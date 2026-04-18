import express from "express";
import { context } from "@opentelemetry/api";
import winston from "winston";

const app = express();
app.set("view engine", "ejs");

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL ?? "info",
  format: winston.format.json(),
  defaultMeta: { service: "bizcloud-frontend" },
  transports: [new winston.transports.Console()],
});

app.use(loggingMiddleware);

app.get("/", async (req, res) => {
  const metrics = await fetchMetrics();
  res.render("hello", { metrics });
});

app.get("/health", async (req, res) => {
  res.status(200).json({ ok: true });
});

const backendBaseUrl =
  process.env.BACKEND_BASE_URL ??
  (process.env.NODE_ENV === "production"
    ? "http://bizcloud-backend"
    : "http://localhost:8081");

const fetchMetrics = async () => {
  try {
    const response = await fetch(backendBaseUrl);
    if (response.ok) {
      return await response.json();
    }
  } catch (error) {
    logger.error({
      event: "backend_fetch_error",
      service: "bizcloud-frontend",
      backend_base_url: backendBaseUrl,
      error: error instanceof Error ? error.message : String(error),
    });

    return {
      synergy: "N/A",
      mean_time_to_powerpoint: "N/A",
      maturity: "Unknown",
    };
  }
};

function loggingMiddleware(req, res, next) {
  const start = process.hrtime.bigint();
  const boundContext = context.active();

  res.on(
    "finish",
    context.bind(boundContext, () => {
      const durationMs = Number(process.hrtime.bigint() - start) / 1_000_000;
      const traceparent = req.header("traceparent") || "";
      const [trace_id, parent_span_id] = traceparent.split("-");

      logger.info({
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
        request_id:
          req.header("x-request-id") || req.header("x-amzn-requestid"),
        user_agent: req.header("user-agent"),
        client_ip: req.header("x-forwarded-for") || req.socket.remoteAddress,
      });
    }),
  );

  next();
}

export default app;
