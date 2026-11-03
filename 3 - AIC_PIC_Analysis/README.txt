3 - AIC_PIC_Analysis
====================

The code in this folder generates the results reported in the section 'Depression modulates
functional connectivity profiles of insular subregions' (Figure 2).

Full_factorial_model_group_subregions_sample_850_with_regress_SPM25.m
    1. Averages the bilateral FC maps of the three anterior (AI short, AI pole, MI short) and
       the three posterior insular subregions (AI long, PI short, PI long) to obtain one AIC and
       one PIC FC map per participant (input: individual z-maps from
       '1 - Functional connectivity').
    2. Selects the participants who passed quality control, splits the maps by group and
       regresses them on age, sex, site and motion (mean framewise displacement).
    3. Calculates the within-participant similarity of the AIC and PIC FC maps (Pearson r,
       Fisher z-transformed), compares it between groups and writes
       Similarity_AIC_PIC_Groups.csv (Figure 2D).
    4. Runs the full factorial model in SPM25 with the factors Group (HCP, MDD) and Subregion
       (AIC, PIC) and estimates the contrasts for the main effects and the interaction
       Group x Subregion (Figure 2A-B).
    5. Extracts the voxel-wise T values of the main effect of Subregion (spmT_0007.nii) and of
       the interaction Group x Subregion (spmT_0008.nii) within the model mask and writes them
       to factorial_model_FC_main_effect_vectorized.csv and
       factorial_model_FC_interaction_effect_vectorized.csv (input for Figure 2C).

Plot_Similarity_profiles.R
    Compares the AIC-PIC similarity between HCP and MDD with a standard t-test and a robust
    Yuen-Welch test (10% trimming) including the robust effect size, and plots Figure 2D.
    Input: Similarity_AIC_PIC_Groups.csv

Plot_factorial_model_main_interaction.R
    Plots the voxel-wise T values of the main effect of Subregion against the T values of the
    interaction effect Group x Subregion (Figure 2C).
    Input: factorial_model_FC_main_effect_vectorized.csv and
    factorial_model_FC_interaction_effect_vectorized.csv

Data provided in this folder
----------------------------
Similarity_AIC_PIC_Groups.csv
    Within-participant AIC-PIC similarity (z-transformed r) per participant
    (Group: 0 = HCP, 1 = MDD).
SPM full factorial model group subregion/
    Group-level output of the full factorial model (SPM.mat, beta, contrast, T and F maps).
    The full statistical maps are also available on NeuroVault
    (https://neurovault.org/collections/YUXNEZAU/).
factorial_model_FC_main_effect_vectorized.csv / factorial_model_FC_interaction_effect_vectorized.csv
    The voxel-wise T values of these two maps within the model mask (one value per voxel;
    created in step 5 of the full factorial script), used as input for
    Plot_factorial_model_main_interaction.R.

Data availability
-----------------
As we can only share summary data and the MATLAB scripts start from individual-level FC maps
(output of '1 - Functional connectivity'), the MATLAB scripts can be reviewed but cannot be run
independently. Their group-level and summary outputs listed above are provided, so the R scripts
can be run with the data in this folder. The last section of the full factorial script
('Extract vectorized main effect and interaction effect for Figure 2C') only needs the SPM
output and can be run on its own by setting spm_model_folder to
'SPM full factorial model group subregion' in this folder.

Usage
-----
Every script starts with a 'USER SETTINGS' section. Adjust the paths in this section to your
system before running a script. For the R scripts, set the input file/folder to the location of
this folder and the results folder to where the figures should be saved.

Requirements: MATLAB (Statistics and Machine Learning Toolbox), SPM25, NIfTI toolbox;
R with the packages tidyverse, gghalves, cowplot, WRS2 and effectsize.
