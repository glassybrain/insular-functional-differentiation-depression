6 - SVM
=======

The code in this folder generates the results reported in the section 'Similarity between
connectivity profiles of insular subregions predicts individual group label with accuracy scaled
by symptom severity'.

The Matlab script svm_prep.m generates the data structure SVM_data.mat which contains
z-transformed individual AIC-PIC similarity values. As we can only share summary data and this
data structure is calculated from individual-level functional connectivity data, the script can
be reviewed but cannot be run independently.

For the Matlab script Run_SVM_BDI_with_permutation.m which runs the classification as described
in the 'Classification' section of the methods in the paper, the relevant input data is provided
in the data folder. Make sure to adjust the 'USER SETTINGS' section of the script. Note that 
average_auc_perm_median.csv is written to the current working directory.

The Matlab script Count_N_per_BDI_threshold.m displays the number of MDD participants retained
at each BDI inclusion threshold (Table S1 in the Supplementary Information). It uses the
variables FC and SVM_data_mdd, so run the first section of Run_SVM_BDI_with_permutation.m
(loading the data and separating MDD and HCP) before running this script.

The associated figure in the results section (Figure 4) can be generated using the R script
plot_perm_svm.R which needs the average_auc_perm_median.csv and slope_perm_median.csv as input
(generated from Run_SVM_BDI_with_permutation.m). Again, make sure to set the data.folder (location
of the two csv files) and the results.folder (where the figures are saved) correctly for your
system.

Data provided in this folder
----------------------------
data/      input of Run_SVM_BDI_with_permutation.m: SVM_data.mat/.csv (group label and the 9
           AIC-PIC similarity predictors per participant) and MDD_BDI_Cov.mat (BDI scores of
           the MDD group)
output/    results of Run_SVM_BDI_with_permutation.m (median AUCs, permutation results,
           slopes and p-values) and the output of svm_prep.m (SVM_data.mat/.csv)
plots/     panels of Figure 4 generated with plot_perm_svm.R

Requirements: MATLAB (Statistics and Machine Learning Toolbox); R with the packages ggplot2,
tidyr, ggpubr and cowplot.
