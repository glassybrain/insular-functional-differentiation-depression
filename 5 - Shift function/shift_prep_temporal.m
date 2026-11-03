%create logical for MDD and HC to get two regressed mean niftis for each ROI:
%one containing only MDD values, one containing HC values
%%% Prepares the input for the shift function analysis (temporal cortex)
%%% The residualised FC maps of every subregion (Bilateral_*_regress.nii; output of
%%% '2 - Similarity') are split by group and averaged across participants within each group.
%%% The resulting group-mean FC values of all non-NaN (grey matter) voxels are saved as one
%%% vector per group and subregion (hc_*.mat/.csv, mdd_*.mat/.csv). These group-level FC
%%% density distributions are the input of Run_shift_function_temporal.R and
%%% Plot_temporal_FC_distributions.R.
%%% Note: the .mat files are written to out_folder, the .csv files to the current working
%%% directory.
%%% Requires: MATLAB, NIfTI toolbox (load_nii)

clear all 

%% USER SETTINGS: adjust the paths below to your local system
nifti_toolbox_folder = '/path/to/NIfTI_20140122';   % NIfTI toolbox
result_folder = '/path/to/results_similarities_individual_subjects';   % residualised temporal FC maps (Bilateral_*_regress.nii) and T_temporal.mat (output of '2 - Similarity')
QC_file = '/path/to/FC.mat';   % QC vector and covariates (output of '0 - Preprocessing/4 - Create_covariates_for_exclusion.m')
out_folder = '/path/to/shift_prep/temporal';   % output folder for the .mat files

addpath(nifti_toolbox_folder)
load([result_folder filesep 'T_temporal.mat'])
load(QC_file)

ROI_names_bilateral = {'Bilateral_AT_medial';'Bilateral_AT_lateral';'Bilateral_ST_middle';'Bilateral_MIT';'Bilateral_PT';'Bilateral_aSTG'};


group = FC.Group(FC.qQC); 
group_mdd = logical(group);%logical to delete all HC (HC = 0);
group_hc = ~group_mdd;


%load regressed niftis (91x109x91x850)
for i = 1:length(ROI_names_bilateral)

  regress_FC.(ROI_names_bilateral{i,1}) = load_nii([result_folder filesep ROI_names_bilateral{i,1} '_regress.nii']);
   
end

%apply logical for mdd and hc on a set of regress_FC to get hc and mdd
%subjects FC and get subjectmean for each roi

%mdd
for i = 1:length(ROI_names_bilateral)

 regress_mdd.(ROI_names_bilateral{i,1}) = regress_FC.(ROI_names_bilateral{i,1}).img;

end

%apply logical value on data to only have mdd information
regress_mdd.Bilateral_AT_medial = regress_mdd.Bilateral_AT_medial(:,:,:,group_mdd);
regress_mdd.Bilateral_AT_lateral = regress_mdd.Bilateral_AT_lateral(:,:,:,group_mdd);
regress_mdd.Bilateral_ST_middle = regress_mdd.Bilateral_ST_middle(:,:,:,group_mdd);
regress_mdd.Bilateral_MIT = regress_mdd.Bilateral_MIT(:,:,:,group_mdd);
regress_mdd.Bilateral_PT = regress_mdd.Bilateral_PT(:,:,:,group_mdd);
regress_mdd.Bilateral_aSTG = regress_mdd.Bilateral_aSTG(:,:,:,group_mdd);

%get FC mean over all mdd
for i = 1:length(ROI_names_bilateral)

  mean_mdd.(ROI_names_bilateral{i,1}) = nanmean(regress_mdd.(ROI_names_bilateral{i,1}) , 4);

end

%hc
for i = 1:length(ROI_names_bilateral)

 regress_hc.(ROI_names_bilateral{i,1}) = regress_FC.(ROI_names_bilateral{i,1}).img;

end

regress_hc.Bilateral_AT_medial = regress_hc.Bilateral_AT_medial(:,:,:,group_hc);
regress_hc.Bilateral_AT_lateral = regress_hc.Bilateral_AT_lateral(:,:,:,group_hc);
regress_hc.Bilateral_ST_middle = regress_hc.Bilateral_ST_middle(:,:,:,group_hc);
regress_hc.Bilateral_MIT = regress_hc.Bilateral_MIT(:,:,:,group_hc);
regress_hc.Bilateral_PT = regress_hc.Bilateral_PT(:,:,:,group_hc);
regress_hc.Bilateral_aSTG = regress_hc.Bilateral_aSTG(:,:,:,group_hc);

for i = 1:length(ROI_names_bilateral)

  mean_hc.(ROI_names_bilateral{i,1}) = nanmean(regress_hc.(ROI_names_bilateral{i,1}) , 4);

end


%create a list of all non-nan values for mdd and hc respectively 
for i = 1:length(ROI_names_bilateral)%put here for memory reaons
   mask_mdd.(ROI_names_bilateral{i,1}) = mean_mdd.(ROI_names_bilateral{i,1});  

end

for i = 1:length(ROI_names_bilateral)

  mask_mdd.(ROI_names_bilateral{i,1})(isnan(mask_mdd.(ROI_names_bilateral{i,1}))) = 0;
  mask_mdd.(ROI_names_bilateral{i,1})= mask_mdd.(ROI_names_bilateral{i,1}) ~=0;
 
end

mask_mdd = mask_mdd.Bilateral_AT_medial;

mean_mdd.Bilateral_AT_medial = mean_mdd.Bilateral_AT_medial(mask_mdd);
mean_mdd.Bilateral_AT_lateral = mean_mdd.Bilateral_AT_lateral(mask_mdd);
mean_mdd.Bilateral_ST_middle = mean_mdd.Bilateral_ST_middle(mask_mdd);
mean_mdd.Bilateral_MIT = mean_mdd.Bilateral_MIT(mask_mdd);
mean_mdd.Bilateral_PT = mean_mdd.Bilateral_PT(mask_mdd);
mean_mdd.Bilateral_aSTG = mean_mdd.Bilateral_aSTG(mask_mdd);

mdd_Bilateral_AT_medial = mean_mdd.Bilateral_AT_medial;
mdd_Bilateral_AT_lateral = mean_mdd.Bilateral_AT_lateral;
mdd_Bilateral_ST_middle = mean_mdd.Bilateral_ST_middle;
mdd_Bilateral_MIT = mean_mdd.Bilateral_MIT;
mdd_Bilateral_PT = mean_mdd.Bilateral_PT;
mdd_Bilateral_aSTG = mean_mdd.Bilateral_aSTG;

save([out_folder filesep 'mdd_Bilateral_AT_medial.mat'],'mdd_Bilateral_AT_medial')
csvwrite('mdd_Bilateral_AT_medial.csv', mdd_Bilateral_AT_medial)

save([out_folder filesep 'mdd_Bilateral_AT_lateral.mat'],'mdd_Bilateral_AT_lateral')
csvwrite('mdd_Bilateral_AT_lateral.csv', mdd_Bilateral_AT_lateral)

save([out_folder filesep 'mdd_Bilateral_ST_middle.mat'],'mdd_Bilateral_ST_middle')
csvwrite('mdd_Bilateral_ST_middle.csv', mdd_Bilateral_ST_middle)

save([out_folder filesep 'mdd_Bilateral_MIT.mat'],'mdd_Bilateral_MIT')
csvwrite('mdd_Bilateral_MIT.csv', mdd_Bilateral_MIT)

save([out_folder filesep 'mdd_Bilateral_PT.mat'],'mdd_Bilateral_PT')
csvwrite('mdd_Bilateral_PT.csv', mdd_Bilateral_PT)

save([out_folder filesep 'mdd_Bilateral_aSTG.mat'],'mdd_Bilateral_aSTG')
csvwrite('mdd_Bilateral_aSTG.csv', mdd_Bilateral_aSTG)

%hc
for i = 1:length(ROI_names_bilateral)%put here for memory reaons
   mask_hc.(ROI_names_bilateral{i,1}) = mean_hc.(ROI_names_bilateral{i,1});  

end

for i = 1:length(ROI_names_bilateral)

  mask_hc.(ROI_names_bilateral{i,1})(isnan(mask_hc.(ROI_names_bilateral{i,1}))) = 0;
  mask_hc.(ROI_names_bilateral{i,1})= mask_hc.(ROI_names_bilateral{i,1}) ~=0;
 
end

mask_hc = mask_hc.Bilateral_AT_medial;

hc_Bilateral_AT_medial = mean_hc.Bilateral_AT_medial(mask_hc);
hc_Bilateral_AT_lateral = mean_hc.Bilateral_AT_lateral(mask_hc);
hc_Bilateral_ST_middle = mean_hc.Bilateral_ST_middle(mask_hc);
hc_Bilateral_MIT = mean_hc.Bilateral_MIT(mask_hc);
hc_Bilateral_PT = mean_hc.Bilateral_PT(mask_hc);
hc_Bilateral_aSTG = mean_hc.Bilateral_aSTG(mask_hc);

save([out_folder filesep 'hc_Bilateral_AT_medial.mat'],'hc_Bilateral_AT_medial')
csvwrite('hc_Bilateral_AT_medial.csv', hc_Bilateral_AT_medial)

save([out_folder filesep 'hc_Bilateral_AT_lateral.mat'],'hc_Bilateral_AT_lateral')
csvwrite('hc_Bilateral_AT_lateral.csv', hc_Bilateral_AT_lateral)

save([out_folder filesep 'hc_Bilateral_ST_middle.mat'],'hc_Bilateral_ST_middle')
csvwrite('hc_Bilateral_ST_middle.csv', hc_Bilateral_ST_middle)

save([out_folder filesep 'hc_Bilateral_MIT.mat'],'hc_Bilateral_MIT')
csvwrite('hc_Bilateral_MIT.csv', hc_Bilateral_MIT)

save([out_folder filesep 'hc_Bilateral_PT.mat'],'hc_Bilateral_PT')
csvwrite('hc_Bilateral_PT.csv', hc_Bilateral_PT)

save([out_folder filesep 'hc_Bilateral_aSTG.mat'],'hc_Bilateral_aSTG')
csvwrite('hc_Bilateral_aSTG.csv', hc_Bilateral_aSTG)