set -eux

# Export this environment variable before running this script
echo "token path: ${GITHUB_TOKEN_PATH}"

export PROJECT=oss-fuzz
export IMAGE=gcr.io/oss-fuzz/triage-party
export SERVICE_NAME=teaparty
export CONFIG_FILE=config/examples/minikube.yaml

docker build -t "${IMAGE}" --build-arg "CFG=${CONFIG_FILE}" .

docker push "${IMAGE}" || exit 2

readonly token="$(cat "${GITHUB_TOKEN_PATH}")"
gcloud beta run deploy "${SERVICE_NAME}" \
    --project "${PROJECT}" \
    --image "${IMAGE}" \
    --set-env-vars="GITHUB_TOKEN=${token},PERSIST_BACKEND=cloudsql,PERSIST_PATH=tp:${DB_PASS}@tcp(k8s-minikube/us-central1/triage-party)/tp" \
    --allow-unauthenticated \
    --region us-central1 \
    --memory 384Mi \
    --platform managed
