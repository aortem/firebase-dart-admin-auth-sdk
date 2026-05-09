#!/bin/bash

set -euo pipefail

START_DIR="$(pwd)"
FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-${GCP_PROJECT_ID_PROD:-}}"
WIF_PROVIDER="${GCP_WORKLOAD_IDENTITY_PROVIDER_PROD:-}"
FIREBASE_ACCOUNT="${ACCOUNT_PROD:-}"
OIDC_TOKEN="${GITLAB_OIDC_TOKEN:-}"

if [ -z "$FIREBASE_PROJECT_ID" ]; then
  echo "ERROR: Set FIREBASE_PROJECT_ID or GCP_PROJECT_ID_PROD."
  exit 1
fi

if [ -z "$WIF_PROVIDER" ]; then
  echo "ERROR: Set GCP_WORKLOAD_IDENTITY_PROVIDER_PROD."
  exit 1
fi

if [ -z "$FIREBASE_ACCOUNT" ]; then
  echo "ERROR: Set ACCOUNT_PROD."
  exit 1
fi

if [ -z "$OIDC_TOKEN" ]; then
  echo "ERROR: GitLab did not provide GITLAB_OIDC_TOKEN."
  exit 1
fi

echo "Navigating to docs directory"
cd firebase-dart-admin-auth-sdk/docs

echo "Listing files in the directory"
ls -la

echo "Cleaning up previous artifacts"
rm -rf node_modules dist build/site

echo "Installing dependencies"
npm ci

echo "Building the documentation site"
npm run build

echo "Current project: $(gcloud config get-value project)"

OIDC_TOKEN_FILE="$(mktemp)"
WIF_CRED_FILE="$(mktemp)"
trap 'rm -f "$OIDC_TOKEN_FILE" "$WIF_CRED_FILE"' EXIT

printf '%s' "$OIDC_TOKEN" > "$OIDC_TOKEN_FILE"

gcloud iam workload-identity-pools create-cred-config \
  "$WIF_PROVIDER" \
  --service-account="$FIREBASE_ACCOUNT" \
  --credential-source-file="$OIDC_TOKEN_FILE" \
  --output-file="$WIF_CRED_FILE"

gcloud auth login --brief --cred-file="$WIF_CRED_FILE"
export GOOGLE_APPLICATION_CREDENTIALS="$WIF_CRED_FILE"
export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$WIF_CRED_FILE"

echo "Authenticated accounts:"
gcloud auth list

gcloud config set project "$FIREBASE_PROJECT_ID"

echo "Active account: $(gcloud config get-value account)"
echo "Active project: $(gcloud config get-value project)"

echo "Current directory: $(pwd)"
ls -la

echo "Installing Firebase CLI globally"
npm install -g firebase-tools

echo "Listing available Firebase projects"
firebase projects:list

echo "Adding Firebase project to local configuration"
firebase use --add "$FIREBASE_PROJECT_ID" || echo "Project already configured"

echo "Returning to original working directory"
cd "$START_DIR"
