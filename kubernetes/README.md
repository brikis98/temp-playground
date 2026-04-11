# BizCloud AI Kubernetes

This folder uses Kustomize overlays with one core app definition and environment-specific patches.

## Structure

- `base/`: Deployment (2 replicas) + Service (`type: LoadBalancer`)
- `overlays/docker-desktop/`: local deployment using the base resources directly
- `overlays/eks-nlb/`: EKS deployment patch for image + NLB + TLS annotations

## Docker Desktop (localhost)

Deploy:

```shell
kubectl apply -k ./overlays/docker-desktop
```

Get the local endpoint:

```shell
kubectl get svc bizcloud-ai
```

On Docker Desktop Kubernetes, the `EXTERNAL-IP` is typically `localhost`, so the app is reachable on:

- `http://localhost`

## EKS (NLB + ACM TLS)

Update these values in `overlays/eks-nlb/service-nlb-tls-patch.yaml`:

- `service.beta.kubernetes.io/aws-load-balancer-ssl-cert` -> your ACM certificate ARN (same region as EKS/NLB)
- Optional NLB settings such as scheme or health check path

Deploy:

```shell
kubectl apply -k ./overlays/eks-nlb
```

Get the NLB hostname:

```shell
kubectl get svc bizcloud-ai -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Route 53 custom domain example

Use an alias record from your domain to the NLB hostname returned above.

1. Find your Route 53 hosted zone ID for the domain:

```shell
aws route53 list-hosted-zones-by-name --dns-name example.com
```

2. Create or update an alias `A` record to the NLB:

```shell
cat > /tmp/route53-alias.json <<'JSON'
{
  "Comment": "Alias app.example.com to EKS NLB",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "app.example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "k8s-default-bizcloud-1234567890.us-east-2.elb.amazonaws.com",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
JSON

aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789ABC \
  --change-batch file:///tmp/route53-alias.json
```

Notes:

- `AliasTarget.HostedZoneId` is the NLB hosted zone ID (not your public hosted zone ID).
- `--hosted-zone-id` is your public Route 53 hosted zone ID (for example `example.com`).
- ACM certificate must be in the same AWS region as the NLB.
