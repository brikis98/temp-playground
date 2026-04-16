#!/usr/bin/env bash
# This script builds Kustomize configurations and then runs Trivy on the rendered output.
# By default, it scans first-party manifests and excludes third-party install bundles.
# Set INCLUDE_THIRD_PARTY=true to also scan kubernetes/argo-rollouts.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if ! command -v kustomize >/dev/null 2>&1; then
  echo "kustomize is required but not installed" >&2
  exit 1
fi

if ! command -v trivy >/dev/null 2>&1; then
  echo "trivy is required but not installed" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARGETS=()
while IFS= read -r target; do
  TARGETS+=("$target")
done < <(
  {
    find kubernetes/apps -type f -name kustomization.yaml \
      | sed 's|/kustomization.yaml$||' \
      | grep -v '/_shared/'
    echo "kubernetes/argocd"
    if [[ "${INCLUDE_THIRD_PARTY:-false}" == "true" ]]; then
      echo "kubernetes/argo-rollouts"
    fi
  } | sort -u
)

if [ "${#TARGETS[@]}" -eq 0 ]; then
  echo "No Kustomize targets found" >&2
  exit 1
fi

echo "Rendering Kustomize targets..."
for target in "${TARGETS[@]}"; do
  out_file="$TMP_DIR/${target//\//__}.yaml"
  echo "- $target"
  kustomize build "$target" > "$out_file"
done

echo "Running Trivy against rendered manifests..."
trivy config --severity HIGH,CRITICAL --exit-code 1 "$TMP_DIR"

echo "Static analysis completed successfully."
