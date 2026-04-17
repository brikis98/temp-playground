import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node";
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-http";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";
import { NodeSDK } from "@opentelemetry/sdk-node";

const traceExporter = new OTLPTraceExporter();
const metricExporter = new OTLPMetricExporter();

const sdk = new NodeSDK({
  traceExporter,
  metricReader: new PeriodicExportingMetricReader({
    exporter: metricExporter,
    exportIntervalMillis: 60000,
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

process.on("SIGTERM", () => {
  sdk
    .shutdown()
    .catch((error) => {
      console.error("OpenTelemetry shutdown failed", error);
    })
    .finally(() => process.exit(0));
});
