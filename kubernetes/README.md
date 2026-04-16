# BizCloud Kubernetes

This folder has Kustomize manifests for all BizCloud apps.

## Structure

- `apps/bizcloud-ai`: original app manifests
- `apps/bizcloud-frontend`: frontend app manifests
- `apps/bizcloud-backend`: backend API manifests
- `apps/_shared`: shared Kustomize building blocks used by all apps
- `argocd`: Argo CD cluster registration
- `argo-rollouts`: Argo Rollouts install manifests

Each app has the same layout:

- `base`: Deployment + Service
- `overlays/docker-desktop`: local Docker Desktop deployment
- `overlays/eks-alb`: EKS deployment (ALB ingress for public apps, internal service for backend)
- `overlays/eks-alb-blue-green`: EKS blue-green deployment with Argo Rollouts

## Docker Desktop

Deploy one app locally:

```shell
kubectl apply -k ./apps/bizcloud-ai/overlays/docker-desktop
```

## EKS (ALB)

Deploy one app into EKS:

```shell
kubectl apply -k ./apps/bizcloud-frontend/overlays/eks-alb
```

Get ingress hostname:

```shell
kubectl get ingress bizcloud-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Argo CD

Register cluster:

```shell
kubectl apply -k ./argocd
```

Apply per-app Argo CD application manifests:

```shell
kubectl apply -k ./apps/bizcloud-ai/argocd
kubectl apply -k ./apps/bizcloud-frontend/argocd
kubectl apply -k ./apps/bizcloud-backend/argocd
```

## Argo Rollouts install

Install controller + CRDs:

```shell
kubectl apply -k ./argo-rollouts
```

## Blue-green updates

1. Update image tag in `apps/<app>/overlays/eks-alb-blue-green/kustomization.yaml`
2. Apply overlay:

```shell
kubectl apply -k ./apps/bizcloud-ai/overlays/eks-alb-blue-green
```

3. Inspect rollout:

```shell
kubectl argo rollouts get rollout bizcloud-ai --watch
```

4. Promote when ready:

```shell
kubectl argo rollouts promote bizcloud-ai
```
