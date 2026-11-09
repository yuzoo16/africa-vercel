import "dotenv/config";
import { PostgresStore } from "./postgresStore.js";

if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is required");
const store = new PostgresStore(process.env.DATABASE_URL);
try {
  const result = await store.verify();
  console.log(JSON.stringify(result));
} finally {
  await store.close();
}
