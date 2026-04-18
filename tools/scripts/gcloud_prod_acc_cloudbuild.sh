#!/bin/bash

set -euo pipefail

GCP_PROJECT_ID="${GCP_PROJECT_ID_PROD:-}"
WIF_PROVIDER="${GCP_WORKLOAD_IDENTITY_PROVIDER_PROD:-}"
SERVICE_ACCOUNT="${ACCOUNT_PROD:-}"
OIDC_TOKEN="${GITLAB_OIDC_TOKEN:-}"

if [ -z "$GCP_PROJECT_ID" ]; then
  echo "ERROR: Set GCP_PROJECT_ID_PROD."
  exit 1
fi

if [ -z "$WIF_PROVIDER" ]; then
  echo "ERROR: Set GCP_WORKLOAD_IDENTITY_PROVIDER_PROD."
  exit 1
fi

if [ -z "$SERVICE_ACCOUNT" ]; then
  echo "ERROR: Set ACCOUNT_PROD."
  exit 1
fi

if [ -z "$OIDC_TOKEN" ]; then
  echo "ERROR: GitLab did not provide GITLAB_OIDC_TOKEN."
  exit 1
fi

echo "Current project: $(gcloud config get-value project)"

OIDC_TOKEN_FILE="$(mktemp)"
WIF_CRED_FILE="$(mktemp)"
trap 'rm -f "$OIDC_TOKEN_FILE" "$WIF_CRED_FILE"' EXIT

printf '%s' "$OIDC_TOKEN" > "$OIDC_TOKEN_FILE"

gcloud iam workload-identity-pools create-cred-config \
  "$WIF_PROVIDER" \
  --service-account="$SERVICE_ACCOUNT" \
  --credential-source-file="$OIDC_TOKEN_FILE" \
  --output-file="$WIF_CRED_FILE"

gcloud auth login --brief --cred-file="$WIF_CRED_FILE"
export GOOGLE_APPLICATION_CREDENTIALS="$WIF_CRED_FILE"
export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$WIF_CRED_FILE"

echo "Authenticated accounts:"
gcloud auth list

gcloud config set project "$GCP_PROJECT_ID"

echo "Active account: $(gcloud config get-value account)"
echo "Active project: $(gcloud config get-value project)"
