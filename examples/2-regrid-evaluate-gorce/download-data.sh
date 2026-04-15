#!/bin/bash
set -e

DATA_DIR="data"

# --- Diffusion model outputs (https://zenodo.org/records/16941776) ---
DIFFUSION_ZIP="generated_npy_files.zip"
DIFFUSION_URL="https://zenodo.org/records/16941776/files/${DIFFUSION_ZIP}"

echo "Downloading diffusion model outputs..."
mkdir -p "${DATA_DIR}/diffusion_states"
curl -L -o "${DIFFUSION_ZIP}" "${DIFFUSION_URL}"
unzip -o "${DIFFUSION_ZIP}" "generated_npy_files/chamon_C2_clean/*"
mv generated_npy_files/chamon_C2_clean "${DATA_DIR}/diffusion_states/"
rmdir generated_npy_files
rm "${DIFFUSION_ZIP}"

# --- Reference data (https://zenodo.org/records/19557419) ---
REFERENCE_ZIP="regrid-evaluate.zip"
REFERENCE_URL="https://zenodo.org/records/19557419/files/${REFERENCE_ZIP}"

echo "Downloading reference data..."
curl -L -o "${REFERENCE_ZIP}" "${REFERENCE_URL}"
unzip -o "${REFERENCE_ZIP}" -d "${DATA_DIR}"
rm "${REFERENCE_ZIP}"

echo "Done. Data downloaded to ${DATA_DIR}/"
