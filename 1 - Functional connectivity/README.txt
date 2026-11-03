1 - Functional connectivity
===========================

The code in this folder calculates the seed-to-voxel functional connectivity (FC) maps of the
insular (region of interest) and temporal (control region) subregions, as described in the
sections 'Definition of regions of interest (ROI)' and 'Calculation of resting state functional
connectivity' of the Methods.

Calculate_Seed_to_Voxel_Connectivity_Insula.m
    Defines the 12 unilateral insular subregions (left/right AI short, AI long, AI pole,
    MI short, PI short, PI long) based on the Hammers atlas. For every participant, the mean time
    series of each subregion is correlated (Pearson) with the time series of every voxel within
    the grey matter mask. The r maps are Fisher z-transformed, sorted by subject ID and saved as
    one 4D NIfTI file per subregion (one volume per participant;
    *_voxel_connectivity_zmap_sorted.nii).

Calculate_Seed_to_Voxel_Connectivity_Temporal.m
    Same procedure for the 12 unilateral temporal cortex subregions (left/right anterior
    temporal lobe medial and lateral part, superior temporal gyrus anterior and middle part,
    middle and inferior temporal gyrus, posterior temporal lobe).

The resulting z-maps are the input of the scripts in '2 - Similarity' and '3 - AIC_PIC_Analysis'.

Data availability
-----------------
As we can only share summary data, neither the input data (preprocessed individual functional
images, output of '0 - Preprocessing') nor the output data (individual FC maps) of these scripts
can be shared. The scripts can therefore be reviewed but cannot be run independently.
The other inputs of these scripts are provided in the preprocessing folder: the grey matter mask
coordinates (GM_voxel_coordinates.mat) and the subject sorting index
(subject_ID_sort_idx.mat).

Usage
-----
Every script starts with a 'USER SETTINGS' section. Adjust the paths in this section to the
locations of the functional images, the grey matter mask coordinates, the Hammers atlas (and its
labels), the subject sorting index and the output folder on your system before running a script.

Requirements: MATLAB (Statistics and Machine Learning Toolbox), NIfTI toolbox
(load_untouch_nii / save_untouch_nii).
