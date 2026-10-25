Reduced functional differentiation of insular connectivity profiles in depression
================================================================================

This repository contains the analysis code for the paper:

    Teckentrup V*, Neubert S*, Kircher T, Stein F, Thomas-Odenthal F, Usemann P, Teutenberg L,
    Nenadić I, Straube B, Alexander N, Jamalabadi H, Jansen A, Krug A, Grotegerd D,
    Flinkenflügel K, Borgers T, Meinert S, Leehr EJ, Hahn T, Dannlowski U, Li M, Walter M*,
    Kroemer NB*. Reduced functional differentiation of insular connectivity profiles in
    depression. 
    (* shared contribution)


The study used resting-state fMRI data from the Marburg-Münster FOR2107 Affective Disorder
Cohort (N = 850; 433 patients with major depressive disorder (MDD), 417 healthy control
participants (HCP)). It tests whether the functional connectivity (FC) profiles of anterior and
posterior insular subregions are less differentiated in MDD, using the temporal cortex as a
control region.


Structure
---------
The folders are numbered in the order of the analysis pipeline. Each folder contains a
README.txt that describes the scripts, their inputs and outputs, and which data are included.

0 - Preprocessing              preprocessing, denoising and smoothing of the fMRI data; quality
                               control and covariates
1 - Functional connectivity    seed-to-voxel FC maps of the insular and temporal subregions
2 - Similarity                 similarity of the subregional FC profiles per participant
3 - AIC_PIC_Analysis           full factorial model Group x Subregion (AIC, PIC); AIC-PIC
                               similarity (Figure 2)
4 - Subregion analysis         linear mixed-effects models of similarity type x group,
                               sensitivity analyses (Figure 3A, Figure S2)
5 - Shift function             FC density distributions and shift function (Figure 3B-C,
                               Table S2, Figures S4-S5)
6 - SVM                        classification of group based on AIC-PIC similarity (Figure 4,
                               Table S1)



Data availability
-----------------
The FOR2107 dataset is not publicly accessible. Researchers may apply for access to the raw
data by contacting the spokespersons of the consortium (Prof. Tilo Kircher, Prof. Udo
Dannlowski; info@for2107.de). Full-brain images and other subject-level brain data cannot be
shared. Summary data (e.g. similarity values per subregion combination and participant, and
group-level statistical maps) are included. Scripts whose input cannot be shared
can be reviewed but not run independently. This is noted in the README of each folder. 


Usage
-----
Every script starts with a 'USER SETTINGS' section. Set the paths in this section to the
locations of the input files and output folders on your system before running a script.

Software: MATLAB (Statistics and Machine Learning Toolbox), SPM12 and SPM25, CONN toolbox v18a,
NIfTI toolbox; R with the packages listed in the README of each folder.


Note on authorship of the code and documentation
------------------------------------------------
All analysis code was written by the authors. To add the README files, extend header comments 
and replace the hard-coded file paths by variables in the header section, Claude Opus 5.5 was 
used, with every README file and header section reviewed by the authors.