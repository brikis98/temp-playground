# BizCloud AI Kubernetes

This folder uses Kustomize overlays with one core app definition and environment-specific patches.

## Structure

- `base/`: Deployment (2 replicas) + Service (`type: LoadBalancer`)
- `overlays/docker-desktop/`: local deployment using the base resources directly
- `overlays/eks-alb/`: EKS deployment patch for image + `Service: ClusterIP` + ALB Ingress

## Docker Desktop (localhost)

Deploy:

```shell
kubectl apply -k ./overlays/docker-desktop
```

Get the local endpoint:

```shell
kubectl get svc bizcloud-ai
```

On Docker Desktop Kubernetes, the `EXTERNAL-IP` is typically `localhost`, so the app is usually reachable on:

- `http://localhost`

## EKS (ALB Ingress)

What this overlay does:

- Patches the app service from `LoadBalancer` to `ClusterIP` (so Service does not create an NLB)
- Creates `IngressClassParams` + `IngressClass` for ALB
- Creates an `Ingress` that provisions an ALB

Update these values before applying:

- `overlays/eks-alb/deployment-image-patch.yaml`: ECR image tag

Authenticate to the EKS cluster:

```shell
aws eks update-kubeconfig \
  --region us-east-2 \
  --name <CLUSTER_NAME>
```

Deploy:

```shell
kubectl apply -k ./overlays/eks-alb
```

Get the ALB hostname:

```shell
kubectl get ingress bizcloud-ai -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```
