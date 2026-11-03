%%% Calculate individual AIC-PIC similarity to prepare data for SVM
%%% classification
%%% For every participant, the residualised FC map of each anterior insular subregion
%%% (AI short, AI pole, MI short) is correlated (Pearson) with the residualised FC map of each
%%% posterior subregion (AI long, PI short, PI long) of the same participant, resulting in
%%% 3 x 3 = 9 similarity values per participant. Together with the group label (MDD = 1,
%%% HCP = 0) these are saved as SVM_data.mat / SVM_data.csv.
%%% Input: Bilateral_*_regress.mat (output of '2 - Similarity/Calculate_Similarity_Insula_Subregions.m')
%%% See 'Classification' in the Methods.
%%% Requires: MATLAB (Statistics and Machine Learning Toolbox)

clear all
clc

%% USER SETTINGS: adjust the paths below to your local system
% root folder
pre_result_folder = '/path/to/results_similarities_individual_subjects';   % residualised insula FC maps (Bilateral_*_regress.mat; output of '2 - Similarity')
out_folder = '/path/to/svm_prep';   % output folder for SVM_data.mat / SVM_data.csv
subj_sim_file = '/path/to/Bilateral_insula_FC/subj_sim';   % similarity values (output of '2 - Similarity/Calculate_Similarity_Insula_Subregions.m')
subject_IDs_file = '/path/to/subject_IDs_sorted';   % sorted subject IDs (subject_IDs_num)
covariates_file = '/path/to/PsyMRI_Covariates';   % covariate table of the FOR2107 sample
QC_file = '/path/to/FC';   % FC.mat (QC vector and covariates; output of '0 - Preprocessing/4 - Create_covariates_for_exclusion.m')

load(subj_sim_file);

% Load subject information
load(subject_IDs_file)
load(covariates_file)

%load QC vector
load(QC_file)

ROI_names_bilateral = {'Bilateral_AI_short';'Bilateral_AI_long';'Bilateral_AI_pole';'Bilateral_MI_short';'Bilateral_PI_short';'Bilateral_PI_long'};
ROI_corr_names = {'AI_short', 'AI_long', 'AI_pole', 'MI_short', 'PI_short', 'PI_long'};
ROI_names_anterior = {'Bilateral_AI_short';'Bilateral_AI_pole';'Bilateral_MI_short'};
ROI_names_posterior =  {'Bilateral_AI_long';'Bilateral_PI_short';'Bilateral_PI_long'};


%% get regressed files of all subregions (from script Calculate_Similarity_Insula_Subregions)
load([pre_result_folder filesep 'Bilateral_MI_short_regress.mat'])
load([pre_result_folder filesep 'Bilateral_AI_short_regress.mat'])
load([pre_result_folder filesep 'Bilateral_AI_long_regress.mat'])
load([pre_result_folder filesep 'Bilateral_AI_pole_regress.mat'])
load([pre_result_folder filesep 'Bilateral_PI_short_regress.mat'])
load([pre_result_folder filesep 'Bilateral_PI_long_regress.mat'])


regress_FC.Bilateral_AI_pole =Bilateral_AI_pole;
regress_FC.Bilateral_AI_long =Bilateral_AI_long;
regress_FC.Bilateral_PI_long =Bilateral_PI_long;
regress_FC.Bilateral_AI_short =Bilateral_AI_short;
regress_FC.Bilateral_PI_short =Bilateral_PI_short;
regress_FC.Bilateral_MI_short =Bilateral_MI_short;

clear Bilateral_AI_long Bilateral_AI_pole Bilateral_AI_short Bilateral_MI_short Bilateral_PI_short Bilateral_PI_long activity coordinates x y z intercept

%%
% Run through ROIs, vectorize matrices and correlate
AI_short = [];
AI_pole = [];
MI_short = [];

clear Bilateral_AI_pole_nii Bilateral_AI_short_nii Bilateral_PI_short_test functional_image nii_template rAI_pole-voxel_connectivity_zmap_sorted
clear rAI_pole_voxel_connectivity_zmap_sorted lAI_pole_voxel_connectivity_zmap_sorted


%correlate every anterior subregion of an individual subject with every
%posterior subregion of the same subject 
 for i = 1:length(ROI_names_anterior)
 
 for subjects = 1:size(regress_FC.(ROI_names_anterior{i,1}), 4)
        subset = regress_FC.(ROI_names_anterior{i,1})(:,:,:, subjects); 
        subject_vector_ant = subset (:);
        
       for j = 1:length(ROI_names_posterior)
            
       
        
        subset_post = regress_FC.(ROI_names_posterior{j,1})(:,:,:, subjects);
        subject_vector_post = subset_post (:);
     
        ROI_corr = corr(subject_vector_ant, subject_vector_post, 'rows','complete');
        save([out_folder filesep 'ROI_corr.mat'],'ROI_corr')

        switch i

            case 1

                AI_short = [AI_short;ROI_corr];

            case 2

                AI_pole = [AI_pole;ROI_corr];

            case 3

                MI_short = [MI_short;ROI_corr];

            
        end

       clear ROI_corr subject_vector_post
       end
   clear subset_vector 
 end
end

clear j i subject_vector_ant subject_vector_post subset_post

untransf_subj_sim.AI_short = AI_short;
untransf_subj_sim.AI_pole = AI_pole;
untransf_subj_sim.MI_short = MI_short;
save([out_folder filesep 'untransf_subj_sim.mat'],'untransf_subj_sim')
load([out_folder filesep 'untransf_subj_sim.mat'],'untransf_subj_sim')


%reshape data 
reshaped.AI_short = (reshape(untransf_subj_sim.AI_short, 3, 850))'; 
reshaped.AI_pole = (reshape(untransf_subj_sim.AI_pole, 3, 850))'; 
reshaped.MI_short = (reshape(untransf_subj_sim.MI_short, 3, 850))'; 

complete = [reshaped.AI_short reshaped.AI_pole reshaped.MI_short];
complete = double(complete);
Group = FC.Group(FC.qQC);
complete = [Group complete];
save([out_folder filesep 'complete_svm_prep.mat'],'complete')

SVM_data = array2table(complete, 'VariableNames', {'Group','AIsxAIl', 'AIsxPIs', 'AIsxPIl','AIpxAIl', 'AIpxPIs', 'AIpxPIl', 'MIsxAIl', 'MIsxPIs', 'MIsxPIl' });

%export
save([out_folder filesep 'SVM_data.mat'],'SVM_data')
writetable(SVM_data, [out_folder filesep 'SVM_data.csv'])
