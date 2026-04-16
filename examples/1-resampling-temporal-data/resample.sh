#!/bin/bash
# Resample DINO temporal cadence files for metric evaluation:
#   10d instantaneous -> 1m monthly mean
#   1m monthly mean   -> 3m quarterly mean
#
# Output format: NetCDF4 (-f nc4), consistent with preexisting files.
# Calendar (360_day) is read automatically from file metadata by CDO.

set -euo pipefail

INDIR="${1:-$(dirname "$(realpath "$0")")}"
OUTDIR="${INDIR}/resampled"

mkdir -p "${OUTDIR}"

# ---------------------------------------------------------------------------
# Step 1: 10d instantaneous -> 1m monthly mean
# Select first 105 time steps (35 complete months) to avoid partial final month
# With 360_day calendar and 10d snapshots, we get exactly 3 steps per month
# ---------------------------------------------------------------------------

export CDO_TIMESTAT_DATE=middle

echo "==> 10d -> 1m: T_3D"
cdo -f nc4 -settaxis,3060-01-16,00:00:00,1mon -monmean -selyear,3060/3062 \
    "${INDIR}/DINO_10d_grid_inst_T_3D.nc" \
    "${OUTDIR}/DINO_1m_grid_T_3D.nc" 

echo "==> 10d -> 1m: U_3D"
cdo -f nc4 -settaxis,3060-01-16,00:00:00,1mon -monmean -selyear,3060/3062 \
    "${INDIR}/DINO_10d_grid_inst_U_3D.nc" \
    "${OUTDIR}/DINO_1m_grid_U_3D.nc" 

echo "==> 10d -> 1m: V_3D"
cdo -f nc4 -settaxis,3060-01-16,00:00:00,1mon -monmean -selyear,3060/3062 \
    "${INDIR}/DINO_10d_grid_inst_V_3D.nc" \
    "${OUTDIR}/DINO_1m_grid_V_3D.nc" 


# cdo showtimestamp resampled/DINO_1m_grid_T_3D.nc | head -10 

# ---------------------------------------------------------------------------
# Step 2: 1m -> 3m quarterly mean
# timselmean,3 averages every 3 consecutive time steps, giving evenly-spaced
# 3-month means consistent with the existing DINO_3m_* files.
# ---------------------------------------------------------------------------

echo "==> 1m -> 3m: T_2D (from existing 1m file)"
cdo -f nc4 timselmean,3 \
    "${INDIR}/DINO_1m_grid_T_2D.nc" \
    "${OUTDIR}/DINO_3m_grid_T_2D.nc"

echo "==> 1m -> 3m: T_3D"
cdo -f nc4 timselmean,3 \
    "${OUTDIR}/DINO_1m_grid_T_3D.nc" \
    "${OUTDIR}/DINO_3m_grid_T_3D.nc"

echo "Done. Output in: ${OUTDIR}"
