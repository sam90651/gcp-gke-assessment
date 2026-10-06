#!/usr/bin/env bash

set -euo pipefail

IP="${1:-136.81.187.221}"
NAMESPACE="${2:-web}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout "$TMP/tls.key" \
  -out "$TMP/tls.crt" \
  -days 90 \
  -subj "/CN=${IP}" \
  -addext "subjectAltName=IP:${IP}"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n "$NAMESPACE" create secret tls web-a-tls \
  --cert="$TMP/tls.crt" \
  --key="$TMP/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret web-a-tls applied in namespace ${NAMESPACE} for ${IP}"