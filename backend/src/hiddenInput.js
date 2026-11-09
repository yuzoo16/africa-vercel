export function readHiddenPassword(input = process.stdin, output = process.stdout, prompt = "Password: ") {
  if (!input.isTTY || typeof input.setRawMode !== "function") {
    return Promise.reject(new Error("Interactive terminal input is required"));
  }

  return new Promise((resolve, reject) => {
    let password = "";
    let settled = false;
    const onData = (chunk) => {
      if (settled) return;
      for (const character of String(chunk)) {
        if (character === "\u0003") {
          finishReject(new Error("Bootstrap cancelled"));
          return;
        }
        if (character === "\r" || character === "\n") {
          if (!password) {
            finishReject(new Error("Password must not be empty"));
            return;
          }
          finishResolve(password);
          return;
        }
        if (character === "\u007f" || character === "\b") {
          password = password.slice(0, -1);
        } else if (character >= " ") {
          password += character;
        }
      }
    };
    const onEnd = () => finishReject(new Error("Terminal input ended before password entry completed"));
    const onError = (error) => finishReject(error);

    function cleanup() {
      input.removeListener("data", onData);
      input.removeListener("end", onEnd);
      input.removeListener("error", onError);
      try {
        input.setRawMode(false);
      } finally {
        input.pause();
        output.write("\n");
      }
    }

    function finishResolve(value) {
      if (settled) return;
      settled = true;
      cleanup();
      resolve(value);
    }

    function finishReject(error) {
      if (settled) return;
      settled = true;
      cleanup();
      reject(error);
    }

    output.write(prompt);
    input.on("data", onData);
    input.on("end", onEnd);
    input.on("error", onError);
    input.setRawMode(true);
    input.resume();
  });
}
