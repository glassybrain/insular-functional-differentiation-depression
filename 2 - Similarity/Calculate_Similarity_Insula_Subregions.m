% Similarity correlation for individuals subjects in insula cortex regions
%%% Calculates the similarity of insular subregional FC profiles for every participant
%%% 1. Averages left and right seed-to-voxel z-maps (output of '1 - Functional connectivity')
%%%    to obtain bilateral FC maps of the 6 insular subregions
%%% 2. Keeps participants who passed quality control (FC.qQC) and regresses the FC maps
%%%    voxel-wise on age, sex, site and motion (mean framewise displacement); residuals plus
%%%    intercept are saved as Bilateral_*_regress.nii/.mat (also used in '5 - Shift function'
%%%    and '6 - SVM')
%%% 3. Averages the residualised maps across all participants (sample FC map per subregion)
%%%    and correlates (Pearson) every participant's subregional FC map with each of the six
%%%    sample FC maps; correlations are Fisher z-transformed (atanh)
%%% 4. Writes the long-format table T_insula (one row per participant x subregion pair) with
%%%    the columns Subj_ID, Sub_A, Sub_B, within, atanh, Group (MDD = 1, HCP = 0) and region
%%%    (0 = between, 1 = anterior-within, 2 = posterior-within)
%%% Subregion codes: 1 = AI short, 2 = AI long, 3 = AI pole, 4 = MI short, 5 = PI short,
%%% 6 = PI long
%%% See 'Calculation of resting state functional connectivity' and 'Similarity calculations'
%%% in the Methods.
%%% Requires: MATLAB (Statistics and Machine Learning Toolbox), NIfTI toolbox

clear all
clc

%% USER SETTINGS: adjust the paths below to your local system
% root folder
Voxel_Conn_data_folder = '/path/to/smoothed_Seed_Voxel_Connectivity';   % seed-to-voxel z-maps of the insular subregions (output of '1 - Functional connectivity')
conn_matrices_folder = '/path/to/connectivity_matrices';   % folder containing the same unilateral insula z-maps (*_voxel_connectivity_zmap_sorted.nii)
result_folder = '/path/to/results_similarities_individual_subjects';   % output folder for the residualised FC maps and T_insula
out_folder = '/path/to/Bilateral_insula_FC';   % output folder for bilateral FC maps, mean maps and similarity values
inter_folder = '/path/to/Bilateral_insula_FC';   % output folder for the bilateral FC maps (.mat)
subject_IDs_file = '/path/to/subject_IDs_sorted';   % sorted subject IDs (subject_IDs_num)
covariates_file = '/path/to/PsyMRI_Covariates';   % covariate table of the FOR2107 sample
QC_file = '/path/to/FC';   % FC.mat (QC vector and covariates; output of '0 - Preprocessing/4 - Create_covariates_for_exclusion.m')
motion_file = '/path/to/FD_HM.xlsx';   % mean framewise displacement per participant

load([out_folder filesep 'subj_sim']);

% Load subject information
load(subject_IDs_file)
load(covariates_file)

%load QC vector
load(QC_file)

ROI_names = {'l_AI_short'; 'r_AI_short';'l_AI_long';'r_AI_long';'l_AI_pole';'r_AI_pole';'l_MI_short';'r_MI_short';'l_PI_short';'r_PI_short';'l_PI_long';'r_PI_long'};
ROI_names_bilateral = {'Bilateral_AI_short';'Bilateral_AI_long';'Bilateral_AI_pole';'Bilateral_MI_short';'Bilateral_PI_short';'Bilateral_PI_long'};
ROI_filenames = {'lAI_short';'rAI_short';'lAI_long';'rAI_long';'lAI_pole';'rAI_pole';'lI_middle';'rI_middle';'lPI_short';'rPI_short';'lPI_long';'rPI_long'};
ROI_corr_names = {'AI_short', 'AI_long', 'AI_pole', 'MI_short', 'PI_short', 'PI_long'};




for i = 1:length(ROI_names)

  seed_FC_map.(ROI_names{i,1}) = load_nii([Voxel_Conn_data_folder filesep ROI_filenames{i,1}  '_voxel_connectivity_zmap_sorted.nii']);
    
end

%1. Generate bilateral from unilateral data
% Generate mean ROI maps
lAI_long_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'lAI_long_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lAI_long_voxel_connectivity_zmap_sorted.img;
rAI_long_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'rAI_long_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rAI_long_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_AI_long = ROI_map_bilateral;
clear lAI_long_voxel_connectivity_zmap_sorted rAI_long_voxel_connectivity_zmap_sorted
clear roi_counter

lAI_pole_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'lAI_pole_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lAI_pole_voxel_connectivity_zmap_sorted.img;
rAI_pole_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'rAI_pole_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rAI_pole_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_AI_pole = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lAI_pole_voxel_connectivity_zmap_sorted rAI_pole_voxel_connectivity_zmap_sorted
clear roi_counter

lAI_short_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'lAI_short_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lAI_short_voxel_connectivity_zmap_sorted.img;
rAI_short_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'rAI_short_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rAI_short_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_AI_short = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lAI_short_voxel_connectivity_zmap_sorted rAI_short_voxel_connectivity_zmap_sorted
clear roi_counter

lI_middle_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'lI_middle_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lI_middle_voxel_connectivity_zmap_sorted.img;
rI_middle_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'rI_middle_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rI_middle_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_MI_short = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lI_middle_voxel_connectivity_zmap_sorted rI_middle_voxel_connectivity_zmap_sorted
clear roi_counter

lPI_short_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'lPI_short_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lPI_short_voxel_connectivity_zmap_sorted.img;
rPI_short_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'rPI_short_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rPI_short_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_PI_short = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lPI_short_voxel_connectivity_zmap_sorted rPI_short_voxel_connectivity_zmap_sorted
clear roi_counter

lPI_long_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'lPI_long_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lPI_long_voxel_connectivity_zmap_sorted.img;
rPI_long_voxel_connectivity_zmap_sorted = load_nii([conn_matrices_folder filesep 'rPI_long_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rPI_long_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_PI_long = ROI_map_bilateral;

clear ROI_map ROI_map_bilateral
clear lPI_long_voxel_connectivity_zmap_sorted rPI_long_voxel_connectivity_zmap_sorted
clear roi_counter

save([inter_folder filesep 'Bilateral_AI_long.mat'],'Bilateral_AI_long')
save([inter_folder filesep 'Bilateral_AI_short.mat'],'Bilateral_AI_short')
save([inter_folder filesep 'Bilateral_AI_pole.mat'],'Bilateral_AI_pole')
save([inter_folder filesep 'Bilateral_PI_long.mat'],'Bilateral_PI_long')
save([inter_folder filesep 'Bilateral_PI_short.mat'],'Bilateral_PI_short')
save([inter_folder filesep 'Bilateral_MI_short.mat'],'Bilateral_MI_short')


%write bilaterals back to NIFTI for further use
 %set a NIFTI template with existing NIFTI with the same size first
   functional_image = load_untouch_nii([conn_matrices_folder filesep 'lPI_long_voxel_connectivity_zmap_sorted.nii']);
        nii_template = functional_image;
        nii_template.img = [];
        nii_template = rmfield(nii_template,'fileprefix');
        nii_template.hdr.dime.dim(1,5) = size(Bilateral_PI_long,4); % change header in 4th dimension to our QC reduced dataset

        clear functional_image
        
Bilateral_AI_long_nii = nii_template;
Bilateral_AI_long_nii.img = Bilateral_AI_long;
save_untouch_nii(Bilateral_AI_long_nii,[out_folder filesep 'Bilateral_AI_long.nii'])
clear Bilateral_AI_long_nii 

Bilateral_AI_short_nii = nii_template;
Bilateral_AI_short_nii.img = Bilateral_AI_short;
save_untouch_nii(Bilateral_AI_short_nii,[out_folder filesep 'Bilateral_AI_short.nii'])
clear Bilateral_AI_short_nii 


Bilateral_AI_pole_nii = nii_template;
Bilateral_AI_pole_nii.img = Bilateral_AI_pole;
save_untouch_nii(Bilateral_AI_pole_nii,[out_folder filesep 'Bilateral_AI_pole.nii'])
clear Bilateral_AI_pole_nii 

Bilateral_PI_short_nii = nii_template;
Bilateral_PI_short_nii.img = Bilateral_PI_short;
save_untouch_nii(Bilateral_PI_short_nii,[out_folder filesep 'Bilateral_PI_short.nii'])
clear Bilateral_PI_short_nii

Bilateral_MI_short_nii = nii_template;
Bilateral_MI_short_nii.img = Bilateral_MI_short;
save_untouch_nii(Bilateral_MI_short_nii,[out_folder filesep 'Bilateral_MI_short.nii'])
clear Bilateral_MI_short_nii

Bilateral_PI_long_nii = nii_template;
Bilateral_PI_long_nii.img = Bilateral_PI_long;
save_untouch_nii(Bilateral_PI_long_nii,[out_folder filesep 'Bilateral_PI_long.nii'])
clear Bilateral_PI_long_nii

%load all niftis and create a matrix with all 6 subregions
for i = 1:length(ROI_names_bilateral)

  seed_FC_map.(ROI_names_bilateral{i,1}) = load_nii([out_folder filesep ROI_names_bilateral{i,1} '.nii']);
   
end

% create maps of bilateral niftis for further correlations
for i = 1:length(ROI_names_bilateral)

 insula_FC.(ROI_names_bilateral{i,1}) = seed_FC_map.(ROI_names_bilateral{i,1}).img;

end

%apply QC vector to only keep participants who have passed QC
insula_FC.Bilateral_AI_long = insula_FC.Bilateral_AI_long(:,:,:,FC.qQC);
insula_FC.Bilateral_AI_short = insula_FC.Bilateral_AI_short(:,:,:,FC.qQC);
insula_FC.Bilateral_AI_pole = insula_FC.Bilateral_AI_pole(:,:,:,FC.qQC);
insula_FC.Bilateral_MI_short = insula_FC.Bilateral_MI_short(:,:,:,FC.qQC);
insula_FC.Bilateral_PI_long = insula_FC.Bilateral_PI_long(:,:,:,FC.qQC);
insula_FC.Bilateral_PI_short = insula_FC.Bilateral_PI_short(:,:,:,FC.qQC);

%% run nodewise correlation/regression for COVs
%get QCed factors for regression
%regress on age, sex, site, and motion
FC.Age = FC.Age(FC.qQC);
FC.Female = FC.Female(FC.qQC); 
FC.Site = FC.Site(FC.qQC);
FC.SubjectID = FC.SubjectID(FC.qQC);

motion = readtable(motion_file,'ReadVariableNames',true);
[logic.overall_ID, logic.motion_Ia, logic.motion_Ib] = intersect(FC.SubjectID, motion.SubjectID);
FC.FD =  motion.meanFD_Power(logic.motion_Ib);
clear motion

for i = 1:length(ROI_names_bilateral)%put here for memory reasons
   mask.(ROI_names_bilateral{i,1}) = insula_FC.(ROI_names_bilateral{i,1});  

end
clear seed_FC_map

%create structure with information about nan (=0) and non-nan (=1) for
%individual roi
for i = 1:length(ROI_names_bilateral)

  mask.(ROI_names_bilateral{i,1})(isnan(mask.(ROI_names_bilateral{i,1}))) = 0;
  mask.(ROI_names_bilateral{i,1})= mask.(ROI_names_bilateral{i,1}) ~=0;
  
end


 functional_image = load_untouch_nii([conn_matrices_folder filesep 'lPI_long_voxel_connectivity_zmap_sorted.nii']);
        nii_template = functional_image;
        nii_template.img = [];
        nii_template = rmfield(nii_template,'fileprefix');
        nii_template.hdr.dime.dim(1,5) = size(insula_FC.Bilateral_PI_long,4); % change header in 4th dimension to our QC reduced dataset

        clear functional_image
        
mask = mask.Bilateral_AI_long;

[x,y,z] = ind2sub([size(mask,1),size(mask,2),size(mask,3)],find(mask(:,:,:,1)));
activity_coordinates = [x,y,z];

subjects = size(FC.SubjectID, 1);

nID = sum(FC.qQC);

regress_FC = insula_FC;% so I don't have to overwrite the original file when regressed values are put in 


for i = 1:length(ROI_names_bilateral) %roi loop
    
    for j = 1:size(activity_coordinates,1) %mask loop
        
        %get values for roi for activity coordinate location 
        subset = insula_FC.(ROI_names_bilateral{i,1})(x(j),y(j),z(j),:); 
        
        FC_vec = squeeze(subset); 
       
        
        %correct FC for linear effects in age + sex + site + FD
        data.X = [ones(nID,1), (FC.Age - mean(FC.Age)), (FC.Female - mean(FC.Female)), (FC.Site - mean(FC.Site)), (FC.FD -mean(FC.FD))]; 
        [reg.b,reg.bint,reg.r,reg.rint,reg.stats] = regress(FC_vec,data.X); 

        
       %get values back in matrix and add intercept to each value
       intercept = reg.b(1);
       regress_FC.(ROI_names_bilateral{i,1})(x(j),y(j),z(j),:) =reg.r + intercept;
       
        clear data FC_vec mask subset reg 

    end
end


Bilateral_MI_short_nii = nii_template;
Bilateral_MI_short_nii.img = regress_FC.Bilateral_MI_short;
save_untouch_nii(Bilateral_MI_short_nii,[result_folder filesep 'Bilateral_MI_short_regress.nii'])
clear Bilateral_MI_short_nii

Bilateral_MI_short = regress_FC.Bilateral_MI_short;
save([result_folder, filesep,  'Bilateral_MI_short_regress.mat'],'Bilateral_MI_short', '-v7.3');

Bilateral_AI_short_nii = nii_template;
Bilateral_AI_short_nii.img = regress_FC.Bilateral_AI_short;
save_untouch_nii(Bilateral_AI_short_nii,[result_folder filesep 'Bilateral_AI_short_regress.nii'])
clear Bilateral_AI_short_nii

Bilateral_AI_short = regress_FC.Bilateral_AI_short;
save([result_folder, filesep,  'Bilateral_AI_short_regress.mat'],'Bilateral_AI_short', '-v7.3');

Bilateral_AI_long_nii = nii_template;
Bilateral_AI_long_nii.img = regress_FC.Bilateral_AI_long;
save_untouch_nii(Bilateral_AI_long_nii,[result_folder filesep 'Bilateral_AI_long_regress.nii'])
clear Bilateral_AI_long_nii

Bilateral_AI_long = regress_FC.Bilateral_AI_long;
save([result_folder, filesep,  'Bilateral_AI_long_regress.mat'],'Bilateral_AI_long', '-v7.3');

Bilateral_AI_pole_nii = nii_template;
Bilateral_AI_pole_nii.img = regress_FC.Bilateral_AI_pole;
save_untouch_nii(Bilateral_AI_pole_nii,[result_folder filesep 'Bilateral_AI_pole_regress.nii'])
clear Bilateral_AI_pole_nii

Bilateral_AI_pole = regress_FC.Bilateral_AI_pole;
save([result_folder, filesep,  'Bilateral_AI_pole_regress.mat'],'Bilateral_AI_pole', '-v7.3');

Bilateral_PI_long_nii = nii_template;
Bilateral_PI_long_nii.img = regress_FC.Bilateral_PI_long;
save_untouch_nii(Bilateral_PI_long_nii,[result_folder filesep 'Bilateral_PI_long_regress.nii'])
clear Bilateral_PI_long_nii

Bilateral_PI_long = regress_FC.Bilateral_PI_long;
save([result_folder, filesep,  'Bilateral_PI_long_regress.mat'],'Bilateral_PI_long', '-v7.3');

Bilateral_PI_short_nii = nii_template;
Bilateral_PI_short_nii.img = regress_FC.Bilateral_PI_short;
save_untouch_nii(Bilateral_PI_short_nii,[result_folder filesep 'Bilateral_PI_short_regress.nii'])
clear Bilateral_PI_short_nii

Bilateral_PI_short = regress_FC.Bilateral_PI_short;
save([result_folder, filesep,  'Bilateral_PI_short_regress.mat'],'Bilateral_PI_short', '-v7.3');

load([result_folder filesep 'Bilateral_MI_short_regress.mat'])
load([result_folder filesep 'Bilateral_AI_short_regress.mat'])
load([result_folder filesep 'Bilateral_AI_long_regress.mat'])
load([result_folder filesep 'Bilateral_AI_pole_regress.mat'])
load([result_folder filesep 'Bilateral_PI_short_regress.mat'])
load([result_folder filesep 'Bilateral_PI_long_regress.mat'])


regress_FC.Bilateral_AI_pole =Bilateral_AI_pole;
regress_FC.Bilateral_AI_long =Bilateral_AI_long;
regress_FC.Bilateral_PI_long =Bilateral_PI_long;
regress_FC.Bilateral_AI_short =Bilateral_AI_short;
regress_FC.Bilateral_PI_short =Bilateral_PI_short;
regress_FC.Bilateral_MI_short =Bilateral_MI_short;

clear Bilateral_AI_long Bilateral_AI_pole Bilateral_AI_short Bilateral_MI_short Bilateral_PI_short Bilateral_PI_long activity coordinates x y z intercept
clear FC_vec

%%
for i = 1:length(ROI_names_bilateral)

  mean_insula_FC_regress.(ROI_names_bilateral{i,1}) = nanmean(regress_FC.(ROI_names_bilateral{i,1}) , 4);

end

% Save mean images
save([out_folder filesep 'mean_insula_FC_regress.mat'],'mean_insula_FC_regress')
save([out_folder filesep 'Insula_FC.mat'],'insula_FC')

load([out_folder filesep 'mean_insula_FC.mat'])
load([out_folder filesep 'Insula_FC.mat'])

% Run through ROIs, vectorize matrices and correlate
AI_short = [];
AI_long = [];
AI_pole = [];
MI_short = [];
PI_short = [];
PI_long = [];

clear Bilateral_AI_pole_nii Bilateral_AI_short_nii Bilateral_PI_short_test functional_image nii_template rAI_pole-voxel_connectivity_zmap_sorted
clear rAI_pole_voxel_connectivity_zmap_sorted lAI_pole_voxel_connectivity_zmap_sorted


%correlate 
for i = 1:length(ROI_names_bilateral)
 
 for subjects = 1:size(regress_FC.(ROI_names_bilateral{i,1}), 4)
        subset = regress_FC.(ROI_names_bilateral{i,1})(:,:,:, subjects); 
        subject_vector = subset (:);
        
        

    for j = 1:length(ROI_names_bilateral)
            
        vector_2 = mean_insula_FC_regress.(ROI_names_bilateral{j,1})(:);
        ROI_corr = corr(subject_vector, vector_2, 'rows','complete');
        save([out_folder filesep 'ROI_corr.mat'],'ROI_corr')

        switch i

            case 1

                AI_short = [AI_short;ROI_corr];

            case 2

                AI_long = [AI_long;ROI_corr];

            case 3

                AI_pole = [AI_pole;ROI_corr];

            case 4

                MI_short = [MI_short;ROI_corr];

            case 5

                PI_short = [PI_short;ROI_corr];

            case 6

                PI_long = [PI_long;ROI_corr];
            
        end

        clear ROI_corr vector_2
    end
   clear subset_vector 
 end
end

%add atanh here
untransf_subj_sim.AI_long =AI_long;
untransf_subj_sim.AI_short = AI_short;
untransf_subj_sim.PI_short = PI_short;
untransf_subj_sim.AI_pole = AI_pole;
untransf_subj_sim.PI_long = PI_long;
untransf_subj_sim.MI_short = MI_short;
save([out_folder filesep 'untransf_subj_sim.mat'],'untransf_subj_sim')


subj_sim.AI_long = atanh(AI_long);
subj_sim.AI_short = atanh(AI_short);
subj_sim.PI_short = atanh(PI_short);
subj_sim.AI_pole = atanh(AI_pole);
subj_sim.PI_long = atanh(PI_long);
subj_sim.MI_short = atanh(MI_short);
save([out_folder filesep 'subj_sim.mat'],'subj_sim')


load([out_folder filesep 'subj_sim.mat'],'subj_sim')

%create empty table to fill in loop later
headers = {'Subj_ID', 'Sub_A', 'Sub_B', 'within', 'atanh', 'Group'};
data = cell(30600, 6); %dimensions of table 
T_insula = cell2table(data);
T_insula.Properties.VariableNames =headers;
T_insula.atanh = zeros(30600,1);% make atanh into double and NOT cell

test = subject_IDs_num(FC.qQC); %apply logical on sorted subjects
subject_IDs_run= repelem(test,36, 1); %repeat elements of table
T_insula.Subj_ID = subject_IDs_run; 


group = FC.Group(FC.qQC);  %group vector, MDD=1, HC=0
group_num= repelem(group,36, 1);
T_insula.Group = [group_num];


sub_A = 1:6;
sub_A =sub_A(:);
sub_A_long= repelem(sub_A,6, 1); %stretch elements of matrix 
sub_A_end = repmat(sub_A_long, 850, 1); %stretch whole matrix
T_insula.Sub_A =sub_A_end;
clear sub_A_long sub_A

sub_B = 1:6;
sub_B =sub_B(:);
sub_B_end = repmat(sub_B, 5100, 1);
T_insula.Sub_B =sub_B_end;
clear sub_B

same_logical = (T_insula.Sub_A == T_insula.Sub_B); %create logical for when sub a = sub B
same = double(same_logical); %change logical to vector
T_insula.within = same;
clear same_logical


%create loop to take correlations from individual ROI in subj_sim and put
%it in T.atanh

 entry_counter = 1;
for subjects_corr = 1:(size(subj_sim.AI_long, 1)/length(ROI_corr_names))
    
    %create subject loop that changes after 6 subregions to next subject
    for j = 1:length(ROI_corr_names)
        
        for counter = 1:length(ROI_corr_names) %counter to change to next roi after 6 results from one ROI
            
            T_insula.atanh(entry_counter) = subj_sim.(ROI_corr_names{1,j})(((subjects_corr-1)*6)+counter,1); %uses subject loop 
            entry_counter = entry_counter + 1;
            
        end
  
   
    end
    
    
end  

aic = ((T_insula.Sub_A == 1) & (T_insula.Sub_B ==1) | (T_insula.Sub_A == 1) & (T_insula.Sub_B ==3) | (T_insula.Sub_A == 1) & (T_insula.Sub_B ==4)|(T_insula.Sub_A == 3) & (T_insula.Sub_B ==1) | (T_insula.Sub_A == 3) & (T_insula.Sub_B ==3) | (T_insula.Sub_A == 4) & (T_insula.Sub_B ==4)|(T_insula.Sub_A == 4) & (T_insula.Sub_B ==1) | (T_insula.Sub_A == 4) & (T_insula.Sub_B ==3) | (T_insula.Sub_A == 4) & (T_insula.Sub_B ==4)); %create logical for when within AIC
aic2 = double(aic); %change logical to vector
pic = ((T_insula.Sub_A == 2) & (T_insula.Sub_B ==2) | (T_insula.Sub_A == 2) & (T_insula.Sub_B ==5) | (T_insula.Sub_A == 2) & (T_insula.Sub_B ==6)|(T_insula.Sub_A == 5) & (T_insula.Sub_B ==2) | (T_insula.Sub_A == 5) & (T_insula.Sub_B ==5) | (T_insula.Sub_A == 5) & (T_insula.Sub_B ==6)|(T_insula.Sub_A == 6) & (T_insula.Sub_B ==2) | (T_insula.Sub_A == 6) & (T_insula.Sub_B ==5) | (T_insula.Sub_A == 6) & (T_insula.Sub_B ==6)); %create logical for when within PIC
pic2 = double(pic);
pic2(pic2 ==1) =2;
region = zeros(30600,1);

region(aic2 ==1) =1;
region(pic2 ==2) =2;
region(region ==0) = 0;
region = array2table(region);
T_insula = [T_insula, region];
T_insula.region =region;

%write out similarity results
save([result_folder filesep 'T_insula.mat'],'T_insula')
writetable(T_insula, 'T_insula.csv')
save([result_folder filesep 'T_insula.csv'],'T_insula')
