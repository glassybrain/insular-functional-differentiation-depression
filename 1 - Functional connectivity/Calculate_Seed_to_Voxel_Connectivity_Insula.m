%%% Seed to Voxel Connectivity %%%
%%% Extract voxel timeseries from mask generated from intersect between the
%%% SPM grey matter tissue probability map and the Hammers atlas
%%% Connectivity is calculated with seed ROIs in the insula
%%% For each participant, the mean time series of each of the 12 unilateral insular subregions
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

Voxel_Conn_data_folder = '/path/to/smoothed_Seed_Voxel_Connectivity';   % output folder for the seed-to-voxel z-maps

GM_coordinates_file = '/path/to/GM_voxel_coordinates.mat';   % voxel coordinates of the grey matter mask
hammers_atlas_file = '/path/to/resliced_Hammers-n30r95-maxprob-gm-MNI152.nii';   % Hammers atlas resliced to the functional images
hammers_labels_file = '/path/to/Hammers_Labels.mat';   % labels of the Hammers atlas
sort_idx_file = '/path/to/subject_ID_sort_idx.mat';   % index used to sort participants by subject ID (subjects_IDs_sort_idx)

% Load voxel coordinates for grey matter mask
load(GM_coordinates_file)

% Load Hammers atlas
hammers_insula = load_untouch_nii(hammers_atlas_file);
hammers_insula = hammers_insula.img;
% Load atlas labels
load(hammers_labels_file)

% Get index of ROIs
lAI_short_idx = find(strcmp(Hammers_Labels,'insula anterior short gyrus L'));
rAI_short_idx = find(strcmp(Hammers_Labels,'insula anterior short gyrus R'));

lAI_long_idx = find(strcmp(Hammers_Labels,'insula anterior long gyrus L'));
rAI_long_idx = find(strcmp(Hammers_Labels,'insula anterior long gyrus R'));

lAI_pole_idx = find(strcmp(Hammers_Labels,'insula anterior pole L'));
rAI_pole_idx = find(strcmp(Hammers_Labels,'insula anterior pole R'));

lI_middle_idx = find(strcmp(Hammers_Labels,'insula middle short gyrus L'));
rI_middle_idx = find(strcmp(Hammers_Labels,'insula middle short gyrus R'));

lPI_short_idx = find(strcmp(Hammers_Labels,'insula posterior short gyrus L'));
rPI_short_idx = find(strcmp(Hammers_Labels,'insula posterior short gyrus R'));

lPI_long_idx = find(strcmp(Hammers_Labels,'insula posterior long gyrus L'));
rPI_long_idx = find(strcmp(Hammers_Labels,'insula posterior long gyrus R'));



% Create the respective logical masks
lAI_short_mask = single(zeros(91,109,91));
lAI_short_mask(hammers_insula == lAI_short_idx) = 1;
lAI_short_mask = logical(lAI_short_mask);

rAI_short_mask = single(zeros(91,109,91));
rAI_short_mask(hammers_insula == rAI_short_idx) = 1;
rAI_short_mask = logical(rAI_short_mask);

lAI_long_mask = single(zeros(91,109,91));
lAI_long_mask(hammers_insula == lAI_long_idx) = 1;
lAI_long_mask = logical(lAI_long_mask);

rAI_long_mask = single(zeros(91,109,91));
rAI_long_mask(hammers_insula == rAI_long_idx) = 1;
rAI_long_mask = logical(rAI_long_mask);

lAI_pole_mask = single(zeros(91,109,91));
lAI_pole_mask(hammers_insula == lAI_pole_idx) = 1;
lAI_pole_mask = logical(lAI_pole_mask);

rAI_pole_mask = single(zeros(91,109,91));
rAI_pole_mask(hammers_insula == rAI_pole_idx) = 1;
rAI_pole_mask = logical(rAI_pole_mask);

lI_middle_mask = single(zeros(91,109,91));
lI_middle_mask(hammers_insula == lI_middle_idx) = 1;
lI_middle_mask = logical(lI_middle_mask);

rI_middle_mask = single(zeros(91,109,91));
rI_middle_mask(hammers_insula == rI_middle_idx) = 1;
rI_middle_mask = logical(rI_middle_mask);

lPI_short_mask = single(zeros(91,109,91));
lPI_short_mask(hammers_insula == lPI_short_idx) = 1;
lPI_short_mask = logical(lPI_short_mask);

rPI_short_mask = single(zeros(91,109,91));
rPI_short_mask(hammers_insula == rPI_short_idx) = 1;
rPI_short_mask = logical(rPI_short_mask);

lPI_long_mask = single(zeros(91,109,91));
lPI_long_mask(hammers_insula == lPI_long_idx) = 1;
lPI_long_mask = logical(lPI_long_mask);

rPI_long_mask = single(zeros(91,109,91));
rPI_long_mask(hammers_insula == rPI_long_idx) = 1;
rPI_long_mask = logical(rPI_long_mask);

% Prepare list of subjects
subjects = dir(FunImgFolder);
subjects = subjects(arrayfun(@(x) x.name(1), subjects) ~= '.');

% Generate target structures
lAI_short_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
rAI_short_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
lAI_long_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
rAI_long_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
lAI_pole_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
rAI_pole_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
lI_middle_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
rI_middle_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
lPI_short_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
rPI_short_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
lPI_long_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));
rPI_long_Voxel_connectivity = single(NaN(size(hammers_insula,1), size(hammers_insula,2), size(hammers_insula,3),length(subjects)));


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
        
        % Insula
        lAI_short_subset_ROI_timeseries = image_subset(lAI_short_mask);
        rAI_short_subset_ROI_timeseries = image_subset(rAI_short_mask);
        lAI_long_subset_ROI_timeseries = image_subset(lAI_long_mask);
        rAI_long_subset_ROI_timeseries = image_subset(rAI_long_mask);
        lAI_pole_subset_ROI_timeseries = image_subset(lAI_pole_mask);
        rAI_pole_subset_ROI_timeseries = image_subset(rAI_pole_mask);
        lI_middle_subset_ROI_timeseries = image_subset(lI_middle_mask);
        rI_middle_subset_ROI_timeseries = image_subset(rI_middle_mask);
        lPI_short_subset_ROI_timeseries = image_subset(lPI_short_mask);
        rPI_short_subset_ROI_timeseries = image_subset(rPI_short_mask);
        lPI_long_subset_ROI_timeseries = image_subset(lPI_long_mask);
        rPI_long_subset_ROI_timeseries = image_subset(rPI_long_mask);
        
        lAI_short_timeseries(1,timepoints) = mean(lAI_short_subset_ROI_timeseries);
        rAI_short_timeseries(1,timepoints) = mean(rAI_short_subset_ROI_timeseries);
        lAI_long_timeseries(1,timepoints) = mean(lAI_long_subset_ROI_timeseries);
        rAI_long_timeseries(1,timepoints) = mean(rAI_long_subset_ROI_timeseries);
        lAI_pole_timeseries(1,timepoints) = mean(lAI_pole_subset_ROI_timeseries);
        rAI_pole_timeseries(1,timepoints) = mean(rAI_pole_subset_ROI_timeseries);
        lI_middle_timeseries(1,timepoints) = mean(lI_middle_subset_ROI_timeseries);
        rI_middle_timeseries(1,timepoints) = mean(rI_middle_subset_ROI_timeseries);
        lPI_short_timeseries(1,timepoints) = mean(lPI_short_subset_ROI_timeseries);
        rPI_short_timeseries(1,timepoints) = mean(rPI_short_subset_ROI_timeseries);
        lPI_long_timeseries(1,timepoints) = mean(lPI_long_subset_ROI_timeseries);
        rPI_long_timeseries(1,timepoints) = mean(rPI_long_subset_ROI_timeseries);

    end
    
    % Calculate seed ROI to Voxel Connectivity
    for voxels = 1:length(GM_voxel_coordinates)
    
        voxel_timeseries = squeeze(functional_image(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),:));
        
        % Insula
        lAI_short_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lAI_short_timeseries',voxel_timeseries);
        rAI_short_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rAI_short_timeseries',voxel_timeseries);
        lAI_long_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lAI_long_timeseries',voxel_timeseries);
        rAI_long_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rAI_long_timeseries',voxel_timeseries);
        lAI_pole_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lAI_pole_timeseries',voxel_timeseries);
        rAI_pole_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rAI_pole_timeseries',voxel_timeseries);
        lI_middle_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lI_middle_timeseries',voxel_timeseries);
        rI_middle_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rI_middle_timeseries',voxel_timeseries);
        lPI_short_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lPI_short_timeseries',voxel_timeseries);
        rPI_short_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rPI_short_timeseries',voxel_timeseries);
        lPI_long_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(lPI_long_timeseries',voxel_timeseries);
        rPI_long_Voxel_connectivity(GM_voxel_coordinates(voxels,1),GM_voxel_coordinates(voxels,2),GM_voxel_coordinates(voxels,3),subjnumb) = corr(rPI_long_timeseries',voxel_timeseries);
        
        clear voxel_timeseries
        
    end
    
end

% Delete everything unnecessary from RAM to free up space
clearvars -except sort_idx_file Voxel_Conn_data_folder nii_template lAI_short_Voxel_connectivity rAI_short_Voxel_connectivity lAI_long_Voxel_connectivity rAI_long_Voxel_connectivity lAI_pole_Voxel_connectivity rAI_pole_Voxel_connectivity lI_middle_Voxel_connectivity rI_middle_Voxel_connectivity lPI_short_Voxel_connectivity rPI_short_Voxel_connectivity lPI_long_Voxel_connectivity rPI_long_Voxel_connectivity

% z-transform r maps, reorder subjects and write out sorted zmaps
load(sort_idx_file)

% Insula
lAI_short_Voxel_conn_zmap = atanh(lAI_short_Voxel_connectivity);
lAI_short_Voxel_connectivity_zmap_sorted = lAI_short_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lAI_short_Voxel_conn_zmap_sorted_nii = nii_template;
lAI_short_Voxel_conn_zmap_sorted_nii.img = lAI_short_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lAI_short_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lAI_short_voxel_connectivity_zmap_sorted.nii'])

clear lAI_short_Voxel_conn_zmap lAI_short_Voxel_conn_zmap_sorted_nii lAI_short_Voxel_connectivity

rAI_short_Voxel_conn_zmap = atanh(rAI_short_Voxel_connectivity);
rAI_short_Voxel_connectivity_zmap_sorted = rAI_short_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rAI_short_Voxel_conn_zmap_sorted_nii = nii_template;
rAI_short_Voxel_conn_zmap_sorted_nii.img = rAI_short_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rAI_short_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rAI_short_voxel_connectivity_zmap_sorted.nii'])

clear rAI_short_Voxel_conn_zmap rAI_short_Voxel_conn_zmap_sorted_nii rAI_short_Voxel_connectivity

lAI_long_Voxel_conn_zmap = atanh(lAI_long_Voxel_connectivity);
lAI_long_Voxel_connectivity_zmap_sorted = lAI_long_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lAI_long_Voxel_conn_zmap_sorted_nii = nii_template;
lAI_long_Voxel_conn_zmap_sorted_nii.img = lAI_long_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lAI_long_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lAI_long_voxel_connectivity_zmap_sorted.nii'])

clear lAI_long_Voxel_conn_zmap lAI_long_Voxel_conn_zmap_sorted_nii lAI_long_Voxel_connectivity

rAI_long_Voxel_conn_zmap = atanh(rAI_long_Voxel_connectivity);
rAI_long_Voxel_connectivity_zmap_sorted = rAI_long_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rAI_long_Voxel_conn_zmap_sorted_nii = nii_template;
rAI_long_Voxel_conn_zmap_sorted_nii.img = rAI_long_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rAI_long_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rAI_long_voxel_connectivity_zmap_sorted.nii'])

clear rAI_long_Voxel_conn_zmap rAI_long_Voxel_conn_zmap_sorted_nii rAI_long_Voxel_connectivity

lAI_pole_Voxel_conn_zmap = atanh(lAI_pole_Voxel_connectivity);
lAI_pole_Voxel_connectivity_zmap_sorted = lAI_pole_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lAI_pole_Voxel_conn_zmap_sorted_nii = nii_template;
lAI_pole_Voxel_conn_zmap_sorted_nii.img = lAI_pole_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lAI_pole_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lAI_pole_voxel_connectivity_zmap_sorted.nii'])

clear lAI_pole_Voxel_conn_zmap lAI_pole_Voxel_conn_zmap_sorted_nii lAI_pole_Voxel_connectivity

rAI_pole_Voxel_conn_zmap = atanh(rAI_pole_Voxel_connectivity);
rAI_pole_Voxel_connectivity_zmap_sorted = rAI_pole_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rAI_pole_Voxel_conn_zmap_sorted_nii = nii_template;
rAI_pole_Voxel_conn_zmap_sorted_nii.img = rAI_pole_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rAI_pole_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rAI_pole_voxel_connectivity_zmap_sorted.nii'])

clear rAI_pole_Voxel_conn_zmap rAI_pole_Voxel_conn_zmap_sorted_nii rAI_pole_Voxel_connectivity

lI_middle_Voxel_conn_zmap = atanh(lI_middle_Voxel_connectivity);
lI_middle_Voxel_connectivity_zmap_sorted = lI_middle_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lI_middle_Voxel_conn_zmap_sorted_nii = nii_template;
lI_middle_Voxel_conn_zmap_sorted_nii.img = lI_middle_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lI_middle_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lI_middle_voxel_connectivity_zmap_sorted.nii'])
 
clear lI_middle_Voxel_conn_zmap lI_middle_Voxel_conn_zmap_sorted_nii lI_middle_Voxel_connectivity

rI_middle_Voxel_conn_zmap = atanh(rI_middle_Voxel_connectivity);
rI_middle_Voxel_connectivity_zmap_sorted = rI_middle_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rI_middle_Voxel_conn_zmap_sorted_nii = nii_template;
rI_middle_Voxel_conn_zmap_sorted_nii.img = rI_middle_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rI_middle_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rI_middle_voxel_connectivity_zmap_sorted.nii'])

clear rI_middle_Voxel_conn_zmap rI_middle_Voxel_conn_zmap_sorted_nii rI_middle_Voxel_connectivity

lPI_short_Voxel_conn_zmap = atanh(lPI_short_Voxel_connectivity);
lPI_short_Voxel_connectivity_zmap_sorted = lPI_short_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lPI_short_Voxel_conn_zmap_sorted_nii = nii_template;
lPI_short_Voxel_conn_zmap_sorted_nii.img = lPI_short_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lPI_short_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lPI_short_voxel_connectivity_zmap_sorted.nii'])

clear lPI_short_Voxel_conn_zmap lPI_short_Voxel_conn_zmap_sorted_nii lPI_short_Voxel_connectivity

rPI_short_Voxel_conn_zmap = atanh(rPI_short_Voxel_connectivity);
rPI_short_Voxel_connectivity_zmap_sorted = rPI_short_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rPI_short_Voxel_conn_zmap_sorted_nii = nii_template;
rPI_short_Voxel_conn_zmap_sorted_nii.img = rPI_short_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rPI_short_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rPI_short_voxel_connectivity_zmap_sorted.nii'])

clear rPI_short_Voxel_conn_zmap rPI_short_Voxel_conn_zmap_sorted_nii rPI_short_Voxel_connectivity

lPI_long_Voxel_conn_zmap = atanh(lPI_long_Voxel_connectivity);
lPI_long_Voxel_connectivity_zmap_sorted = lPI_long_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
lPI_long_Voxel_conn_zmap_sorted_nii = nii_template;
lPI_long_Voxel_conn_zmap_sorted_nii.img = lPI_long_Voxel_connectivity_zmap_sorted;
save_untouch_nii(lPI_long_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'lPI_long_voxel_connectivity_zmap_sorted.nii'])

clear lPI_long_Voxel_conn_zmap lPI_long_Voxel_conn_zmap_sorted_nii lPI_long_Voxel_connectivity

rPI_long_Voxel_conn_zmap = atanh(rPI_long_Voxel_connectivity);
rPI_long_Voxel_connectivity_zmap_sorted = rPI_long_Voxel_conn_zmap(:,:,:,subjects_IDs_sort_idx);
rPI_long_Voxel_conn_zmap_sorted_nii = nii_template;
rPI_long_Voxel_conn_zmap_sorted_nii.img = rPI_long_Voxel_connectivity_zmap_sorted;
save_untouch_nii(rPI_long_Voxel_conn_zmap_sorted_nii,[Voxel_Conn_data_folder filesep 'rPI_long_voxel_connectivity_zmap_sorted.nii'])

clear rPI_long_Voxel_conn_zmap rPI_long_Voxel_conn_zmap_sorted_nii rPI_long_Voxel_connectivity
