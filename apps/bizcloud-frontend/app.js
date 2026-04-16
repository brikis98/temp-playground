import express from "express";

const app = express();
app.set("view engine", "ejs");

const backendBaseUrl =
  process.env.BACKEND_BASE_URL ??
  (process.env.NODE_ENV === "production"
    ? "http://bizcloud-backend"
    : "http://localhost:8081");

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
      JSON.stringify({
        event: "backend_fetch_error",
        service: "bizcloud-frontend",
        backend_base_url: backendBaseUrl,
        error: error instanceof Error ? error.message : String(error),
      }),
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
    const traceparent = req.header("traceparent") || "";
    const [trace_id, parent_span_id] = traceparent.split("-");

    console.log(
      JSON.stringify({
        event: "http_request",
        service: "bizcloud-frontend",
        method: req.method,
        route: req.route?.path,
        path: req.path,
        status: res.statusCode,
        duration_ms: Math.round(durationMs * 100) / 100,
        trace_id,
        parent_span_id,
        traceparent,
        x_amzn_trace_id: req.header("x-amzn-trace-id"),
        request_id:
          req.header("x-request-id") || req.header("x-amzn-requestid"),
        user_agent: req.header("user-agent"),
        client_ip: req.header("x-forwarded-for") || req.socket.remoteAddress,
      }),
    );
  });

  next();
});

export default app;
