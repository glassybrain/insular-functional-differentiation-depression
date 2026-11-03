4 - Subregion analysis
======================

The code in this folder generates the results reported in the section 'Connectivity profiles of
insular subregions are less differentiated in depression which is driven by the anterior insula'
and the related analyses in the Supplementary Information. The analysis is described in the section 
'Linear mixed effects analysis of the similarity estimates' of the Methods.

LME_group_similarity_type_HC_MDD.m
    Runs the linear mixed-effects models (MATLAB: fitlme) predicting similarity from Group
    (HCP, MDD), Similarity type (between, anterior-within, posterior-within) and their
    interaction, with a random intercept and random slopes for Group and Similarity type per
    participant, for the insula and the temporal cortex. Fixed effects are reported with
    Satterthwaite degrees of freedom.
    Output: lm_insula_region.mat, lm_temporal_region.mat (fitted models) and insula_region.mat,
    temporal_region.mat (fixed-effects tables).

LME_run_emmeans_comparisons_anterior_posterior.R
    Refits the same Group x Similarity type model in R (lme4/lmerTest) for the insula and the
    temporal cortex and statistically compares the Group x Similarity type interactions between
    anterior and posterior subregions: based on the estimated marginal means (R package
    'emmeans'), it calculates the interaction contrasts (HCP - MDD) x (anterior-within -
    between) and (HCP - MDD) x (posterior-within - between) and compares them with each other
    (contrast of contrasts).

Plot_similarity_Subregions-Figure3A.R
    Plots the delta similarity (anterior-within - between and posterior-within - between) for
    HCP and MDD in the insula and the temporal cortex (Figure 3A; plot p3). The script also
    creates the plots for Figure S2 (p1: within vs. between similarity, p2: delta similarity
    within - between).

Comorbidities_and_medication_effects.R
    1. Counts the comorbid diagnoses in the MDD group (Table 1).
    2. Sensitivity analysis comparing HCP, MDD without and MDD with comorbid anxiety disorder.
    3. Adds medication information to the similarity tables (creates T_insula_medication.csv and
       T_temporal_medication.csv as outputs) and runs the medication
       sensitivity analysis, i.e. the Group x Similarity type models extended by Similarity type
       x antidepressant (SNRI, SSRI, NaSSA, tricyclic antidepressants) interactions (section
       'Sensitivity analysis on medication effects' in the Supplementary Information).

    T_insula_medication.csv / T_temporal_medication.csv
    T_insula/T_temporal tables with additional columns for medication (SNRI, Antipsychotic, SSRI, NaSSA, 
    TZA (tricyclic antidepressants), Lithium; 0 = no, 1 = yes).

SI/LME_group_within_between_HC_MDD.m
    Runs the linear mixed-effects models with the two-level Similarity type (within, between)
    reported in the Supplementary Information (section 'Predicting Similarity by Group x
    Similarity type (within vs. between)', Figure S2).
    Output: lm_insula_within.mat, lm_temporal_within.mat, insula_within.mat,
    temporal_within.mat; provided in the 'SI' folder.

Data availability
-----------------
The input data for LME_group_similarity_type_HC_MDD.m, SI/LME_group_within_between_HC_MDD.m,
LME_run_emmeans_comparisons_anterior_posterior.R and Plot_similarity_Subregions-Figure3A.R
(T_insula.csv and T_temporal.csv) are provided in
'2 - Similarity/output', so these scripts can be run independently.

Comorbidities_and_medication_effects.R additionally requires the individual-level clinical
covariates of the FOR2107 sample (diagnoses and medication; Covariates_14-05-2018.csv). These files 
cannot be shared and the comorbidity analyses can be reviewed but cannot be run independently. 
The similarity tables including the medication columns are provided as an output, so the medication 
models can be reproduced by reading these files instead of merging the covariates.

Usage
-----
Every script starts with a 'USER SETTINGS' section. Adjust the paths in this section to your
system before running a script: set the folder containing T_insula.csv and T_temporal.csv to the
location of '2 - Similarity/output' and the output/results folder to where the models or figures
should be saved. Plot_similarity_Subregions-Figure3A.R uses the data folder as working directory
and saves intermediate model estimates (x.RData, x_temporal.RData) there.

Requirements: MATLAB (Statistics and Machine Learning Toolbox); R with the packages lme4,
lmerTest, emmeans, tidyverse, sjstats, merTools, carData, effects, dplyr, plyr, ggplot2, cowplot
and viridis.
