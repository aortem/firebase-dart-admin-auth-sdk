#!/bin/bash

set -e

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

gcloud auth activate-service-account $ACCOUNT_PROD --key-file=$GOOGLE_CLOUD_CREDENTIALS_PROD

echo "Setting account to: $ACCOUNT_PROD"
gcloud config set account $ACCOUNT_PROD
gcloud config set project aortem-prod

echo "Authenticated accounts:"
gcloud auth list

echo "Active account: $(gcloud config get-value account)"
echo "Active project: $(gcloud config get-value project)"

export GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_CLOUD_CREDENTIALS_PROD"

gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
gcloud config set project aortem-prod

echo "Installing Firebase CLI globally"
npm install -g firebase-tools

echo "Listing available Firebase projects"
firebase projects:list
