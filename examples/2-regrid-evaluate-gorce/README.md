# 2 - Diffusion state restart file generation and evaluation

This example demonstrates the full pipeline for generating upscaled NEMO restart files from diffusion model predictions and evaluating them. It uses the GORCE configuration with 1-degree coarse predictions upscaled to 0.25-degree resolution.

Data is available from two Zenodo repositories:
- Diffusion model outputs: https://zenodo.org/records/16941776
- Reference restart files and mesh masks: https://zenodo.org/records/19557419

## Prerequisites

Create a conda environment and install xESMF (required for regridding). Then create a pip venv with access to the conda packages using `--system-site-packages`:

```bash
conda create -n nemo python=3.10
conda activate nemo
conda install -c conda-forge xesmf

python -m venv venv --system-site-packages
source venv/bin/activate
```

Install the nemo-spinup-restart and nemo-spinup-evaluation tools (from the repo root):

```bash
pip install ./nemo-spinup-restart
pip install ./nemo-spinup-evaluation
```

## Data setup

Download data from both Zenodo repositories using the provided script:

```bash
bash download-data.sh
```

Or download manually:

1. **Diffusion model outputs** from https://zenodo.org/records/16941776 - download `generated_npy_files.zip` and extract the `chamon_C2_clean/` directory into `data/diffusion_states/`.
2. **Reference data** from https://zenodo.org/records/19474413 - download `regrid-evaluate.zip` and extract into `data/`.

The expected directory structure is:

```
data/
├── diffusion_states/
│   └── chamon_C2_clean/
│       ├── toce.npy
│       ├── soce.npy
│       └── ssh.npy
├── 100-reference/
│   ├── DINO_00000002_restart.nc
│   ├── mesh_mask.nc
│   └── namelist_cfg
└── 025-reference/
    ├── DINO_10800000_restart.nc
    └── mesh_mask.nc
```

## Regrid and upscale

Generate a 0.25-degree restart file from the diffusion model predictions:

```bash
bash upscale.sh
```

This runs the `nemo-upscale` tool which:
1. Loads the diffusion model numpy predictions (temperature, salinity, SSH)
2. Creates a coarse (1-degree) restart file from the predictions
3. Regrids to fine (0.25-degree) resolution using xESMF bilinear interpolation
4. Applies the fine resolution mask and zeros out velocities for NEMO to recompute

Output is written to `./generated/coarse/` and `./generated/fine/`.

## Evaluate using nemo-spinup-evaluation

Evaluate the generated restart files at both resolutions. There are separate configs for the coarse (1-degree) and fine (0.25-degree) restart files:

- `gen-setup-100.yaml` - evaluates the coarse restart
- `gen-setup-025.yaml` - evaluates the fine restart

```bash
bash evaluate.sh
```

Results are saved to `./results/` with prefixes `gen-C2-100` and `gen-C2-025`.

## Results

| Metric | Coarse (1°) | Fine (0.25°) |
|---|---|---|
| Density (from file) | 0.1875 | 0.1920 |
| Density (computed) | 0.2102 | 0.2161 |
| Temperature 500m 30NS | 10.5851 | 10.5861 |
| Temperature BW box | 3.5304 | 3.5432 |
| Temperature DW box | 3.6499 | 3.6545 |
| ACC Drake Passage | 257.2559 | 0.0000 |
| NASTG BSF max | 35.4295 | 0.0000 |

Note: ACC Drake Passage and NASTG BSF max are zero at fine resolution because velocities are zeroed out in the upscaled restart for NEMO to recompute.

## Running the full pipeline

To run both steps in sequence:

```bash
bash upscale.sh && bash evaluate.sh
```
