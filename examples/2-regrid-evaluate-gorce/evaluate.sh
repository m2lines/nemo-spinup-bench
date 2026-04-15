#!/bin/bash
# Evaluate generated restart files using nemo-spinup-evaluation

set -euo pipefail

INDIR="$(dirname "$(realpath "$0")")"
RESULTS_DIR="${INDIR}/results"

mkdir -p "${RESULTS_DIR}"

echo "==> Evaluating 1-degree (coarse) restart"
nemo-spinup-evaluation \
    --config "${INDIR}/gen-setup-100.yaml" \
    --sim-path "${INDIR}/generated/coarse" \
    --mode restart \
    --results-dir "${RESULTS_DIR}" \
    --result-file-prefix gen-C2-100

echo "==> Evaluating 0.25-degree (fine) restart"
nemo-spinup-evaluation \
    --config "${INDIR}/gen-setup-025.yaml" \
    --sim-path "${INDIR}/generated/fine" \
    --mode restart \
    --results-dir "${RESULTS_DIR}" \
    --result-file-prefix gen-C2-025

echo "Evaluation complete. Results are saved in: ${RESULTS_DIR}"
