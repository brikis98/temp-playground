# BizCloud AI Kubernetes

This folder has YAML code to deploy the BizCloud AI app into Kubernetes. It uses Kustomize overlays with one core app 
definition and environment-specific patches.

## Structure

- `base/`: Deployment (2 replicas) + Service (`type: LoadBalancer`)
- `overlays/docker-desktop/`: local deployment using the base resources directly
- `overlays/eks-alb/`: EKS deployment patch for image + `Service: ClusterIP` + ALB Ingress
- `overlays/eks-alb-blue-green/`: EKS deployment with ALB Ingress + Argo Rollouts blue-green strategy
- `argo-rollouts/`: Argo Rollouts install manifests (single-command install via Kustomize)

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

- `overlays/eks-alb/kustomization.yaml` (`images`): ECR image name and tag override

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

## Argo CD instructions

Add the app to Argo CD as follows:

```shell
kubectl apply -k ./argocd
```

## Argo Rollouts install (single command)

Install Argo Rollouts controller + CRDs:

```shell
kubectl apply -k ./argo-rollouts
```

Verify:

```shell
kubectl -n argo-rollouts get deploy argo-rollouts
kubectl get crd rollouts.argoproj.io
```

## Blue-green update flow (EKS blue-green overlay)

1) Change image tag in `overlays/eks-alb-blue-green/kustomization.yaml` (`images[].newTag`)

2) Apply the overlay:

```shell
kubectl apply -k ./overlays/eks-alb-blue-green
```

3) Check rollout status:

```shell
kubectl get rollout bizcloud-ai
kubectl argo rollouts get rollout bizcloud-ai --watch
```

With `autoPromotionEnabled: false`, rollout pauses before switching production traffic.

4) Check the preview environment

You can test your code in the preview environment before the load balancer exposes it to users:

```shell
kubectl port-forward svc/bizcloud-ai-preview 8081:80
```

Open http://localhost:8081 in your browser.

5) Promote when ready:

[Installing the Argo Rollouts plugin for 
`kubectl`](https://argo-rollouts.readthedocs.io/en/stable/features/kubectl-plugin/) (e.g., run 
`brew install argoproj/tap/kubectl-argo-rollouts`) and to promote, run the following:

```shell
kubectl argo rollouts promote bizcloud-ai
```

Or you can do it with vanilla `kubectl` as follows:

```shell
kubectl patch rollouts.argoproj.io bizcloud-ai \
  --subresource=status \
  --type merge \
  -p '{"status":{"pauseConditions":null}}'
```
