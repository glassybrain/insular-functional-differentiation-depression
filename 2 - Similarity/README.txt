2 - Similarity
==============

The code in this folder calculates the similarity of the subregional FC profiles for every
participant, as described in the sections 'Calculation of resting state functional connectivity'
and 'Similarity calculations' of the Methods (Figure 1C).

Calculate_Similarity_Insula_Subregions.m
    1. Averages the left and right seed-to-voxel z-maps (output of '1 - Functional connectivity')
       to obtain bilateral FC maps of the 6 insular subregions.
    2. Keeps the participants who passed quality control (FC.qQC, see '0 - Preprocessing') and
       regresses the FC maps voxel-wise on site, age, sex and motion (mean framewise
       displacement). The residualised maps (Bilateral_*_regress.nii/.mat) are also the input
       of '5 - Shift function' and '6 - SVM'.
    3. Averages the residualised maps across all participants (sample FC map per subregion) and
       correlates (Pearson) every participant's FC map of each subregion with each of the six
       sample FC maps. Correlations are Fisher z-transformed.
    4. Writes the results to the long-format table T_insula (see below).

Calculate_Similarity_Temporal_Subregions.m
    Same procedure for the 6 temporal cortex subregions (control region); writes T_temporal.

Output (provided in the 'output' folder)
----------------------------------------
T_insula.csv / T_temporal.csv
    One row per participant and subregion pair (850 participants x 36 pairs = 30600 rows):
    Subj_ID   participant ID
    Sub_A     subregion of the participant's FC map
    Sub_B     subregion of the sample (mean) FC map
    within    1 = same subregion (Sub_A = Sub_B), 0 = different subregions
    atanh     similarity (Fisher z-transformed Pearson r)
    Group     0 = HCP, 1 = MDD
    region    similarity type: 0 = between, 1 = anterior-within, 2 = posterior-within
    Subregion codes insula:   1 = AI short, 2 = AI long, 3 = AI pole, 4 = MI short,
                              5 = PI short, 6 = PI long
    Subregion codes temporal: 1 = TL medial (AT medial), 2 = TL lateral (AT lateral),
                              3 = STG middle (ST middle), 4 = ITG middle (MIT),
                              5 = TL posterior (PT), 6 = STGa (aSTG)


These tables are the input of the analyses in '4 - Subregion analysis'.

Data availability
-----------------
As we can only share summary data and the similarity values are calculated from individual-level
FC maps (output of '1 - Functional connectivity'), the scripts can be reviewed but cannot be run
independently. The intermediate outputs of the scripts (bilateral and residualised individual FC
maps) cannot be shared either. The resulting similarity values per participant and subregion
pair are provided in the 'output' folder.

Usage
-----
Every script starts with a 'USER SETTINGS' section. Adjust the paths in this section to the
locations of the input files and output folders on your system before running a script. Note
that T_insula.csv / T_temporal.csv are written to the current working directory.

Requirements: MATLAB (Statistics and Machine Learning Toolbox), NIfTI toolbox.
