# BizCloud AI

This is an OpenTofu module to deploy the Biz Cloud AI SaaS app. This module includes:

- EKS cluster
- EKS cluster add-ons, such as ExternalDNS and Argo CD
- AWS-Managed Grafana
- A Grafana dashboard for Biz Cloud AI
- An ECR repo for the Biz Cloud AI Docker image
- OIDC provider and IAM roles to do CI/CD for the BizCloud AI app

## Quick start

Deploy the module:

```shell
cd tofu/live/bizcloud-ai
tofu init
tofu apply
```

Build and push the Docker image to ECR:

```shell
cd app
aws ecr get-login-password --region us-east-2 | \
  docker login --username AWS --password-stdin 168852252849.dkr.ecr.us-east-2.amazonaws.com
docker buildx build \
  --target prod \
  --platform linux/amd64,linux/arm64 \
  -t 168852252849.dkr.ecr.us-east-2.amazonaws.com/bizcloud-ai:v1 \
  --push \
  .
```

Deploy the app into EKS, and add the app to Argo CD:

```shell
cd kubernetes
aws eks update-kubeconfig --region us-east-2 --name jim-testing
kubectl apply -k overlays/eks-alb
kubectl apply -k argocd
```

## Grafana dashboard token

To authenticate to Grafana, you use a service account token. This token is set to expire after 30 days. Once it 
expires, to be able to run `tofu plan` or `tofu apply`, you must force OpenTofu to regenerate the token
as follows:

```shell
cd tofu/live/bizcloud-ai
tofu init
tofu apply \
  -refresh=false \
  -replace=aws_grafana_workspace_service_account_token.dashboard_provisioner \
  -target=aws_grafana_workspace_service_account_token.dashboard_provisioner
```