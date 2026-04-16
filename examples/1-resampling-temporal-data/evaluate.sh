#!/bin/bash
# Evaluate the resampled data using nemo-spinup-evaluation

set -euo pipefail

# Define the directory paths
INDIR="$(dirname "$(realpath "$0")")"
CONFIG_DIR="${INDIR}"
DATA_DIR="${INDIR}/restart3"

# Create a temporary directory for the evaluation results
mkdir -p "${INDIR}/results"

# Define the configuration files for evaluation
eval_config_10d="${CONFIG_DIR}/DINO-evaluation-10d.yaml"
eval_config_1m="${CONFIG_DIR}/DINO-evaluation-1m.yaml"
eval_config_3m="${CONFIG_DIR}/DINO-evaluation-3m.yaml"

# Check if the evaluation configuration files exist
if [ ! -f "$eval_config_10d" ]; then
    echo "Error: Evaluation configuration file not found at $eval_config_10d"
    exit 1
fi

if [ ! -f "$eval_config_1m" ]; then
    echo "Error: Evaluation configuration file not found at $eval_config_1m"
    exit 1
fi

if [ ! -f "$eval_config_3m" ]; then
    echo "Error: Evaluation configuration file not found at $eval_config_3m"
    exit 1
fi

# Run the evaluation for each resampled file
echo "==> Evaluating 10-day data"
nemo-spinup-evaluation \
    --config "$eval_config_10d" \
    --sim-path "$DATA_DIR" \
    --results-dir "${INDIR}/results/10d"

echo "==> Evaluating 1-month data"
nemo-spinup-evaluation \
    --config "$eval_config_1m" \
    --sim-path "$DATA_DIR" \
    --results-dir "${INDIR}/results/1m"

echo "==> Evaluating 3-month data"
nemo-spinup-evaluation \
    --config "$eval_config_3m" \
    --sim-path "$DATA_DIR" \
    --results-dir "${INDIR}/results/3m"

echo "Evaluation complete. Results are saved in: ${INDIR}/results"
