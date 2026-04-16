import express from "express";

const app = express();
app.set("view engine", "ejs");

const backendBaseUrl =
  process.env.BACKEND_BASE_URL || process.env.NODE_ENV === "production"
    ? "http://bizcloud-backend"
    : "http://localhost:8081";

const fallbackMetrics = {
  synergy: "N/A",
  mean_time_to_powerpoint: "N/A",
  maturity: "Unknown",
};

app.get("/", async (req, res) => {
  let metrics = fallbackMetrics;

  try {
    const response = await fetch(backendBaseUrl);
    if (response.ok) {
      metrics = await response.json();
    }
  } catch (error) {
    console.error(
      `Failed to fetch backend metrics from ${backendBaseUrl}:`,
      error,
    );
  }

  res.render("hello", { metrics });
});

app.get("/health", async (req, res) => {
  res.status(200).json({ ok: true });
});

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
