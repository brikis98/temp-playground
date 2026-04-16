import express from "express";

const app = express();
app.set("view engine", "ejs");

app.get("/", async (req, res) => {
  res.render("hello");
});

app.get("/health", async (req, res) => {
  res.status(200).json({ ok: true });
});

// Simple middleware to log a message at the end of each request
app.use((req, res, next) => {
  const start = process.hrtime.bigint();

  res.on("finish", () => {
    const durationMs = Number(process.hrtime.bigint() - start) / 1_000_000;
    console.log(
      JSON.stringify({
        event: "http_request",
        method: req.method,
        path: req.path,
        status: res.statusCode,
        duration_ms: Math.round(durationMs * 100) / 100,
      }),
    );
  });

  next();
});

export default app;
