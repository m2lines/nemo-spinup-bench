# 1-sampling-temporal-data and evaluation

This data was provided by Etienne Meunier to test resampling using cdo and other tooling in mid-2025. 

It contains instantaneous data. I would advise outputting 10 day averages instead of instantaneous outputs to avoid unnecessary jitter. We proceed with this example as a demonstration of how the user can evaluate with nemo-spinup-evaluation.

## Pipeline steps

1. **Install CDO** (if not already available):
   ```bash
   conda install -c conda-forge cdo
   ```

2. **Download data from Zenodo:**
   ```bash
   wget https://zenodo.org/records/19474414/files/restart3.tar
   ```

3. **Extract the archive:**
   ```bash
   tar xvf restart3.tar
   ```

4. **Run the resampling step:**

   This assumes data has been extracted to the `restart3` directory inside the `1-sampling-temporal-data` example.
   ```bash
   bash resample.sh ./restart3
   ```

5. **Run the evaluation:**
   ```bash
   bash evaluate.sh
   ```


## Data Processing Note: 10-Day to Monthly Resampling

### Input Data Characteristics
* **Source:** NEMO/DINO Model Output
* **Temporal Resolution:** 10-day instantaneous snapshots (`_inst`)
* **Calendar:** `360_day` (30 days per month)
* **Original Timesteps:** 108 steps (3 years + 1 day overhead)
* **Original Cadence:** Data points fall on the 1st, 11th, and 21st of each month due to the interaction between the 10-day output frequency and the 360-day calendar.

### Additional Data Characteristics
* **10-day Data:** Includes 3D temperature (T), U-velocity, and V-velocity fields.
* **1-month Data:** Includes 2D temperature (T) fields.
* **3-month Data:** Includes 3D U-velocity, V-velocity, and W-velocity fields.
* **Restart Files:** Includes restart files at specific timestamps (e.g., `DINO_35524800_restart.nc`, `DINO_35654400_restart.nc`).
* **Configuration Files:** Includes domain configuration (`domain_cfg.nc`) and mesh mask (`mesh_mask.nc`).

### Processing Pipeline (CDO)
To generate the monthly mean files, the following Climate Data Operators (CDO) command was utilized to ensure a "lazy" (memory-efficient) streaming workflow:

```bash
cdo -f nc4 -settaxis,3060-01-16,00:00:00,1mon -monmean -selyear,3060/3062 input_10d.nc output_1m.nc
```

See `resample.sh` for a complete script for all files.

### Sequence of Operations
The `resample.sh` script performs the following sequence of operations to resample the data:

1. **Step 1: 10-day instantaneous to 1-month monthly mean**
   - The script uses the Climate Data Operators (CDO) tool to resample 10-day instantaneous data to 1-month monthly means.
   - It selects the first 105 time steps (35 complete months) to avoid a partial final month.
   - The `settaxis` command sets the time axis to start at `3060-01-16,00:00:00` with a 1-month interval.
   - The `monmean` command calculates the monthly mean.
   - The `selyear` command selects the years 3060 to 3062.
   - This process is applied to the 3D temperature (T), U-velocity, and V-velocity fields.

2. **Step 2: 1-month to 3-month quarterly mean**
   - The script uses the `timselmean,3` command to average every 3 consecutive time steps, resulting in evenly-spaced 3-month means.
   - This process is applied to the 2D temperature (T), 3D temperature (T), U-velocity, and V-velocity fields.

The output files are saved in the `resampled` directory.

## Summary of Data Processing

### Input Data
The initial data consists of the following files:
- `DINO_10d_grid_inst_T_3D.nc` (7.0G)
- `DINO_10d_grid_inst_U_3D.nc` (7.0G)
- `DINO_10d_grid_inst_V_3D.nc` (7.0G)
- `DINO_1m_grid_T_2D.nc` (179M)
- `DINO_35524800_restart.nc` (459M)
- `DINO_35654400_restart.nc` (459M)
- `DINO_3m_grid_U_3D.nc` (1.1G)
- `DINO_3m_grid_V_3D.nc` (1.1G)
- `DINO_3m_grid_W_3D.nc` (532M)

### Output Data
After running the `resample.sh` script, the following files are generated in the `resampled` directory:
- `DINO_10d_grid_inst_T_3D.nc` (7.0G)
- `DINO_10d_grid_inst_U_3D.nc` (7.0G)
- `DINO_10d_grid_inst_V_3D.nc` (7.0G)
- `DINO_1m_grid_T_2D.nc` (179M)
- `DINO_1m_grid_T_3D.nc` (2.4G)
- `DINO_1m_grid_U_3D.nc` (2.4G)
- `DINO_1m_grid_V_3D.nc` (2.4G)
- `DINO_35524800_restart.nc` (459M)
- `DINO_35654400_restart.nc` (459M)
- `DINO_3m_grid_T_2D.nc` (61M)
- `DINO_3m_grid_T_3D.nc` (798M)
- `DINO_3m_grid_U_3D.nc` (1.1G)
- `DINO_3m_grid_V_3D.nc` (1.1G)
- `DINO_3m_grid_W_3D.nc` (532M)

### Note on Temporal Cadence
The resampling process only goes from high-frequency to low-frequency (never the other way around). This means that we start with high-frequency data (e.g., 10-day instantaneous snapshots) and resample it to lower-frequency data (e.g., 1-month or 3-month means). This approach ensures that we do not introduce artifacts or errors that could arise from upsampling or interpolating data.

### Note on Data Location
All data, including the `mesh_mask.nc` file, is assumed to be in the `resampled` directory. The evaluation scripts and configuration files are designed to work with this assumption. If the `mesh_mask.nc` file is located elsewhere, the paths in the configuration files should be updated accordingly.

## Expected Warnings and Errors

When running the evaluation script, you may encounter the following warnings and errors:

### SerializationWarning
```
SerializationWarning: Unable to decode time axis into full numpy.datetime64[ns] objects, continuing using cftime.datetime objects instead, reason: dates out of range. To silence this warning use a coarser resolution 'time_unit' or specify 'use_cftime=True'.
```

This warning is expected and can be safely ignored. It occurs because the dates in the data are out of the range that can be represented by `numpy.datetime64[ns]` objects. This is a common issue when dealing with future dates (e.g., year 3000+).

### UserWarning for Missing Variables
```
UserWarning: Error in metric check_density_from_file: 'density'
```

This error occurs because the `density` variable is not present in the data files. Since the data does not include this variable, the metrics that depend on it will fail. This is expected and not a cause for concern.

## Automatic resampling 

This is still a WIP. See [#PR64](https://github.com/m2lines/nemo-spinup-evaluation/pull/64).
