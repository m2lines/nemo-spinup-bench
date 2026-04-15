#!/bin/bash
# Upscale diffusion model predictions from 1-degree to 0.25-degree restart files
# using nemo-upscale from nemo-spinup-restart.
#
# Requires: xesmf (conda install -c conda-forge xesmf)

set -euo pipefail

INDIR="$(dirname "$(realpath "$0")")"
DATA_DIR="${INDIR}/data"
OUTPUT_DIR="${INDIR}/generated"

mkdir -p "${OUTPUT_DIR}"

echo "==> Upscaling diffusion predictions to 0.25-degree restart file"
nemo-upscale upscale \
    --predictions-dir "${DATA_DIR}/diffusion_states/chamon_C2_clean/" \
    --coarse-template "${DATA_DIR}/100-reference/DINO_00000002_restart.nc" \
    --coarse-mask     "${DATA_DIR}/100-reference/mesh_mask.nc" \
    --coarse-namelist "${DATA_DIR}/100-reference/namelist_cfg" \
    --fine-template   "${DATA_DIR}/025-reference/DINO_10800000_restart.nc" \
    --fine-mask       "${DATA_DIR}/025-reference/mesh_mask.nc" \
    --name            C2 \
    --time-index      4 \
    --output-dir      "${OUTPUT_DIR}"

# Move restart files into resolution-specific directories with mesh mask symlinks
mkdir -p "${OUTPUT_DIR}/coarse" "${OUTPUT_DIR}/fine"

mv "${OUTPUT_DIR}/generated_restart_C2_coarse.nc" "${OUTPUT_DIR}/coarse/"
mv "${OUTPUT_DIR}/generated_restart_C2_fine.nc"   "${OUTPUT_DIR}/fine/"

ln -sf "${DATA_DIR}/100-reference/mesh_mask.nc" "${OUTPUT_DIR}/coarse/mesh_mask.nc"
ln -sf "${DATA_DIR}/025-reference/mesh_mask.nc" "${OUTPUT_DIR}/fine/mesh_mask.nc"

echo "Done. Output in: ${OUTPUT_DIR}"
