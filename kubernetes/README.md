# BizCloud AI Kubernetes

This folder uses Kustomize overlays so one app config works in both environments.

## Structure

- `base/`: Deployment (2 replicas), Service, HTTPRoute
- `overlays/docker-desktop/`: local Gateway (`gatewayClassName: nginx`)
- `overlays/eks-alb/`: AWS GatewayClass + Gateway (`gatewayClassName: aws-alb`)

## Usage with Docker Desktop 

Install NGINX API Gateway Fabric CRDs:

```shell
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.5.1" | kubectl apply -f -
```

Install NGINX Gateway Fabric controller:

```shell
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
--version 2.5.1 \
--create-namespace -n nginx-gateway \
--set nginx.service.type=LoadBalancer
```

Check it installed correctly:

```shell
kubectl get gatewayclass
kubectl get pods -n nginx-gateway
```

Deploy the app:

```shell
kubectl apply -k ./overlays/docker-desktop
```

Find how to access the app:

```shell
kubectl get svc
```

Then open the Gateway service endpoint on localhost (typically `http://localhost` or `http://localhost:<port>` depending on the service port mapping).

## Usage with EKS

Install AWS Load Balancer Controller with Gateway API support.

Check classes:

```shell
kubectl get gatewayclass
```

Deploy the app:

```shell
kubectl apply -k ./overlays/eks-alb
```

Find how to access the app:

```shell
kubectl get svc
```

## Notes

- If your cluster uses a different GatewayClass name, update `gatewayClassName` in the corresponding overlay.
- For EKS, you may also add HTTPS listeners and cert references in `overlays/eks-alb/gateway.yaml`.
