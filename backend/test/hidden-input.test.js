import test from "node:test";
import assert from "node:assert/strict";
import { EventEmitter } from "node:events";
import { PassThrough } from "node:stream";
import { readHiddenPassword } from "../src/hiddenInput.js";

class TerminalInput extends EventEmitter {
  constructor() {
    super();
    this.isTTY = true;
    this.rawModes = [];
    this.paused = false;
  }

  setRawMode(enabled) {
    this.rawModes.push(enabled);
    return this;
  }

  resume() {
    return this;
  }

  pause() {
    this.paused = true;
    return this;
  }
}

test("hidden password accepts Enter and restores terminal mode", async () => {
  const input = new TerminalInput();
  const output = new PassThrough();
  const promise = readHiddenPassword(input, output, "Password: ");

  input.emit("data", "Secret");
  input.emit("data", "\r");

  assert.equal(await promise, "Secret");
  assert.deepEqual(input.rawModes, [true, false]);
  assert.equal(input.paused, true);
  assert.equal(output.read()?.toString(), "Password: \n");
  assert.equal(input.listenerCount("data"), 0);
  assert.equal(input.listenerCount("end"), 0);
  assert.equal(input.listenerCount("error"), 0);
});

test("hidden password does not expose typed characters and supports backspace", async () => {
  const input = new TerminalInput();
  const outputChunks = [];
  const output = { write(value) { outputChunks.push(String(value)); } };
  const promise = readHiddenPassword(input, output, "Password: ");

  input.emit("data", "S");
  input.emit("data", "ec");
  input.emit("data", "\u007f");
  input.emit("data", "cret\n");

  assert.equal(await promise, "Secret");
  assert.deepEqual(outputChunks, ["Password: ", "\n"]);
});

test("empty hidden password is rejected and cleaned up", async () => {
  const input = new TerminalInput();
  const output = { write() {} };
  const promise = readHiddenPassword(input, output);

  input.emit("data", "\r");

  await assert.rejects(promise, /must not be empty/);
  assert.deepEqual(input.rawModes, [true, false]);
  assert.equal(input.listenerCount("data"), 0);
  assert.equal(input.listenerCount("end"), 0);
  assert.equal(input.listenerCount("error"), 0);
});

test("interrupt cancels and restores terminal mode", async () => {
  const input = new TerminalInput();
  const output = { write() {} };
  const promise = readHiddenPassword(input, output);

  input.emit("data", "\u0003");

  await assert.rejects(promise, /Bootstrap cancelled/);
  assert.deepEqual(input.rawModes, [true, false]);
  assert.equal(input.listenerCount("data"), 0);
});

test("hidden input requires an interactive terminal", async () => {
  const input = new TerminalInput();
  input.isTTY = false;
  await assert.rejects(readHiddenPassword(input, { write() {} }), /Interactive terminal input is required/);
});
