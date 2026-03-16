#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <secret-name> [namespace]" >&2
  exit 1
fi

secret_name="$1"
namespace="${2:-gxdch-compliance}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

key_file="$tmp_dir/private-key.pem"
cert_file="$tmp_dir/certificate.pem"

# Generate an RSA private key in PKCS#8 PEM format.
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out "$key_file" >/dev/null 2>&1

openssl req \
  -new \
  -x509 \
  -key "$key_file" \
  -out "$cert_file" \
  -days 825 \
  -subj "/CN=${secret_name}" >/dev/null 2>&1

private_key_b64="$(base64 -w 0 < "$key_file")"
certificate_b64="$(base64 -w 0 < "$cert_file")"

cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${secret_name}
  namespace: ${namespace}
type: Opaque
data:
  key: ${private_key_b64}
  x509: ${certificate_b64}
  PRIVATE_KEY: ${private_key_b64}
  X509_CERTIFICATE: ${certificate_b64}
  openCorporatesAPIKey: ""
EOF
