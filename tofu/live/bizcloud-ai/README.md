# BizCloud AI

This is an OpenTofu module to deploy the Biz Cloud AI SaaS stack. This module includes:

- EKS cluster
- EKS cluster add-ons, such as ExternalDNS and Argo CD
- ECR repos for BizCloud AI, frontend, and backend Docker images
- OIDC provider and IAM roles to do CI/CD for BizCloud apps
- Native CloudWatch observability resources:
  - CloudWatch dashboard
  - CloudWatch Logs Insights saved queries

## Quick start

Deploy the module:

```shell
cd tofu/live/bizcloud-ai
tofu init
tofu apply
```

Build and push app images to ECR:

```shell
aws ecr get-login-password --region us-east-2 | \
  docker login --username AWS --password-stdin 168852252849.dkr.ecr.us-east-2.amazonaws.com

cd app
docker buildx build \
  --target prod \
  --platform linux/amd64,linux/arm64 \
  -t 168852252849.dkr.ecr.us-east-2.amazonaws.com/bizcloud-ai:v1 \
  --push \
  .

cd ../bizcloud-frontend
docker buildx build \
  --target prod \
  --platform linux/amd64,linux/arm64 \
  -t 168852252849.dkr.ecr.us-east-2.amazonaws.com/bizcloud-frontend:v1 \
  --push \
  .

cd ../bizcloud-backend
docker buildx build \
  --target prod \
  --platform linux/amd64,linux/arm64 \
  -t 168852252849.dkr.ecr.us-east-2.amazonaws.com/bizcloud-backend:v1 \
  --push \
  .
```

Deploy apps into EKS and add them to Argo CD:

```shell
cd kubernetes
aws eks update-kubeconfig --region us-east-2 --name jim-testing
kubectl apply -k apps/bizcloud-ai/overlays/eks-alb
kubectl apply -k apps/bizcloud-frontend/overlays/eks-alb
kubectl apply -k apps/bizcloud-backend/overlays/eks-alb
kubectl apply -k argocd
```

## CloudWatch observability notes

- Application and infrastructure metrics are shown in a native CloudWatch dashboard (`cloudwatch_dashboard_url` output).
- Saved Logs Insights queries are created for:
  - recent frontend/backend requests
  - latency percentiles by route
  - request errors
