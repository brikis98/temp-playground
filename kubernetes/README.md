# BizCloud AI Kubernetes

This folder uses Kustomize overlays so one app config works in both environments.

## Structure

- `base/`: Deployment (2 replicas), Service, HTTPRoute
- `overlays/docker-desktop/`: local Gateway (`gatewayClassName: nginx`)
- `overlays/eks-alb/`: AWS Gateway (`gatewayClassName: aws-alb`)

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

Install AWS Load Balancer Controller with Gateway API support:

```shell
# Set your values
export CLUSTER_NAME="<your-eks-cluster-name>"
export AWS_REGION="<your-aws-region>"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
```

```shell
# Associate IAM OIDC provider with the cluster (safe to re-run)
eksctl utils associate-iam-oidc-provider \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --approve
```

```shell
# Download IAM policy (AWS docs currently reference controller v2.14.1+ for Gateway API support)
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json

# Create IAM policy (ignore "already exists" if re-running)
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

```shell
# Create/attach IAM role to the controller service account
eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --region="$AWS_REGION" \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn="arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy" \
  --override-existing-serviceaccounts \
  --approve
```

```shell
# Install controller via Helm (pick latest chart version from helm search output)
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm search repo eks/aws-load-balancer-controller --versions | head -n 5
```

```shell
# Replace <chart-version> with a version from the previous command
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --version <chart-version> \
  --set clusterName="$CLUSTER_NAME" \
  --set region="$AWS_REGION" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

```shell
# Verify controller and GatewayClass
kubectl get deployment -n kube-system aws-load-balancer-controller
```

```shell
# Create GatewayClass for ALB (platform-level resource)
kubectl apply -f - <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: aws-alb
spec:
  controllerName: gateway.k8s.aws/alb
EOF
```

```shell
# Verify GatewayClass exists
kubectl get gatewayclass aws-alb
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
