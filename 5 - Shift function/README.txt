5 - Shift function
==================

The code in this folder generates the shift function results reported in the section
'Connectivity profiles of insular subregions are less differentiated in depression which is
driven by the anterior insula'. The analysis is described in the section 'Shift function' of the Methods.

The scripts are listed in the order in which they are run:

shift_prep_insula.m / shift_prep_temporal.m
    Split the residualised FC maps of every subregion (output of '2 - Similarity') by group and
    average them across participants within each group. The group-mean FC values of all grey
    matter voxels are saved as one vector per group and subregion (hc_Bilateral_*.csv/.mat and
    mdd_Bilateral_*.csv/.mat). These vectors represent the FC density distributions of each
    group. The .mat files are written to the output folder set in the script, the .csv files to
    the current working directory.

Run_shift_function_insula.R / Run_shift_function_temporal.R
    Compare the FC density distributions of HCP and MDD for each subregion decile-wise using the
    shift function (R package rogme, shifthd_pbci; 1000 bootstrap samples). Results are saved as
    out_<subregion>.RData in the current working directory.

Convert_decile_stats_to_t.R
    Converts the bootstrapped decile differences and confidence intervals of the shift function
    into T values and Cohen's d and writes one table per subregion (<subregion>.csv; Table S2)
    into the folder of the respective .RData files.

Plot_insula_FC_distributions.R / Plot_temporal_FC_distributions.R
    Plot the FC density distributions of HCP and MDD for each subregion (Figures 3B-C, Figures S4 and S5).

Data provided in this folder
----------------------------
shift_prep/              group-mean FC vectors of the insular subregions (hc_/mdd_Bilateral_*)
shift_prep/temporal/     group-mean FC vectors of the temporal subregions
output/insula/           shift function results of the insular subregions (out_*.RData)
output/temporal/         shift function results of the temporal subregions (out_*.RData)

Data availability
-----------------
The MATLAB scripts shift_prep_insula.m and shift_prep_temporal.m start from the individual-level
residualised FC maps (output of '2 - Similarity'). As we can only share summary data, these
scripts can be reviewed but cannot be run independently. Their output (group-level mean FC per
voxel for each group and subregion) is provided in the 'shift_prep' folder, so all R scripts can
be run with the data in this folder.

Usage
-----
Every script starts with a 'USER SETTINGS' section. Adjust the paths in this section to your
system before running a script:
- Run_shift_function_insula.R and Plot_insula_FC_distributions.R: set the input folder to
  'shift_prep'.
- Run_shift_function_temporal.R and Plot_temporal_FC_distributions.R: set the input folder to
  'shift_prep/temporal'.
- Convert_decile_stats_to_t.R: set the two folders to 'output/insula' and 'output/temporal'
  (or to wherever you saved the .RData files produced by the Run_shift_function scripts).
Note that the Run_shift_function scripts save their output to the current working directory
(use setwd() to choose the folder) and that the Run_shift_function and plotting scripts install
the package rogme from GitHub (devtools::install_github("GRousselet/rogme")).

Requirements: MATLAB, NIfTI toolbox; R with the packages readr, rogme, devtools, ggplot2,
cowplot, tibble, gridExtra, ggpubr, tidyr and tidyverse.
