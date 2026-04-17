# Grafana Alloy

1. Sign up for Grafana Cloud
2. Login to your stack (e.g., at https://xxx.grafana.net/)
3. Go to Observability -> Kubernetes
4. Click the "Enable" button
5. Go through the wizard to configure installing Grafana Alloy in your cluster
6. At the end, it spits out the YAML values for the installation. We want to use this YAML file, but we don't want to
   check it in with a bunch of secrets in it. So we are going to store the secrets using Kubernetes Secrets, and use
   `alloy-values.yml` instead, which knows how to read the secrets from Kubernetes Secrets (using the [approach
   shown here](https://github.com/grafana/k8s-monitoring-helm/tree/51c7e8f508729d6b1cfe808e10a95344d11e24cd/charts/k8s-monitoring/docs/examples/auth/external-secrets)).
7. Create monitoring namespace: `kubectl create namespace monitoring`
7. The URLs, usernames, and password values from the YAML should be stored as Kubernetes secrets:

    ```shell
    kubectl -n monitoring create secret generic grafana-creds \
      --from-literal=prom-url="<PROMETHEUS_URL>" \
      --from-literal=prom-username="<PROMETHEUS_USERNAME>" \
      --from-literal=loki-url="<LOKI_URL>" \
      --from-literal=loki-username="<LOKI_USERNAME>" \
      --from-literal=otlp-url="<OTLP_URL>" \
      --from-literal=otlp-username="<OTLP_USERNAME>" \
      --from-literal=pyroscope-url="<PYROSCOPE_URL>" \
      --from-literal=pyroscope-username="<PYROSCOPE_USERNAME>" \
      --from-literal=access-token="<PASSWORD>"
    ```
   
    Where:

    - `PROMETHEUS_URL`: The Prometheus URL. E.g., `https://prometheus-prod-XX-prod-eu-west-YY.grafana.net./api/prom/push`.
    - `PROMETHEUS_USERNAME`: The Prometheus username. E.g., `1234567`.
    - `LOKI_URL`: The Loki URL. E.g., `https://logs-prod-XXX.grafana.net./loki/api/v1/push`.
    - `LOKI_USERNAME`: The Loki username. E.g., `1234567`.
    - `OTLP_URL`: The OTLP URL. E.g., `https://otlp-gateway-prod-eu-west-XX.grafana.net./otlp`.
    - `OTLP_USERNAME`: The OTLP username. E.g., `1234567`.
    - `PYROSCOPE_URL`: The Pyroscope URL. E.g., `https://profiles-prod-XXX.grafana.net.:443`.
    - `PYROSCOPE_USERNAME`: The Pyroscope username. E.g., `1234567`.
    - `PASSWORD`: The password token for any of the above URLs (they should all be the same). E.g., `glc_abcd1234FDSDF34234sdfsdfsd234234234lkj234klj324lkj234lkjdvlkjblkjn653124`.
8. Authenticate to your EKS cluster
9. Run `kubectl kustomize --enable-helm grafana-alloy | kubectl apply -f -`