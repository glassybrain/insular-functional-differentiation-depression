% Similarity correlation for individuals subjects in temporal cortex regions
%%% Calculates the similarity of temporal cortex (control region) subregional FC profiles
%%% for every participant
%%% 1. Averages left and right seed-to-voxel z-maps (output of '1 - Functional connectivity')
%%%    to obtain bilateral FC maps of the 6 temporal subregions
%%% 2. Keeps participants who passed quality control (FC.qQC) and regresses the FC maps
%%%    voxel-wise on age, sex, site and motion (mean framewise displacement); residuals plus
%%%    intercept are saved as Bilateral_*_regress.nii/.mat (also used in '5 - Shift function')
%%% 3. Averages the residualised maps across all participants (sample FC map per subregion)
%%%    and correlates (Pearson) every participant's subregional FC map with each of the six
%%%    sample FC maps; correlations are Fisher z-transformed (atanh)
%%% 4. Writes the long-format table T_temporal (one row per participant x subregion pair)
%%%    with the columns Subj_ID, Sub_A, Sub_B, within, atanh, Group (MDD = 1, HCP = 0) and
%%%    region (0 = between, 1 = anterior-within, 2 = posterior-within)
%%% Subregion codes: 1 = AT medial (TL medial), 2 = AT lateral (TL lateral),
%%% 3 = ST middle (STG middle), 4 = MIT (ITG middle), 5 = PT (TL posterior), 6 = aSTG (STGa)
%%% See 'Calculation of resting state functional connectivity' and 'Similarity calculations'
%%% in the Methods.
%%% Requires: MATLAB (Statistics and Machine Learning Toolbox), NIfTI toolbox

clear all
clc

%% USER SETTINGS: adjust the paths below to your local system
% root folder
Voxel_Conn_data_folder = '/path/to/smoothed_Seed_Voxel_Connectivity';   % seed-to-voxel z-maps of the temporal subregions (output of '1 - Functional connectivity')
result_folder = '/path/to/results_similarities_individual_subjects';   % output folder for the residualised FC maps and T_temporal
inter_folder = '/path/to/PsyMRI_Temporal_Analysis';   % not used in this script
test_folder = '/path/to/Bilateral_temporal_FC';   % output folder for bilateral FC maps, mean maps and similarity values
subject_IDs_file = '/path/to/subject_IDs_sorted';   % sorted subject IDs (subject_IDs_num)
covariates_file = '/path/to/PsyMRI_Covariates';   % covariate table of the FOR2107 sample
QC_file = '/path/to/FC';   % FC.mat (QC vector and covariates; output of '0 - Preprocessing/4 - Create_covariates_for_exclusion.m')
motion_file = '/path/to/FD_HM.xlsx';   % mean framewise displacement per participant


% Load subject information
load(subject_IDs_file)
load(covariates_file)

%load QC vector
load(QC_file)


ROI_names_bilateral = {'Bilateral_AT_medial';'Bilateral_AT_lateral';'Bilateral_ST_middle';'Bilateral_MIT';'Bilateral_PT';'Bilateral_aSTG'};
ROI_corr_names = {'AT_medial', 'AT_lateral', 'ST_middle', 'MIT', 'PT', 'aSTG'};


%1. Generate bilateral from unilateral data
% Generate mean ROI maps
lAT_medial_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'lAT_medial_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lAT_medial_voxel_connectivity_zmap_sorted.img;
rAT_medial_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'rAT_medial_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rAT_medial_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_AT_medial = ROI_map_bilateral;
clear lAT_medial_voxel_connectivity_zmap_sorted rAT_medial_voxel_connectivity_zmap_sorted

lAT_lateral_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'lAT_lateral_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lAT_lateral_voxel_connectivity_zmap_sorted.img;
rAT_lateral_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'rAT_lateral_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rAT_lateral_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_AT_lateral = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lAT_lateral_voxel_connectivity_zmap_sorted rAT_lateral_voxel_connectivity_zmap_sorted

lST_middle_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'lST_middle_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lST_middle_voxel_connectivity_zmap_sorted.img;
rST_middle_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'rST_middle_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rST_middle_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_ST_middle = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lST_middle_voxel_connectivity_zmap_sorted rST_middle_voxel_connectivity_zmap_sorted

lMIT_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'lMIT_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lMIT_voxel_connectivity_zmap_sorted.img;
rMIT_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'rMIT_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rMIT_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_MIT = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lMIT_voxel_connectivity_zmap_sorted rMIT_voxel_connectivity_zmap_sorted

lPT_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'lPT_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = lPT_voxel_connectivity_zmap_sorted.img;
rPT_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'rPT_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = rPT_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_PT = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear lPT_voxel_connectivity_zmap_sorted rPT_voxel_connectivity_zmap_sorted

laSTG_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'laSTG_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,1) = laSTG_voxel_connectivity_zmap_sorted.img;
raSTG_voxel_connectivity_zmap_sorted = load_nii([Voxel_Conn_data_folder filesep 'raSTG_voxel_connectivity_zmap_sorted.nii']);
ROI_map(:,:,:,:,2) = raSTG_voxel_connectivity_zmap_sorted.img;
ROI_map_bilateral = nanmean(ROI_map,5);
Bilateral_aSTG = ROI_map_bilateral;
clear ROI_map ROI_map_bilateral
clear laSTG_voxel_connectivity_zmap_sorted raSTG_voxel_connectivity_zmap_sorted


%write bilaterals back to NIFTI for further use
 %set a NIFTI template with existing NIFTI with the same size first
   functional_image = load_untouch_nii([Voxel_Conn_data_folder filesep 'laSTG_voxel_connectivity_zmap_sorted.nii']);
        nii_template = functional_image;
        nii_template.img = [];
        nii_template = rmfield(nii_template,'fileprefix');
        nii_template.hdr.dime.dim(1,5) = size(Bilateral_aSTG,4); % change header in 4th dimension to our QC reduced dataset

        clear functional_image
        
Bilateral_AT_medial_nii = nii_template;
Bilateral_AT_medial_nii.img = Bilateral_AT_medial;
save_untouch_nii(Bilateral_AT_medial_nii,[test_folder filesep 'Bilateral_AT_medial.nii'])
clear Bilateral_AT_medial_nii 

Bilateral_AT_lateral_nii = nii_template;
Bilateral_AT_lateral_nii.img = Bilateral_AT_lateral;
save_untouch_nii(Bilateral_AT_lateral_nii,[test_folder filesep 'Bilateral_AT_lateral.nii'])
clear Bilateral_AT_lateral_nii 


Bilateral_ST_middle_nii = nii_template;
Bilateral_ST_middle_nii.img = Bilateral_ST_middle;
save_untouch_nii(Bilateral_ST_middle_nii,[test_folder filesep 'Bilateral_ST_middle.nii'])
clear Bilateral_ST_middle_nii 

Bilateral_PT_nii = nii_template;
Bilateral_PT_nii.img = Bilateral_PT;
save_untouch_nii(Bilateral_PT_nii,[test_folder filesep 'Bilateral_PT.nii'])
clear Bilateral_PT_nii

Bilateral_MIT_nii = nii_template;
Bilateral_MIT_nii.img = Bilateral_MIT;
save_untouch_nii(Bilateral_MIT_nii,[test_folder filesep 'Bilateral_MIT.nii'])
clear Bilateral_MIT_nii

Bilateral_aSTG_nii = nii_template;
Bilateral_aSTG_nii.img = Bilateral_aSTG;
save_untouch_nii(Bilateral_aSTG_nii,[test_folder filesep 'Bilateral_aSTG.nii'])
clear Bilateral_aSTG_nii


%load all niftis and create a matrix with all 6 subregions
for i = 1:length(ROI_names_bilateral)

  seed_FC_map.(ROI_names_bilateral{i,1}) = load_nii([test_folder filesep ROI_names_bilateral{i,1} '.nii']);
   
end


% create maps of bilateral niftis for further correlations
for i = 1:length(ROI_names_bilateral)

 temporal_FC.(ROI_names_bilateral{i,1}) = seed_FC_map.(ROI_names_bilateral{i,1}).img;

end

%apply QC vector to only keep participants who have passed QC
temporal_FC.Bilateral_AT_medial = temporal_FC.Bilateral_AT_medial(:,:,:,FC.qQC);
temporal_FC.Bilateral_AT_lateral = temporal_FC.Bilateral_AT_lateral(:,:,:,FC.qQC);
temporal_FC.Bilateral_ST_middle = temporal_FC.Bilateral_ST_middle(:,:,:,FC.qQC);
temporal_FC.Bilateral_MIT = temporal_FC.Bilateral_MIT(:,:,:,FC.qQC);
temporal_FC.Bilateral_PT = temporal_FC.Bilateral_PT(:,:,:,FC.qQC);
temporal_FC.Bilateral_aSTG = temporal_FC.Bilateral_aSTG(:,:,:,FC.qQC);

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
   mask.(ROI_names_bilateral{i,1}) = temporal_FC.(ROI_names_bilateral{i,1});  

end
clear seed_FC_map

%create structure with information about nan (=0) and non-nan (=1) for
%individual roi
for i = 1:length(ROI_names_bilateral)

  mask.(ROI_names_bilateral{i,1})(isnan(mask.(ROI_names_bilateral{i,1}))) = 0;
  mask.(ROI_names_bilateral{i,1})= mask.(ROI_names_bilateral{i,1}) ~=0;
  
end


 functional_image = load_untouch_nii([Voxel_Conn_data_folder filesep 'laSTG_voxel_connectivity_zmap_sorted.nii']);
        nii_template = functional_image;
        nii_template.img = [];
        nii_template = rmfield(nii_template,'fileprefix');
        nii_template.hdr.dime.dim(1,5) = size(temporal_FC.Bilateral_AT_medial,4); % change header in 4th dimension to our QC reduced dataset

        clear functional_image

[x,y,z] = ind2sub([size(mask.Bilateral_AT_medial,1),size(mask.Bilateral_AT_medial,2),size(mask.Bilateral_AT_medial,3)],find(mask.Bilateral_AT_medial(:,:,:,1)));
activity_coordinates = [x,y,z];

mask = mask.Bilateral_AT_medial(:,:,:,1);
save([test_folder, filesep,  'mask.mat'],'mask');

subjects = size(FC.SubjectID, 1);
regress_temporal_FC  = temporal_FC;

nID = sum(FC.qQC);
for i = 1:length(ROI_names_bilateral) %roi loop
    
    for j = 1:size(activity_coordinates,1) %mask loop
        
        %%get values for one roi for activity coordinate location 
        subset = temporal_FC.(ROI_names_bilateral{i,1})(x(j),y(j),z(j),:); 
      
        FC_vec = squeeze(subset);
       
        
        %correct FC for linear effects in age + sex + site + FD
        data.X = [ones(nID,1), (FC.Age - mean(FC.Age)), (FC.Female - mean(FC.Female)), (FC.Site - mean(FC.Site)), (FC.FD -mean(FC.FD))]; 
        [reg.b,reg.bint,reg.r,reg.rint,reg.stats] = regress(FC_vec,data.X); 

        
        %get values back in matrix and add intercept to each value
        intercept = reg.b(1);
        regress_temporal_FC_test.(ROI_names_bilateral{i,1})(x(j),y(j),z(j),:) =reg.r + intercept;
        clear data %subset FC_vec mask reg 

    end
end


Bilateral_AT_medial_nii = nii_template;
Bilateral_AT_medial_nii.img = regress_temporal_FC.Bilateral_AT_medial;
save_untouch_nii(Bilateral_AT_medial_nii,[result_folder filesep 'Bilateral_AT_medial_regress.nii'])
clear Bilateral_AT_medial_nii

Bilateral_AT_medial = regress_temporal_FC.Bilateral_AT_medial;
save([result_folder, filesep,  'Bilateral_AT_medial_regress.mat'],'Bilateral_AT_medial', '-v7.3');

Bilateral_AT_lateral_nii = nii_template;
Bilateral_AT_lateral_nii.img = regress_temporal_FC.Bilateral_AT_lateral;
save_untouch_nii(Bilateral_AT_lateral_nii,[result_folder filesep 'Bilateral_AT_lateral_regress.nii'])
clear Bilateral_AT_lateral_nii

Bilateral_AT_lateral = regress_temporal_FC.Bilateral_AT_lateral;
save([result_folder, filesep,  'Bilateral_AT_lateral_regress.mat'],'Bilateral_AT_lateral', '-v7.3');

Bilateral_ST_middle_nii = nii_template;
Bilateral_ST_middle_nii.img = regress_temporal_FC.Bilateral_ST_middle;
save_untouch_nii(Bilateral_ST_middle_nii,[result_folder filesep 'Bilateral_ST_middle_regress.nii'])
clear Bilateral_ST_middle_nii

Bilateral_ST_middle = regress_temporal_FC.Bilateral_ST_middle;
save([result_folder, filesep,  'Bilateral_ST_middle_regress.mat'],'Bilateral_ST_middle',  '-v7.3');

Bilateral_MIT_nii = nii_template;
Bilateral_MIT_nii.img = regress_temporal_FC.Bilateral_MIT;
save_untouch_nii(Bilateral_MIT_nii,[result_folder filesep 'Bilateral_MIT_regress.nii'])
clear Bilateral_MIT_nii

Bilateral_MIT = regress_temporal_FC.Bilateral_MIT;
save([result_folder, filesep,  'Bilateral_MIT_regress.mat'],'Bilateral_MIT',  '-v7.3');

Bilateral_PT = nii_template;
Bilateral_PT.img = regress_temporal_FC.Bilateral_PT;
save_untouch_nii(Bilateral_PT,[result_folder filesep 'Bilateral_PT_regress.nii'])
clear Bilateral_PT_nii

Bilateral_PT = regress_temporal_FC.Bilateral_PT;
save([result_folder, filesep,  'Bilateral_PT_regress.mat'],'Bilateral_PT', '-v7.3');

Bilateral_aSTG_nii = nii_template;
Bilateral_aSTG_nii.img = regress_temporal_FC.Bilateral_aSTG;
save_untouch_nii(Bilateral_aSTG_nii,[result_folder filesep 'Bilateral_aSTG_regress.nii'])
clear Bilateral_aSTG_nii

Bilateral_aSTG = regress_temporal_FC.Bilateral_aSTG;
save([result_folder, filesep,  'Bilateral_aSTG_regress.mat'],'Bilateral_aSTG', '-v7.3');

load([result_folder filesep 'Bilateral_MIT_regress.mat'])
load([result_folder filesep 'Bilateral_ST_middle_regress.mat'])
load([result_folder filesep 'Bilateral_AT_lateral_regress.mat'])
load([result_folder filesep 'Bilateral_AT_medial_regress.mat'])
load([result_folder filesep 'Bilateral_PT_regress.mat'])
load([result_folder filesep 'Bilateral_aSTG_regress.mat'])

regress_temporal_FC.Bilateral_MIT =Bilateral_MIT;
regress_temporal_FC.Bilateral_ST_middle =Bilateral_ST_middle;
regress_temporal_FC.Bilateral_PT =Bilateral_PT;
regress_temporal_FC.Bilateral_AT_lateral =Bilateral_AT_lateral;
regress_temporal_FC.Bilateral_aSTG =Bilateral_aSTG;
regress_temporal_FC.Bilateral_AT_medial =Bilateral_AT_medial;

clear Bilateral_AT_medial Bilateral_AT_lateral Bilateral_aSTG Bilateral_MIT Bilateral_PT Bilateral_ST_middle activity coordinates x y z intercept
clear FC_vec

%%
for i = 1:length(ROI_names_bilateral)

  mean_temporal_FC_regress.(ROI_names_bilateral{i,1}) = nanmean(regress_temporal_FC.(ROI_names_bilateral{i,1}) , 4);

end

% Save mean images
save([test_folder filesep 'mean_temporal_FC_regress.mat'],'mean_temporal_FC_regress')
save([test_folder filesep 'Temporal_FC.mat'],'temporal_FC')

load([test_folder filesep 'mean_temporal_FC_regress.mat'])
load([test_folder filesep 'Temporal_FC.mat'])

% Run through ROIs, vectorize matrices and correlate
AT_medial = [];
AT_lateral = [];
ST_middle = [];
MIT = [];
PT = [];
aSTG = [];

clear regress_FC_temporal_test

%correlate 
for i = 1:length(ROI_names_bilateral)
 
 for subjects = 1:size(regress_temporal_FC.(ROI_names_bilateral{i,1}), 4)
        subset = regress_temporal_FC.(ROI_names_bilateral{i,1})(:,:,:, subjects); 
        subject_vector = subset (:);
        

    for j = 1:length(ROI_names_bilateral)
            
        vector_2 = mean_temporal_FC_regress.(ROI_names_bilateral{j,1})(:);            
        ROI_corr = corr(subject_vector, vector_2, 'rows','complete');
        save([test_folder filesep 'ROI_corr.mat'],'ROI_corr')

        switch i

            case 1

                AT_medial = [AT_medial;ROI_corr];

            case 2

                AT_lateral = [AT_lateral;ROI_corr];

            case 3

                ST_middle = [ST_middle;ROI_corr];

            case 4

                MIT = [MIT;ROI_corr];

            case 5

                PT = [PT;ROI_corr];

            case 6

                aSTG = [aSTG;ROI_corr];
            
        end

        clear ROI_corr vector_2
    end
   clear subset_vector 
 end
end


untransf_subj_sim.AT_lateral = AT_lateral;
untransf_subj_sim.AT_medial = AT_medial;
untransf_subj_sim.PT = PT;
untransf_subj_sim.ST_middle = ST_middle;
untransf_subj_sim.aSTG = aSTG;
untransf_subj_sim.MIT = MIT;
save([test_folder filesep 'unfransf_subj_sim.mat'],'untransf_subj_sim')

subj_sim.AT_lateral = AT_lateral;
subj_sim.AT_medial = AT_medial;
subj_sim.PT = PT;
subj_sim.ST_middle = ST_middle;
subj_sim.aSTG = aSTG;
subj_sim.MIT = MIT;
save([test_folder filesep 'subj_sim.mat'],'subj_sim')

load([test_folder filesep 'subj_sim.mat'])

%create empty table to fill in loop later
clear T
headers = {'Subj_ID', 'Sub_A', 'Sub_B', 'within', 'atanh', 'Group'};
data = cell(30600, 6); %dimensions of table 
T_temporal = cell2table(data);
T_temporal.Properties.VariableNames =headers;
T_temporal.atanh = zeros(30600,1); % make atanh into double and NOT cell

test = subject_IDs_num(FC.qQC); %apply logical on sorted subjects
subject_IDs_run= repelem(test,36, 1); %repeat elements of table
T_temporal.Subj_ID = subject_IDs_run; 


group = FC.Group(FC.qQC);  %group vector, MDD=1, HC=0
group_num= repelem(group,36, 1);
T_temporal.Group = group_num;


sub_A = 1:6;
sub_A =sub_A(:);
sub_A_long= repelem(sub_A,6, 1); %stretch elements of matrix 
sub_A_end = repmat(sub_A_long, 850, 1); %stretch whole matrix
T_temporal.Sub_A =sub_A_end;
clear sub_A_long sub_A

sub_B = 1:6;
sub_B =sub_B(:);
sub_B_end = repmat(sub_B, 5100, 1);
T_temporal.Sub_B =sub_B_end;
clear sub_B

same_logical = (T_temporal.Sub_A == T_temporal.Sub_B); %create logical for when sub a = sub B
same = double(same_logical); %change logical to vector
T_temporal.within = same;
clear same_logical


%create loop to take correlations from individual ROI in subj_sim and put
%it in T.atanh
entry_counter = 1;
for subjects_corr = 1:(size(subj_sim.AT_medial, 1)/length(ROI_corr_names))
    
    %create subject loop that changes after 6 subregions to next subject
    for j = 1:length(ROI_corr_names)
        
        for counter = 1:length(ROI_corr_names) %counter to change to next roi after 6 results from one ROI
            
            T_temporal.atanh(entry_counter) = subj_sim.(ROI_corr_names{1,j})(((subjects_corr-1)*6)+counter,1); %uses subject loop 
            entry_counter = entry_counter + 1;
            
        end
  
   
    end
    
    
end  

a_temporal = ((T_temporal.Sub_A == 1) & (T_temporal.Sub_B ==1) | (T_temporal.Sub_A == 1) & (T_temporal.Sub_B ==2) | (T_temporal.Sub_A == 1) & (T_temporal.Sub_B ==6)|(T_temporal.Sub_A == 2) & (T_temporal.Sub_B ==1) | (T_temporal.Sub_A == 2) & (T_temporal.Sub_B ==2) | (T_temporal.Sub_A == 2) & (T_temporal.Sub_B ==6)|(T_temporal.Sub_A == 6) & (T_temporal.Sub_B ==1) | (T_temporal.Sub_A == 6) & (T_temporal.Sub_B ==2) | (T_temporal.Sub_A == 6) & (T_temporal.Sub_B ==6)); %create logical for when within AT
a_temporal2 = double(a_temporal); %change logical to vector
p_temporal = ((T_temporal.Sub_A == 3) & (T_temporal.Sub_B ==3) | (T_temporal.Sub_A == 3) & (T_temporal.Sub_B ==4) | (T_temporal.Sub_A == 3) & (T_temporal.Sub_B ==5)|(T_temporal.Sub_A == 4) & (T_temporal.Sub_B ==3) | (T_temporal.Sub_A == 4) & (T_temporal.Sub_B ==4) | (T_temporal.Sub_A == 5) & (T_temporal.Sub_B ==5)|(T_temporal.Sub_A == 5) & (T_temporal.Sub_B ==3) | (T_temporal.Sub_A == 5) & (T_temporal.Sub_B ==4) | (T_temporal.Sub_A == 5) & (T_temporal.Sub_B ==5)); %create logical for when within PT
p_temporal2 = double(p_temporal);
p_temporal2(p_temporal2 ==1) =2;
region = zeros(30600,1);

region(a_temporal2 ==1) =1;
region(p_temporal2 ==2) =2;
region = array2table(region);
T_temporal = [T_temporal, region];
T_temporal.region = region;

%write out similarity results
save([result_folder filesep 'T_temporal.mat'],'T_temporal')
writetable(T_temporal, 'T_temporal.csv')
save([result_folder filesep 'T_temporal.csv'],'T_temporal')
