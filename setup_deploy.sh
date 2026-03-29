#!/usr/bin/env bash
set -euo pipefail

REGION="${GCP_REGION:-us-central1}"
BUCKET_NAME="${GCS_BUCKET:-otmow-feedback-db}"

# ── Resolve project ──────────────────────────────────────────────────────────

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "${PROJECT_ID}" ]]; then
    echo "Error: no active GCP project. Run: gcloud config set project <PROJECT_ID>" >&2
    exit 1
fi
PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")
SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "Project:  ${PROJECT_ID}"
echo "Region:   ${REGION}"
echo "Bucket:   gs://${BUCKET_NAME}"
echo "SA:       ${SA}"
echo ""

# ── 1. Create GCS bucket ────────────────────────────────────────────────────

echo "==> Creating GCS bucket gs://${BUCKET_NAME} ..."
if gcloud storage buckets describe "gs://${BUCKET_NAME}" &>/dev/null; then
    echo "    Bucket already exists, skipping."
else
    gcloud storage buckets create "gs://${BUCKET_NAME}" \
        --location="${REGION}" \
        --uniform-bucket-level-access
fi

# ── 2. Upload existing database (if present) ────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_FILE="${SCRIPT_DIR}/feedbacks.db"

if [[ -f "${DB_FILE}" ]]; then
    echo "==> Uploading feedbacks.db to gs://${BUCKET_NAME}/ ..."
    gcloud storage cp "${DB_FILE}" "gs://${BUCKET_NAME}/feedbacks.db"
else
    echo "==> No local feedbacks.db found, skipping upload."
fi

# ── 3. Create secrets ───────────────────────────────────────────────────────

create_secret() {
    local name="$1"
    local env_var="$2"
    local prompt="$3"

    if gcloud secrets describe "${name}" &>/dev/null 2>&1; then
        echo "    Secret '${name}' already exists, skipping."
        return
    fi

    local value="${!env_var:-}"
    if [[ -z "${value}" ]]; then
        echo -n "    ${prompt}: "
        read -r -s value
        echo ""
    fi

    if [[ -z "${value}" ]]; then
        echo "Error: no value provided for ${name}" >&2
        exit 1
    fi

    echo -n "${value}" | gcloud secrets create "${name}" --data-file=-
    echo "    Created secret '${name}'."
}

echo "==> Creating secrets in Secret Manager ..."
echo "    (reads from SECRET_KEY / SMTP_EMAIL / SMTP_PASSWORD env vars, or prompts)"
create_secret "SECRET_KEY"     "SECRET_KEY"     "Enter SECRET_KEY"
create_secret "SMTP_EMAIL"     "SMTP_EMAIL"     "Enter SMTP_EMAIL"
create_secret "SMTP_PASSWORD"  "SMTP_PASSWORD"  "Enter SMTP_PASSWORD"

# ── 4. Grant IAM permissions ────────────────────────────────────────────────

echo "==> Granting Secret Manager access to ${SA} ..."
for secret in SECRET_KEY SMTP_EMAIL SMTP_PASSWORD; do
    gcloud secrets add-iam-policy-binding "${secret}" \
        --member="serviceAccount:${SA}" \
        --role="roles/secretmanager.secretAccessor" \
        --quiet
done

echo "==> Granting GCS access to ${SA} ..."
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SA}" \
    --role="roles/storage.objectAdmin" \
    --quiet

echo ""
echo "Setup complete. Run ./deploy.sh to build and deploy."
