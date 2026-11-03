%create logical for MDD and HC to get two regressed mean niftis for each ROI:
%one containing only MDD values, one containing HC values
%%% Prepares the input for the shift function analysis (insula)
%%% The residualised FC maps of every subregion (Bilateral_*_regress.nii; output of
%%% '2 - Similarity') are split by group and averaged across participants within each group.
%%% The resulting group-mean FC values of all non-NaN (grey matter) voxels are saved as one
%%% vector per group and subregion (hc_*.mat/.csv, mdd_*.mat/.csv). These group-level FC
%%% density distributions are the input of Run_shift_function_insula.R and
%%% Plot_insula_FC_distributions.R.
%%% Note: the .mat files are written to out_folder, the .csv files to the current working
%%% directory.
%%% Requires: MATLAB, NIfTI toolbox (load_nii)

clear all 

%% USER SETTINGS: adjust the paths below to your local system
result_folder = '/path/to/results_similarities_individual_subjects';   % residualised insula FC maps (Bilateral_*_regress.nii) and T_insula.mat (output of '2 - Similarity')
QC_file = '/path/to/FC.mat';   % QC vector and covariates (output of '0 - Preprocessing/4 - Create_covariates_for_exclusion.m')
out_folder = '/path/to/shift_prep';   % output folder for the .mat files

load([result_folder filesep 'T_insula.mat'])
load(QC_file)

ROI_names_bilateral = {'Bilateral_AI_short';'Bilateral_AI_long';'Bilateral_AI_pole';'Bilateral_MI_short';'Bilateral_PI_short';'Bilateral_PI_long'};


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
regress_mdd.Bilateral_AI_long = regress_mdd.Bilateral_AI_long(:,:,:,group_mdd);
regress_mdd.Bilateral_AI_short = regress_mdd.Bilateral_AI_short(:,:,:,group_mdd);
regress_mdd.Bilateral_AI_pole = regress_mdd.Bilateral_AI_pole(:,:,:,group_mdd);
regress_mdd.Bilateral_MI_short = regress_mdd.Bilateral_MI_short(:,:,:,group_mdd);
regress_mdd.Bilateral_PI_long = regress_mdd.Bilateral_PI_long(:,:,:,group_mdd);
regress_mdd.Bilateral_PI_short = regress_mdd.Bilateral_PI_short(:,:,:,group_mdd);

%get FC mean over all mdd
for i = 1:length(ROI_names_bilateral)

  mean_mdd.(ROI_names_bilateral{i,1}) = nanmean(regress_mdd.(ROI_names_bilateral{i,1}) , 4);

end

%hc
for i = 1:length(ROI_names_bilateral)

 regress_hc.(ROI_names_bilateral{i,1}) = regress_FC.(ROI_names_bilateral{i,1}).img;

end

regress_hc.Bilateral_AI_long = regress_hc.Bilateral_AI_long(:,:,:,group_hc);
regress_hc.Bilateral_AI_short = regress_hc.Bilateral_AI_short(:,:,:,group_hc);
regress_hc.Bilateral_AI_pole = regress_hc.Bilateral_AI_pole(:,:,:,group_hc);
regress_hc.Bilateral_MI_short = regress_hc.Bilateral_MI_short(:,:,:,group_hc);
regress_hc.Bilateral_PI_long = regress_hc.Bilateral_PI_long(:,:,:,group_hc);
regress_hc.Bilateral_PI_short = regress_hc.Bilateral_PI_short(:,:,:,group_hc);

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

mask_mdd = mask_mdd.Bilateral_AI_long;

mean_mdd.Bilateral_AI_long = mean_mdd.Bilateral_AI_long(mask_mdd);
mean_mdd.Bilateral_AI_short = mean_mdd.Bilateral_AI_short(mask_mdd);
mean_mdd.Bilateral_AI_pole = mean_mdd.Bilateral_AI_pole(mask_mdd);
mean_mdd.Bilateral_PI_long = mean_mdd.Bilateral_PI_long(mask_mdd);
mean_mdd.Bilateral_PI_short = mean_mdd.Bilateral_PI_short(mask_mdd);
mean_mdd.Bilateral_MI_short = mean_mdd.Bilateral_MI_short(mask_mdd);

mdd_Bilateral_AI_long = mean_mdd.Bilateral_AI_long;
mdd_Bilateral_AI_short = mean_mdd.Bilateral_AI_short;
mdd_Bilateral_AI_pole = mean_mdd.Bilateral_AI_pole;
mdd_Bilateral_PI_long = mean_mdd.Bilateral_PI_long;
mdd_Bilateral_PI_short = mean_mdd.Bilateral_PI_short;
mdd_Bilateral_MI_short = mean_mdd.Bilateral_MI_short;

save([out_folder filesep 'mdd_Bilateral_AI_long.mat'],'mdd_Bilateral_AI_long')
csvwrite('mdd_Bilateral_AI_long.csv', mdd_Bilateral_AI_long)

save([out_folder filesep 'mdd_Bilateral_AI_short.mat'],'mdd_Bilateral_AI_short')
csvwrite('mdd_Bilateral_AI_short.csv', mdd_Bilateral_AI_short)

save([out_folder filesep 'mdd_Bilateral_AI_pole.mat'],'mdd_Bilateral_AI_pole')
csvwrite('mdd_Bilateral_AI_pole.csv', mdd_Bilateral_AI_pole)

save([out_folder filesep 'mdd_Bilateral_PI_long.mat'],'mdd_Bilateral_PI_long')
csvwrite('mdd_Bilateral_PI_long.csv', mdd_Bilateral_PI_long)

save([out_folder filesep 'mdd_Bilateral_PI_short.mat'],'mdd_Bilateral_PI_short')
csvwrite('mdd_Bilateral_PI_short.csv', mdd_Bilateral_PI_short)

save([out_folder filesep 'mdd_Bilateral_MI_short.mat'],'mdd_Bilateral_MI_short')
csvwrite('mdd_Bilateral_MI_short.csv', mdd_Bilateral_MI_short)

%hc
for i = 1:length(ROI_names_bilateral)%put here for memory reaons
   mask_hc.(ROI_names_bilateral{i,1}) = mean_hc.(ROI_names_bilateral{i,1});  

end

for i = 1:length(ROI_names_bilateral)

  mask_hc.(ROI_names_bilateral{i,1})(isnan(mask_hc.(ROI_names_bilateral{i,1}))) = 0;
  mask_hc.(ROI_names_bilateral{i,1})= mask_hc.(ROI_names_bilateral{i,1}) ~=0;
 
end

mask_hc = mask_hc.Bilateral_AI_long;

hc_Bilateral_AI_long = mean_hc.Bilateral_AI_long(mask_hc);
hc_Bilateral_AI_short = mean_hc.Bilateral_AI_short(mask_hc);
hc_Bilateral_AI_pole = mean_hc.Bilateral_AI_pole(mask_hc);
hc_Bilateral_PI_long = mean_hc.Bilateral_PI_long(mask_hc);
hc_Bilateral_PI_short = mean_hc.Bilateral_PI_short(mask_hc);
hc_Bilateral_MI_short = mean_hc.Bilateral_MI_short(mask_hc);

save([out_folder filesep 'hc_Bilateral_AI_long.mat'],'hc_Bilateral_AI_long')
csvwrite('hc_Bilateral_AI_long.csv', hc_Bilateral_AI_long)

save([out_folder filesep 'hc_Bilateral_AI_short.mat'],'hc_Bilateral_AI_short')
csvwrite('hc_Bilateral_AI_short.csv', hc_Bilateral_AI_short)

save([out_folder filesep 'hc_Bilateral_AI_pole.mat'],'hc_Bilateral_AI_pole')
csvwrite('hc_Bilateral_AI_pole.csv', hc_Bilateral_AI_pole)

save([out_folder filesep 'hc_Bilateral_PI_long.mat'],'hc_Bilateral_PI_long')
csvwrite('hc_Bilateral_PI_long.csv', hc_Bilateral_PI_long)

save([out_folder filesep 'hc_Bilateral_PI_short.mat'],'hc_Bilateral_PI_short')
csvwrite('hc_Bilateral_PI_short.csv', hc_Bilateral_PI_short)

save([out_folder filesep 'hc_Bilateral_MI_short.mat'],'hc_Bilateral_MI_short')
csvwrite('hc_Bilateral_MI_short.csv', hc_Bilateral_MI_short)