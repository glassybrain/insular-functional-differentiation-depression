%%% PsyMRI ROI to ROI Connectivity %%%
%%% Extract voxel timeseries from the extended Harvard Oxford
%%% atlas (CONN plus reinforcement learning atlas) and correlate
%%% For every participant, the mean time series of each atlas ROI is extracted and all
%%% ROI time series are correlated with each other (Pearson). The resulting ROI-to-ROI
%%% connectivity matrices (ROIs x ROIs x participants) are used to compute each
%%% participant's whole-brain mean connectivity for quality control (script 4).
%%% Requires: MATLAB, NIfTI toolbox (load_untouch_nii)

clear all
clc

%% USER SETTINGS: adjust the paths below to your local system
% Set up folders
FunImgFolder = '/path/to/preprocessed_smoothed';   % smoothed functional images (one 4D NIfTI per participant, output of script 2)

Voxel_Conn_data_folder = '/path/to/smoothed_Seed_Voxel_Connectivity';   % not used in this script

output_folder = '/path/to/ROI_conn_sorted';   % output folder for Whole_brain_ROI_Conn_sorted.mat

atlas_folder = '/path/to/Atlas/reinforcement_learning_atlas';   % contains Harvard_Oxford_atlas_extended.nii and Harvard_Oxford_atlas_extended_labels.mat

% Load extended CONN atlas (including regions from Reinforcement Learning
% atlas)
atlas = load_untouch_nii([atlas_folder filesep 'Harvard_Oxford_atlas_extended.nii']);
atlas = atlas.img;
% Load atlas labels
load([atlas_folder filesep 'Harvard_Oxford_atlas_extended_labels.mat'])


% Prepare list of subjects
subjects = dir(FunImgFolder);
subjects = subjects(arrayfun(@(x) x.name(1), subjects) ~= '.');



for subjnumb = 1:length(subjects)
    
    disp('---------------------------------------')
    disp(' ')
    disp(['Constructing ROI to ROI connectivity for subject ' num2str(subjnumb) ' of ' num2str(length(subjects))])
    disp(' ')
    disp('---------------------------------------') 
    
    subj = subjects(subjnumb).name;
    subj_ID = subj(1:end-4);
    
        
    functional_image = load_untouch_nii([FunImgFolder filesep subj]);
    functional_image = functional_image.img;
    functional_image(functional_image == 0) = NaN;
    
    for ROIs = 1:length(Labels)
        
        % Get mask
        seed_ROI_mask = single(zeros(91,109,91));
        seed_ROI_mask(atlas == ROIs) = 1;
        seed_ROI_mask = logical(seed_ROI_mask);
    
        % Extract the seed ROI timeseries
        for timepoints = 1:size(functional_image,4)

            image_subset = functional_image(:,:,:,timepoints);
            subset_ROI_timeseries = image_subset(seed_ROI_mask);
            seed_ROI_timeseries(ROIs,timepoints) = nanmean(subset_ROI_timeseries);   
            
            clear image_subset subset_ROI_timeseries

        end
        
        clear seed_ROI_mask
        
    end
    
    % Calculate seed ROI timeseries connectivity to every other ROI
    ROI_conn_sorted(:,:,subjnumb) = corrcoef(seed_ROI_timeseries');
    
    clear seed_ROI_timeseries functional_image
    
end

% Save connectivity matrix
save([output_folder filesep 'Whole_brain_ROI_Conn_sorted.mat'],'ROI_conn_sorted')

