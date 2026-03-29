#!/usr/bin/env bash
set -euo pipefail

REGION="${GCP_REGION:-us-central1}"
BUCKET_NAME="${GCS_BUCKET:-otmow-feedback-db}"
SERVICE_NAME="${CLOUD_RUN_SERVICE:-eng-feedback-tool}"

# ── Resolve project ──────────────────────────────────────────────────────────

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "${PROJECT_ID}" ]]; then
    echo "Error: no active GCP project. Run: gcloud config set project <PROJECT_ID>" >&2
    exit 1
fi

IMAGE="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Detect container CLI ────────────────────────────────────────────────────

if command -v podman &>/dev/null; then
    CTR=podman
elif command -v docker &>/dev/null; then
    CTR=docker
else
    echo "Error: neither podman nor docker found" >&2
    exit 1
fi

echo "Project:  ${PROJECT_ID}"
echo "Region:   ${REGION}"
echo "Image:    ${IMAGE}"
echo "Runtime:  ${CTR}"
echo ""

# ── 1. Authenticate with GCR ───────────────────────────────────────────────

echo "==> Authenticating ${CTR} with GCR ..."
gcloud auth print-access-token | ${CTR} login -u oauth2accesstoken --password-stdin gcr.io

# ── 2. Build ─────────────────────────────────────────────────────────────────

echo "==> Building container image (linux/amd64) ..."
${CTR} build --platform linux/amd64 -t "${IMAGE}" "${SCRIPT_DIR}"

# ── 3. Push to GCR ──────────────────────────────────────────────────────────

echo "==> Pushing to GCR ..."
${CTR} push "${IMAGE}"

# ── 4. Deploy to Cloud Run ──────────────────────────────────────────────────

echo "==> Deploying to Cloud Run ..."
gcloud run deploy "${SERVICE_NAME}" \
    --image "${IMAGE}" \
    --region "${REGION}" \
    --platform managed \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 1 \
    --max-instances 1 \
    --no-cpu-throttling \
    --timeout 300 \
    --execution-environment gen2 \
    --set-env-vars "CLOUD_RUN=1,DB_PATH=/mnt/gcs/feedbacks.db" \
    --set-secrets "SECRET_KEY=SECRET_KEY:latest,SMTP_EMAIL=SMTP_EMAIL:latest,SMTP_PASSWORD=SMTP_PASSWORD:latest" \
    --add-volume name=gcs-vol,type=cloud-storage,bucket="${BUCKET_NAME}" \
    --add-volume-mount volume=gcs-vol,mount-path=/mnt/gcs \
    --allow-unauthenticated \
    --cpu-boost

# ── 5. Print service URL ────────────────────────────────────────────────────

echo ""
SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" \
    --region "${REGION}" \
    --format "value(status.url)" 2>/dev/null)
echo "Deployed: ${SERVICE_URL}"
echo "Health:   ${SERVICE_URL}/healthz"
