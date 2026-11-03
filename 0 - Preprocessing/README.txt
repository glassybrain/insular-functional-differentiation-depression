0 - Preprocessing
=================

The code in this folder preprocesses the resting-state fMRI data and creates the quality-control
(QC) vector that defines the final sample (N = 850; NMDD = 433, NHCP = 417). The procedures are
described in the section 'Participants' of the Methods and in the section 'Preprocessing' of the
Supplementary Information (see also Figure S1).

The scripts are numbered in the order in which they were run:

1 - conn_preprocess_FOR2107data.m
    Preprocesses and denoises the functional and structural images of each participant with the
    default pipeline of the CONN toolbox (v18a): realignment & unwarping, slice-timing
    correction, outlier detection, segmentation and normalisation to MNI space (2 mm isotropic)
    and denoising (aCompCor for white matter and CSF, realignment parameters and their
    derivatives, scrubbing, band-pass filter 0.01-0.1 Hz, linear detrending). The denoised data
    are exported to NIfTI.

2 - smooth_functional_images.m
    Smooths the preprocessed functional images with a 6 mm FWHM isotropic Gaussian kernel.

3 - Calculate_whole_brain_ROI_to_ROI_Conn.m
    Calculates ROI-to-ROI connectivity (Pearson correlation of the mean ROI time series) for every
    participant using the extended Harvard-Oxford atlas and saves them as
    Whole_brain_ROI_Conn_sorted.mat. These matrices are only used for quality control in
    script 4.

4 - Create_covariates_for_exclusion.m
    Matches imaging and covariate data, calculates each participant's whole-brain mean
    z-transformed connectivity and creates FC.mat. FC.mat contains the covariates (group, age,
    sex, site, body coil), the subject IDs and the QC vector FC.qQC, which marks participants
    with a mean connectivity < 0.2 who were not scanned with the body coil. FC.mat is used by
    most scripts in the following folders.

Files
-----------------------------
FC.mat
    Output of 4 - Create_covariates_for_exclusion.m (see above).
The following files were created before running the scripts and are used as input by scripts
in several folders:
FD_HM.xlsx
    Summary of the head motion parameters per participant (translation, rotation and framewise
    displacement); Mean framewise displacement (meanFD_Power) per participant, used as motion covariate
    (script 4 in this folder, '2 - Similarity' and '3 - AIC_PIC_Analysis').
GM_voxel_coordinates.mat
    Voxel coordinates of the grey matter mask (input of '1 - Functional connectivity').
subject_ID_sort_idx.mat
    Index used to sort the participants by subject ID (input of '1 - Functional connectivity'
    and '3 - AIC_PIC_Analysis').

Data availability
-----------------
As we can only share summary data, the input data of these scripts (raw and preprocessed
individual MRI images and the individual covariate table) cannot be shared. The scripts
can therefore be reviewed but cannot be run independently. The FOR2107 dataset is available on
request from the consortium (see 'Data availability' in the paper).

Usage
-----
Every script starts with a 'USER SETTINGS' section. Adjust the paths in this section to the
locations of the respective input files and output folders on your system before running a
script. The comment next to each path explains which file or folder is expected.

Requirements: MATLAB, SPM12, CONN toolbox v18a, NIfTI toolbox (load_untouch_nii).
