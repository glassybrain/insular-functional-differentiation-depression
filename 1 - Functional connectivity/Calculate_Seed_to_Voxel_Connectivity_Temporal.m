%%% Seed to Voxel Connectivity %%%
%%% Extract voxel timeseries from mask generated from intersect between the
%%% SPM grey matter tissue probability map and the Hammers atlas
%%% Connectivity is calculated with seed ROIs in the temporal cortex
%%% For each participant, the mean time series of each of the 12 unilateral temporal cortex subregions
%%% (Hammers atlas) is correlated (Pearson) with the time series of every voxel in the
%%% grey matter mask. The resulting r maps are Fisher z-transformed, sorted by subject ID
%%% and saved as one 4D NIfTI file per seed ROI (one volume per participant).
%%% See 'Calculation of resting state functional connectivity' in the Methods.
%%% Requires: MATLAB, NIfTI toolbox (load_untouch_nii / save_untouch_nii)

clear all
clc

%% USER SETTINGS: adjust the paths below to your local system
% Set up folders
FunImgFolder = ('/path/to/preprocessed_smoothed');   % smoothed functional images (one 4D NIfTI per participant)
Voxel_Conn_data_folder = '/path/to/PsyMRI_Temporal_Analysis';   % output folder for the seed-to-voxel z-maps
GM_coordinates_file = '/path/to/GM_voxel_coordinates.mat';   % voxel coordinates of the grey matter mask
hammers_atlas_file = '/path/to/resliced_Hammers-n30r95-maxprob-gm-MNI152.nii';   % Hammers atlas resliced to the functional images
hammers_labels_file = '/path/to/Hammers_Labels.mat';   % labels of the Hammers atlas
sort_idx_file = '/path/to/subject_ID_sort_idx.mat';   % index used to sort participants by subject ID (subjects_IDs_sort_idx)

% Load voxel coordinates for grey matter mask
load(GM_coordinates_file)


% Load Hammers atlas
hammers_temporal = load_untouch_nii(hammers_atlas_file);
hammers_temporal = hammers_temporal.img;
% Load atlas labels
load(hammers_labels_file)
Hammers_Labels = cellstr(Hammers_Labels);


% Get index of ROIs
lAT_medial_idx = find(strcmp(Hammers_Labels,'TL anterior temporal lobe medial part L'));
rAT_medial_idx = find(strcmp(Hammers_Labels,'TL anterior temporal lobe medial part R'));

lAT_lateral_idx = find(strcmp(Hammers_Labels,'TL anterior temporal lobe lateral part L'));
rAT_lateral_idx = find(strcmp(Hammers_Labels,'TL anterior temporal lobe lateral part R'));

lST_middle_idx = find(strcmp(Hammers_Labels,'TL superior temporal gyrus middle part L'));
rST_middle_idx = find(strcmp(Hammers_Labels,'TL superior temporal gyrus middle part R'));

lMIT_idx = find(strcmp(Hammers_Labels,'TL middle and inferior temporal gyrus L'));
rMIT_idx = find(strcmp(Hammers_Labels,'TL middle and inferior temporal gyrus R'));

lPT_idx = find(strcmp(Hammers_Labels, 'TL posterior temporal lobe L'));
rPT_idx = find(strcmp(Hammers_Labels, 'TL posterior temporal lobe R'));

laSTG_idx = find(strcmp(Hammers_Labels,'TL superior temporal gyrus anterior part L'));
raSTG_idx = find(strcmp(Hammers_Labels,'TL superior temporal gyrus anterior part R'));

clear lACC_idx lAT_medial_idx r

%Create the respective logical masks
lAT_medial_mask = single(zeros(91,109,91));
lAT_medial_mask(hammers_temporal == lAT_medial_idx) = 1;
lAT_medial_mask = logical(lAT_medial_mask);

rAT_medial_mask = single(zeros(91,109,91));
rAT_medial_mask(hammers_temporal == rAT_medial_idx) = 1;
rAT_medial_mask = logical(rAT_medial_mask);

lAT_lateral_mask = single(zeros(91,109,91));
lAT_lateral_mask(hammers_temporal == lAT_lateral_idx) = 1;
lAT_lateral_mask = logical(lAT_lateral_mask);

rAT_lateral_mask = single(zeros(91,109,91));
rAT_lateral_mask(hammers_temporal == rAT_lateral_idx) = 1;
rAT_lateral_mask = logical(rAT_lateral_mask);

lST_middle_mask = single(zeros(91,109,91));
lST_middle_mask(hammers_temporal == lST_middle_idx) = 1;
lST_middle_mask = logical(lST_middle_mask);

rST_middle_mask = single(zeros(91,109,91));
rST_middle_mask(hammers_temporal == rST_middle_idx) = 1;
rST_middle_mask = logical(rST_middle_mask);

lMIT_mask = single(zeros(91,109,91));
lMIT_mask(hammers_temporal == lMIT_idx) = 1;
lMIT_mask = logical(lMIT_mask);

rMIT_mask = single(zeros(91,109,91));
rMIT_mask(hammers_temporal == rMIT_idx) = 1;
rMIT_mask = logical(rMIT_mask);

lPT_mask = single(zeros(91,109,91));
lPT_mask(hammers_temporal == lPT_idx) = 1;
lPT_mask = logical(lPT_mask);

rPT_mask = single(zeros(91,109,91));
rPT_mask(hammers_temporal == rPT_idx) = 1;
rPT_mask = logical(rPT_mask);

laSTG_mask = single(zeros(91,109,91));
laSTG_mask(hammers_temporal == laSTG_idx) = 1;
laSTG_mask = logical(laSTG_mask);

raSTG_mask = single(zeros(91,109,91));
raSTG_mask(hammers_temporal == raSTG_idx) = 1;
raSTG_mask = logical(raSTG_mask);

% Prepare list of subjects
subjects = dir(FunImgFolder);
subjects = subjects(arrayfun(@(x) x.name(1), subjects) ~= '.');

% Generate target structures
lAT_medial_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
rAT_medial_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
lAT_lateral_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
rAT_lateral_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
lST_middle_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
rST_middle_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
lMIT_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
rMIT_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
lPT_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
rPT_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
laSTG_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));
raSTG_Voxel_connectivity = single(NaN(size(hammers_temporal,1), size(hammers_temporal,2), size(hammers_temporal,3),length(subjects)));


for subjnumb = 1:length(subjects)
    
    disp('---------------------------------------')
    disp(' ')
    disp(['Constructing seed to Voxel connectivity for subject ' num2str(subjnumb) ' of ' num2str(length(subjects))])
    disp(' ')
    disp('---------------------------------------') 
    
    subj = subjects(subjnumb).name;
    subj_ID = subj(1:end-4);
    
       
    % Load 4D Nifti containing activity    
    % Get Nifti header from first subject for saving images
    if subjnumb == 1
        
        functional_image = load_untouch_nii([FunImgFolder filesep subj]);
        nii_template = functional_image;
        nii_template.img = [];
        nii_template = rmfield(nii_template,'fileprefix');
        nii_template.hdr.dime.dim(5) = length(subjects);
        functional_image = functional_image.img;
        
    else
        
        functional_image = load_untouch_nii([FunImgFolder filesep subj]);
        functional_image = functional_image.img;
        functional_image(functional_image == 0) = NaN;
        
    end
    
    % Extract the seed ROI timeseries
    for timepoints = 1:size(functional_image,4)

        image_subset = functional_image(:,:,:,timepoints);
        
        % Temporal
        lAT_medial_subset_ROI_timeseries = image_subset(lAT_medial_mask);
        rAT_medial_subset_ROI_timeseries = image_subset(rAT_medial_mask);
        lAT_lateral_subset_ROI_timeseries = image_subset(lAT_lateral_mask);
        rAT_lateral_subset_ROI_timeseries = image_subset(rAT_lateral_mask);
        lST_middle_subset_ROI_timeseries = image_subset(lST_middle_mask);
        rST_middle_subset_ROI_timeseries = image_subset(rST_middle_mask);
        lMIT_subset_ROI_timeseries = image_subset(lMIT_mask);
        rMIT_subset_ROI_timeseries = image_subset(rMIT_mask);
        lPT_subset_ROI_timeseries = image_subset(lPT_mask);
        rPT_subset_ROI_timeseries = image_subset(rPT_mask);
        laSTG_subset_ROI_timeseries = image_subset(laSTG_mask);
        raSTG_subset_ROI_timeseries = image_subset(raSTG_mask);
        
        lAT_medial_timeseries(1,timepoints) = mean(lAT_medial_subset_ROI_timeseries);
        rAT_medial_timeseries(1,timepoints) = mean(rAT_medial_subset_ROI_timeseries);
        lAT_lateral_timeseries(1,timepoints) = mean(lAT_lateral_subset_ROI_timeseries);
        rAT_lateral_timeseries(1,timepoints) = mean(rAT_lateral_subset_ROI_timeseries);
        lST_middle_timeseries(1,timepoints) = mean(lST_middle_subset_ROI_timeseries);
        rST_middle_timeseries(1,timepoints) = mean(rST_middle_subset_ROI_timeseries);
        lMIT_timeseries(1,timepoints) = mean(lMIT_subset_ROI_timeseries);
        rMIT_timeseries(1,timepoints) = mean(rMIT_subset_ROI_timeseries);
        lPT_timeseries(1,timepoints) = mean(lPT_subset_ROI_timeseries);
        rPT_timeseries(1,timepoints) = mean(rPT_subset_ROI_timeseries);
        laSTG_timeseries(1,timepoints) = mean(laSTG_subset_ROI_timeseries);
        raSTG_timeseries(1,timepoints) = mean(raSTG_subset_ROI_timeseries);

    end
    
    % Calculate seed ROI to Voxel Connectivity
    for voxels = 1:length(GM_voxel_coordinates)
    
        voxel_timeseries = squeeze(functional_image(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),:));
        
        % Temporal
        lAT_medial_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lAT_medial_timeseries',voxel_timeseries);
        rAT_medial_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rAT_medial_timeseries',voxel_timeseries);
        lAT_lateral_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lAT_lateral_timeseries',voxel_timeseries);
        rAT_lateral_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rAT_lateral_timeseries',voxel_timeseries);
        lST_middle_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lST_middle_timeseries',voxel_timeseries);
        rST_middle_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rST_middle_timeseries',voxel_timeseries);
        lMIT_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lMIT_timeseries',voxel_timeseries);
        rMIT_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rMIT_timeseries',voxel_timeseries);
        lPT_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lPT_timeseries',voxel_timeseries);
        rPT_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rPT_timeseries',voxel_timeseries);
        laSTG_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(laSTG_timeseries',voxel_timeseries);
        raSTG_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(raSTG_timeseries',voxel_timeseries);
        
        clear voxel_timeseries
        
    end
    
end

% Delete everything unnecessary from RAM to free up space
clearvars -except sort_idx_file Voxel_Conn_data_folder nii_template lAT_medial_Voxel_connectivity rAT_medial_Voxel_connectivity lAT_lateral_Voxel_connectivity rAT_lateral_Voxel_connectivity lST_middle_Voxel_connectivity rST_middle_Voxel_connectivity lMIT_Voxel_connectivity rMIT_Voxel_connectivity lTP_Voxel_connectivity rTP_Voxel_connectivity laSTG_Voxel_connectivity raSTG_Voxel_connectivity

% z-transform r maps, reorder subjects and write out sorted zmaps
load(sort_idx_file)

% Temporal
lAT_medial_Voxel_conn_zmap = atanh(lAT_medial_Voxel_connectivity);
lAT_medial_Voxel_connectivity_zmap_sorted = lAT_medial_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lAT_medial_Voxel_conn_zmap_sorted_nii = nii_template;

lAT_medial_Voxel_conn_zmap_sorted_nii.img = lAT_medial_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lAT_medial_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lAT_medial_voxel_connectivity_zmap_sorted.nii'])

clear lAT_medial_Voxel_conn_zmap lAT_medial_Voxel_conn_zmap_sorted_nii lAT_medial_Voxel_connectivity

rAT_medial_Voxel_conn_zmap = atanh(rAT_medial_Voxel_connectivity);
rAT_medial_Voxel_connectivity_zmap_sorted = rAT_medial_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rAT_medial_Voxel_conn_zmap_sorted_nii = nii_template;
rAT_medial_Voxel_conn_zmap_sorted_nii.img = rAT_medial_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rAT_medial_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rAT_medial_voxel_connectivity_zmap_sorted.nii'])

clear rAT_medial_Voxel_conn_zmap rAT_medial_Voxel_conn_zmap_sorted_nii rAT_medial_Voxel_connectivity

lAT_lateral_Voxel_conn_zmap = atanh(lAT_lateral_Voxel_connectivity);
lAT_lateral_Voxel_connectivity_zmap_sorted = lAT_lateral_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lAT_lateral_Voxel_conn_zmap_sorted_nii = nii_template;
lAT_lateral_Voxel_conn_zmap_sorted_nii.img = lAT_lateral_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lAT_lateral_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lAT_lateral_voxel_connectivity_zmap_sorted.nii'])

clear lAT_lateral_Voxel_conn_zmap lAT_lateral_Voxel_conn_zmap_sorted_nii lAT_lateral_Voxel_connectivity

rAT_lateral_Voxel_conn_zmap = atanh(rAT_lateral_Voxel_connectivity);
rAT_lateral_Voxel_connectivity_zmap_sorted = rAT_lateral_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rAT_lateral_Voxel_conn_zmap_sorted_nii = nii_template;
rAT_lateral_Voxel_conn_zmap_sorted_nii.img = rAT_lateral_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rAT_lateral_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rAT_lateral_voxel_connectivity_zmap_sorted.nii'])

clear rAT_lateral_Voxel_conn_zmap rAT_lateral_Voxel_conn_zmap_sorted_nii rAT_lateral_Voxel_connectivity

lST_middle_Voxel_conn_zmap = atanh(lST_middle_Voxel_connectivity);
lST_middle_Voxel_connectivity_zmap_sorted = lST_middle_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lST_middle_Voxel_conn_zmap_sorted_nii = nii_template;
lST_middle_Voxel_conn_zmap_sorted_nii.img = lST_middle_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lST_middle_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lST_middle_voxel_connectivity_zmap_sorted.nii'])

clear lST_middle_Voxel_conn_zmap lST_middle_Voxel_conn_zmap_sorted_nii lST_middle_Voxel_connectivity

rST_middle_Voxel_conn_zmap = atanh(rST_middle_Voxel_connectivity);
rST_middle_Voxel_connectivity_zmap_sorted = rST_middle_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rST_middle_Voxel_conn_zmap_sorted_nii = nii_template;
rST_middle_Voxel_conn_zmap_sorted_nii.img = rST_middle_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rST_middle_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rST_middle_voxel_connectivity_zmap_sorted.nii'])

clear rST_middle_Voxel_conn_zmap rST_middle_Voxel_conn_zmap_sorted_nii rST_middle_Voxel_connectivity

lMIT_Voxel_conn_zmap = atanh(lMIT_Voxel_connectivity);
lMIT_Voxel_connectivity_zmap_sorted = lMIT_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lMIT_Voxel_conn_zmap_sorted_nii = nii_template;
lMIT_Voxel_conn_zmap_sorted_nii.img = lMIT_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lMIT_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lMIT_voxel_connectivity_zmap_sorted.nii'])
 
clear lMIT_Voxel_conn_zmap lMIT_Voxel_conn_zmap_sorted_nii lMIT_Voxel_connectivity

rMIT_Voxel_conn_zmap = atanh(rMIT_Voxel_connectivity);
rMIT_Voxel_connectivity_zmap_sorted = rMIT_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rMIT_Voxel_conn_zmap_sorted_nii = nii_template;
rMIT_Voxel_conn_zmap_sorted_nii.img = rMIT_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rMIT_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rMIT_voxel_connectivity_zmap_sorted.nii'])

clear rMIT_Voxel_conn_zmap rMIT_Voxel_conn_zmap_sorted_nii rMIT_Voxel_connectivity

lPT_Voxel_conn_zmap = atanh(lPT_Voxel_connectivity);
lPT_Voxel_connectivity_zmap_sorted = lPT_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lPT_Voxel_conn_zmap_sorted_nii = nii_template;
lPT_Voxel_conn_zmap_sorted_nii.img = lPT_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lPT_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lPT_voxel_connectivity_zmap_sorted.nii'])

clear lPT_Voxel_conn_zmap lPT_Voxel_conn_zmap_sorted_nii lPT_Voxel_connectivity

rPT_Voxel_conn_zmap = atanh(rPT_Voxel_connectivity);
rPT_Voxel_connectivity_zmap_sorted = rPT_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rPT_Voxel_conn_zmap_sorted_nii = nii_template;
rPT_Voxel_conn_zmap_sorted_nii.img = rPT_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rPT_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rPT_voxel_connectivity_zmap_sorted.nii'])

clear rPT_Voxel_conn_zmap rPT_Voxel_conn_zmap_sorted_nii rPT_Voxel_connectivity

laSTG_Voxel_conn_zmap = atanh(laSTG_Voxel_connectivity);
laSTG_Voxel_connectivity_zmap_sorted = laSTG_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
laSTG_Voxel_conn_zmap_sorted_nii = nii_template;
laSTG_Voxel_conn_zmap_sorted_nii.img = laSTG_Voxel_connectivity_zmap_sorted;
save_untouch_nii(laSTG_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'laSTG_voxel_connectivity_zmap_sorted.nii'])

clear laSTG_Voxel_conn_zmap laSTG_Voxel_conn_zmap_sorted_nii laSTG_Voxel_connectivity

raSTG_Voxel_conn_zmap = atanh(raSTG_Voxel_connectivity);
raSTG_Voxel_connectivity_zmap_sorted = raSTG_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
raSTG_Voxel_conn_zmap_sorted_nii = nii_template;
raSTG_Voxel_conn_zmap_sorted_nii.img = raSTG_Voxel_connectivity_zmap_sorted;
save_untouch_nii(raSTG_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'raSTG_voxel_connectivity_zmap_sorted.nii'])

clear raSTG_Voxel_conn_zmap raSTG_Voxel_conn_zmap_sorted_nii raSTG_Voxel_connectivity
