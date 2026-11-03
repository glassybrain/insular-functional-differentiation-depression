%%% Load FC maps and residualise site, age, sex, and motion 
%%% Calculate AIC/PIC similarity and compare between HCP and MDD
%%% Run full factorial model including the factors Group (MDD, HCP) and Subregion (AIC, PIC) based on residualised FC maps
%%% Details:
%%% - AIC map = mean of the bilateral AI short, AI pole and MI short FC maps;
%%%   PIC map = mean of the bilateral AI long, PI short and PI long FC maps
%%% - Only participants who passed QC (FC.qQC) are included; maps are split by group and
%%%   residualised voxel-wise for age, sex, site and mean framewise displacement
%%% - AIC-PIC similarity (Pearson r, Fisher z-transformed) is compared between groups
%%%   (Figure 2D) and exported to Similarity_AIC_PIC_Groups.csv
%%% - Full factorial model (SPM25) with Group (2 levels, independent) x Subregion (2 levels,
%%%   dependent) and t-contrasts for the main effects and the interaction (Figure 2A-B)
%%% - Extraction of the voxel-wise T values of the main effect of Subregion and of the
%%%   interaction within the model mask (factorial_model_FC_*_vectorized.csv; Figure 2C)
%%% See 'Identification of insular FC profiles that are modulated by Group' in the Methods.
%%% Requires: MATLAB (Statistics and Machine Learning Toolbox), SPM25, NIfTI toolbox

%% USER SETTINGS: adjust the paths below to your local system
covariates_file = '/path/to/Covariates_for_exclusion.mat';   % FC structure with QC vector and covariates (cf. '0 - Preprocessing/4 - Create_covariates_for_exclusion.m')
sort_idx_file = '/path/to/subject_ID_sort_idx.mat';   % index used to sort participants by subject ID (subjects_IDs_sort_idx)
subjects_order_file = '/path/to/subjects_order.mat';   % subject IDs in the order of the seed-to-voxel z-maps (subjects_order)
motion_file = '/path/to/FD_HM.xlsx';   % mean framewise displacement per participant
nii_out_folder = '/path/to/AIC_PIC_HC_MDD_FC_maps';   % output folder for the AIC/PIC FC maps per group
similarity_csv_file = '/path/to/Similarity_AIC_PIC_Groups.csv';   % output file with AIC-PIC similarity per participant
save_folder = '/path/to/SPM full factorial model group subregion';   % output folder for the SPM model
spm_model_folder = '/path/to/SPM full factorial model group subregion';   % folder with spmT_0007.nii (main effect Subregion), spmT_0008.nii (interaction Group x Subregion) and mask.nii of the full factorial model
vectorized_csv_folder = '/path/to/3 - AIC_PIC_Analysis';   % output folder for the vectorized T maps (input of Plot_factorial_model_main_interaction.R)

% Load covariates
load(covariates_file)

%% Set up folders
Conn_folder_root = '/path/to/AI_Analysis_MDD_HC';   % not used in this script
Voxel_Conn_data_folder = '/path/to/Connectivity';   % seed-to-voxel z-maps of the insular subregions (output of '1 - Functional connectivity')

ROI_filenames = {'lAI_short';'rAI_short';'lAI_long';'rAI_long';'lAI_pole';'rAI_pole';'lI_middle';'rI_middle';'lPI_short';'rPI_short';'lPI_long';'rPI_long'};
ROI_folder_names = {'l_AI_short'; 'r_AI_short';'l_AI_long';'r_AI_long';'l_AI_pole';'r_AI_pole';'l_MI_short';'r_MI_short';'l_PI_short';'r_PI_short';'l_PI_long';'r_PI_long'};

% Load subject information
load(sort_idx_file)
load(subjects_order_file)
subjects_order_sorted = subjects_order(subjects_IDs_sort_idx);

% Average ROIs for anterior (AI short, AI pole, MI) and posterior insular
% cortex (PI short, AI long, PI long)

AIC_count = 1;
PIC_count = 1;

for ROI_num = 1:2:12

    count_included = 1;

    % Choose subjects with prior quality control -> only include
    % subjects with a mean z-standardized connectivity of below 0.2 who
    % haven't been scanned with a bodycoil
    seed_FC_map_ROI1 = load_nii([Voxel_Conn_data_folder filesep ROI_filenames{ROI_num,1} '_voxel_connectivity_zmap_sorted.nii']);
    seed_FC_map_ROI2 = load_nii([Voxel_Conn_data_folder filesep ROI_filenames{ROI_num+1,1} '_voxel_connectivity_zmap_sorted.nii']);
    seed_FC_map(:,:,:,:,1) = seed_FC_map_ROI1.img;
    seed_FC_map(:,:,:,:,2) = seed_FC_map_ROI2.img;
    
    clear seed_FC_map_ROI1 seed_FC_map_ROI2

    if ROI_num == 1 || ROI_num == 5 || ROI_num == 7

        Bilateral_ROI_FC_maps_AIC(:,:,:,:,AIC_count) = nanmean(seed_FC_map,5);
        AIC_count = AIC_count +1;

    else

        Bilateral_ROI_FC_maps_PIC(:,:,:,:,PIC_count) = nanmean(seed_FC_map,5);
        PIC_count = PIC_count +1;

    end

end

% Create average maps for AIC and PIC
% Use mean function here instead of nanmean as all subjects have the same
% non-nan voxels in all ROIs and nanmean leads to error where all
% voxels are NaN
AIC_bilateral_FC = mean(Bilateral_ROI_FC_maps_AIC,5);
PIC_bilateral_FC = mean(Bilateral_ROI_FC_maps_PIC,5);

% Divide into HCs and MDDs
% Use QC vector to select sample
countHC = 1;
countMDD = 1;

for subjects = 1:size(AIC_bilateral_FC,4)

    lst_idx = FC.SubjectID == str2num(subjects_order_sorted{subjects});

    if sum(lst_idx) == 1

        if FC.Group(lst_idx) == 0 && FC.qQC(lst_idx) == 1 % HC & passed QC
    
            % Get FC and write to image
            subset_AIC = AIC_bilateral_FC(:,:,:,subjects);
            subset_PIC = PIC_bilateral_FC(:,:,:,subjects);
            
            AIC_bilateral_FC_HC(:,:,:,countHC) = subset_AIC;
            PIC_bilateral_FC_HC(:,:,:,countHC) = subset_PIC;
            %AIC_PIC_bilateral_HC_SubjID(countHC) = Covariates.SubjectID(lst_idx);
            countHC = countHC + 1;
    
            clear subset_AIC subset_PIC
    
        elseif FC.Group(lst_idx) == 1 && FC.qQC(lst_idx) == 1 % MDD & passed QC
    
            % Get FC and write to image
            subset_AIC = AIC_bilateral_FC(:,:,:,subjects);
            subset_PIC = PIC_bilateral_FC(:,:,:,subjects);
                
            AIC_bilateral_FC_MDD(:,:,:,countMDD) = subset_AIC;
            PIC_bilateral_FC_MDD(:,:,:,countMDD) = subset_PIC;
            %AIC_PIC_bilateral_MDD_SubjID(countMDD) = Covariates.SubjectID(lst_idx);
            countMDD = countMDD + 1;
    
            clear subset_AIC subset_PIC
    
        end

    end

end


% Clean RAM
clearvars -except AIC_bilateral_FC_HC PIC_bilateral_FC_HC AIC_bilateral_FC_MDD PIC_bilateral_FC_MDD Voxel_Conn_data_folder ROI_filenames FC nii_out_folder motion_file similarity_csv_file save_folder spm_model_folder vectorized_csv_folder

% Save out four images as Nifti again
% Load one ROI image as template
nii_temp = load_nii([Voxel_Conn_data_folder filesep ROI_filenames{1,1} '_voxel_connectivity_zmap_sorted.nii']);
% nii_out_folder is set in the USER SETTINGS section at the top of the script

% AIC HC
AIC_bilateral_FC_HC_nii = nii_temp;
AIC_bilateral_FC_HC_nii.img = [];
AIC_bilateral_FC_HC_nii.original = [];
AIC_bilateral_FC_HC_nii.img = AIC_bilateral_FC_HC;
AIC_bilateral_FC_HC_nii.hdr.dime.dim = [4 size(AIC_bilateral_FC_HC) 1 1 1];
save_nii(AIC_bilateral_FC_HC_nii,[nii_out_folder filesep 'AIC_bilateral_FC_HC.nii'])

% PIC HC
PIC_bilateral_FC_HC_nii = nii_temp;
PIC_bilateral_FC_HC_nii.img = [];
PIC_bilateral_FC_HC_nii.original = [];
PIC_bilateral_FC_HC_nii.img = PIC_bilateral_FC_HC;
PIC_bilateral_FC_HC_nii.hdr.dime.dim = [4 size(PIC_bilateral_FC_HC) 1 1 1];
save_nii(PIC_bilateral_FC_HC_nii,[nii_out_folder filesep 'PIC_bilateral_FC_HC.nii'])

% AIC MDD
AIC_bilateral_FC_MDD_nii = nii_temp;
AIC_bilateral_FC_MDD_nii.img = [];
AIC_bilateral_FC_MDD_nii.original = [];
AIC_bilateral_FC_MDD_nii.img = AIC_bilateral_FC_MDD;
AIC_bilateral_FC_MDD_nii.hdr.dime.dim = [4 size(AIC_bilateral_FC_MDD) 1 1 1];
save_nii(AIC_bilateral_FC_MDD_nii,[nii_out_folder filesep 'AIC_bilateral_FC_MDD.nii'])

% PIC MDD
PIC_bilateral_FC_MDD_nii = nii_temp;
PIC_bilateral_FC_MDD_nii.img = [];
PIC_bilateral_FC_MDD_nii.original = [];
PIC_bilateral_FC_MDD_nii.img = PIC_bilateral_FC_MDD;
PIC_bilateral_FC_MDD_nii.hdr.dime.dim = [4 size(PIC_bilateral_FC_MDD) 1 1 1];
save_nii(PIC_bilateral_FC_MDD_nii,[nii_out_folder filesep 'PIC_bilateral_FC_MDD.nii'])




%% Run regression for covariates before SPM analysis
%get QCed factors for regression
%regress on age, sex, site, and motion
FC.Group = FC.Group(FC.qQC);
FC.Age = FC.Age(FC.qQC);
FC.Female = FC.Female(FC.qQC); 
FC.Site = FC.Site(FC.qQC);
FC.SubjectID = FC.SubjectID(FC.qQC);

motion = readtable(motion_file,'ReadVariableNames',true);
[logic.overall_ID, logic.motion_Ia, logic.motion_Ib] = intersect(FC.SubjectID, motion.SubjectID);
FC.FD =  motion.meanFD_Power(logic.motion_Ib);
clear motion

% Load FC maps
AIC_HC = load_nii([nii_out_folder filesep 'AIC_bilateral_FC_HC.nii']);
AIC_HC_img(:,:,:,:) = AIC_HC.img;

PIC_HC = load_nii([nii_out_folder filesep 'PIC_bilateral_FC_HC.nii']);
PIC_HC_img(:,:,:,:) = PIC_HC.img;

AIC_MDD = load_nii([nii_out_folder filesep 'AIC_bilateral_FC_MDD.nii']);
AIC_MDD_img(:,:,:,:) = AIC_MDD.img;

PIC_MDD = load_nii([nii_out_folder filesep 'PIC_bilateral_FC_MDD.nii']);
PIC_MDD_img(:,:,:,:) = PIC_MDD.img;


%create structure with information about nan (=0) and non-nan (=1)
mask = AIC_HC_img(:,:,:,1);
mask(isnan(mask)) = 0;
mask = mask ~=0;

[x,y,z] = ind2sub([size(mask,1),size(mask,2),size(mask,3)],find(mask(:,:,:,1)));
activity_coordinates = [x,y,z];

% Use existing nifti structure as template
functional_image = load_untouch_nii([nii_out_folder filesep 'AIC_bilateral_FC_HC.nii']);
nii_template_HC = functional_image;
nii_template_HC.img = [];
nii_template_HC = rmfield(nii_template_HC,'fileprefix');

clear functional_image

functional_image = load_untouch_nii([nii_out_folder filesep 'AIC_bilateral_FC_MDD.nii']);
nii_template_MDD = functional_image;
nii_template_MDD.img = [];
nii_template_MDD = rmfield(nii_template_MDD,'fileprefix');

clear functional_image
        

% Run regression on HCP
FC_HC.Age = FC.Age(~FC.Group);
FC_HC.Female = FC.Female(~FC.Group);
FC_HC.Site = FC.Site(~FC.Group);
FC_HC.FD = FC.FD(~FC.Group);
nID = sum(~FC.Group);

regress_FC_AIC = AIC_HC_img; % so I don't have to overwrite the original file when regressed values are put in 
regress_FC_PIC = PIC_HC_img;
    
for j = 1:size(activity_coordinates,1) %mask loop

    % Get values for activity coordinate location for AIC and PIC
    FC_vec_AIC = squeeze(AIC_HC_img(x(j),y(j),z(j),:));
    FC_vec_PIC = squeeze(PIC_HC_img(x(j),y(j),z(j),:));

    % Build matrix
    data.X = [ones(nID,1), (FC_HC.Age - mean(FC_HC.Age)), (FC_HC.Female - mean(FC_HC.Female)), (FC_HC.Site - mean(FC_HC.Site)), (FC_HC.FD -mean(FC_HC.FD))];
    
    % Correct FC for linear effects in age + sex + site + FD
    [reg_AIC.b,reg_AIC.bint,reg_AIC.r,reg_AIC.rint,reg_AIC.stats] = regress(FC_vec_AIC,data.X);
    [reg_PIC.b,reg_PIC.bint,reg_PIC.r,reg_PIC.rint,reg_PIC.stats] = regress(FC_vec_PIC,data.X);

    %get values back in matrix and add intercept to each value
    intercept = reg_AIC.b(1);
    regress_FC_AIC(x(j),y(j),z(j),:) = reg_AIC.r + intercept;

    intercept = reg_PIC.b(1);
    regress_FC_PIC(x(j),y(j),z(j),:) = reg_PIC.r + intercept;

    clear data FC_vec_AIC FC_vec_PIC mask subset_AIC subset_PIC reg_AIC reg_PIC

end

% Export nii for HCP
AIC_bilateral_FC_HC_nii = nii_template_HC;
AIC_bilateral_FC_HC_nii.img = regress_FC_AIC;
save_untouch_nii(AIC_bilateral_FC_HC_nii,[nii_out_folder filesep 'AIC_bilateral_FC_HC_regress.nii'])

PIC_bilateral_FC_HC_nii = nii_template_HC;
PIC_bilateral_FC_HC_nii.img = regress_FC_PIC;
save_untouch_nii(PIC_bilateral_FC_HC_nii,[nii_out_folder filesep 'PIC_bilateral_FC_HC_regress.nii'])


% Run regression on MDD
FC_MDD.Age = FC.Age(FC.Group==1);
FC_MDD.Female = FC.Female(FC.Group==1);
FC_MDD.Site = FC.Site(FC.Group==1);
FC_MDD.FD = FC.FD(FC.Group==1);
nID = sum(FC.Group);

regress_FC_AIC = AIC_MDD_img; % so I don't have to overwrite the original file when regressed values are put in 
regress_FC_PIC = PIC_MDD_img;
    
for j = 1:size(activity_coordinates,1) %mask loop

    % Get values for activity coordinate location for AIC and PIC
    FC_vec_AIC = squeeze(AIC_MDD_img(x(j),y(j),z(j),:));
    FC_vec_PIC = squeeze(PIC_MDD_img(x(j),y(j),z(j),:));

    % Build matrix
    data.X = [ones(nID,1), (FC_MDD.Age - mean(FC_MDD.Age)), (FC_MDD.Female - mean(FC_MDD.Female)), (FC_MDD.Site - mean(FC_MDD.Site)), (FC_MDD.FD -mean(FC_MDD.FD))];
    
    % Correct FC for linear effects in age + sex + site + FD
    [reg_AIC.b,reg_AIC.bint,reg_AIC.r,reg_AIC.rint,reg_AIC.stats] = regress(FC_vec_AIC,data.X);
    [reg_PIC.b,reg_PIC.bint,reg_PIC.r,reg_PIC.rint,reg_PIC.stats] = regress(FC_vec_PIC,data.X);

    %get values back in matrix and add intercept to each value
    intercept = reg_AIC.b(1);
    regress_FC_AIC(x(j),y(j),z(j),:) = reg_AIC.r + intercept;

    intercept = reg_PIC.b(1);
    regress_FC_PIC(x(j),y(j),z(j),:) = reg_PIC.r + intercept;

    clear data FC_vec_AIC FC_vec_PIC mask subset_AIC subset_PIC reg_AIC reg_PIC

end

% Export nii for MDD
AIC_bilateral_FC_MDD_nii = nii_template_MDD;
AIC_bilateral_FC_MDD_nii.img = regress_FC_AIC;
save_untouch_nii(AIC_bilateral_FC_MDD_nii,[nii_out_folder filesep 'AIC_bilateral_FC_MDD_regress.nii'])

PIC_bilateral_FC_MDD_nii = nii_template_MDD;
PIC_bilateral_FC_MDD_nii.img = regress_FC_PIC;
save_untouch_nii(PIC_bilateral_FC_MDD_nii,[nii_out_folder filesep 'PIC_bilateral_FC_MDD_regress.nii'])


%%% Calculate and compare similarity between anterior and posterior insula subregions between HC and MDD
% Load AIC HC
AIC_HC = load_nii([nii_out_folder filesep 'AIC_bilateral_FC_HC_regress.nii']);
AIC_HC_map = AIC_HC.img;

% Load PIC HC
PIC_HC = load_nii([nii_out_folder filesep 'PIC_bilateral_FC_HC_regress.nii']);
PIC_HC_map = PIC_HC.img;

% Load AIC MDD
AIC_MDD = load_nii([nii_out_folder filesep 'AIC_bilateral_FC_MDD_regress.nii']);
AIC_MDD_map = AIC_MDD.img;

% Load PIC MDD
PIC_MDD = load_nii([nii_out_folder filesep 'PIC_bilateral_FC_MDD_regress.nii']);
PIC_MDD_map = PIC_MDD.img;


% HC
for participants = 1:size(AIC_HC_map,4)
    
   % Vectorize AIC map
   AIC_map = AIC_HC_map(:,:,:,participants);
   selector = ~isnan(AIC_HC_map(:,:,:,participants));
   AIC_profile = AIC_map(selector);
   clear selector
   % Vectorize PIC map
   PIC_map = PIC_HC_map(:,:,:,participants);
   selector = ~isnan(PIC_HC_map(:,:,:,participants));
   PIC_profile = PIC_map(selector);
   
   % Get correlation
   HC_similarity(participants,1) = corr(AIC_profile, PIC_profile);
   
   clear AIC_map AIC_profile PIC_map PIC_profile selector
    
end

HC_similarity_z = atanh(HC_similarity);

% MDD
for participants = 1:size(AIC_MDD_map,4)
    
   % Vectorize AIC map
   AIC_map = AIC_MDD_map(:,:,:,participants);
   selector = ~isnan(AIC_MDD_map(:,:,:,participants));
   AIC_profile = AIC_map(selector);
   clear selector
   % Vectorize PIC map
   PIC_map = PIC_MDD_map(:,:,:,participants);
   selector = ~isnan(PIC_MDD_map(:,:,:,participants));
   PIC_profile = PIC_map(selector);
   
   % Get correlation
   MDD_similarity(participants,1) = corr(AIC_profile, PIC_profile);
   
   clear AIC_map AIC_profile PIC_map PIC_profile selector
    
end

MDD_similarity_z = atanh(MDD_similarity);

% Run two sample t-test
[h,p,ci,stats] = ttest2(MDD_similarity_z,HC_similarity_z);
mean_diff = mean(MDD_similarity_z) - mean(HC_similarity_z);
d = stats.tstat/(sqrt((length(HC_similarity_z) * length(MDD_similarity_z))/(length(HC_similarity_z) + length(MDD_similarity_z))));

% Export csv file for plotting in R
Group = [zeros(length(HC_similarity_z),1);ones(length(MDD_similarity_z),1)];
Similarity = [HC_similarity_z;MDD_similarity_z];
Similarity_AIC_PIC = table(Similarity,Group,'VariableNames',{'Similarity','Group'});

writetable(Similarity_AIC_PIC,similarity_csv_file);




%%% Run full factorial model in SPM
% Initialise SPM 
%--------------------------------------------------------------------------
spm('Defaults','fMRI');
spm_jobman('initcfg');

%--------------------------------------------------------------------------

% nii_out_folder is set in the USER SETTINGS section at the top of the script
% save_folder is set in the USER SETTINGS section at the top of the script

matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(save_folder);

matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'subregion';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;

% Define HCP
nii_AIC_HC = spm_select('ExtFPList',[nii_out_folder,filesep], 'AIC_bilateral_FC_HC_regress.nii');
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = cellstr(nii_AIC_HC);

nii_PIC_HC = spm_select('ExtFPList',[nii_out_folder,filesep], 'PIC_bilateral_FC_HC_regress.nii');
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = cellstr(nii_PIC_HC);

% Define MDD
nii_AIC_MDD = spm_select('ExtFPList',[nii_out_folder,filesep], 'AIC_bilateral_FC_MDD_regress.nii');
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = cellstr(nii_AIC_MDD);

nii_PIC_MDD = spm_select('ExtFPList',[nii_out_folder,filesep], 'PIC_bilateral_FC_MDD_regress.nii');
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = cellstr(nii_PIC_MDD);        

        
% Generate basic contrasts according to design
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% Model estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% Additional contrasts
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = ['Effects of interest'];
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(4);
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ['Positive effect of group 2'];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-1 -1 1 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ['Positive effect of subregion 2'];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1 -1 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = ['Negative interaction']; 
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [-1 1 1 -1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

% Run matlabbatch
spm_jobman('run',matlabbatch);



%% Extract vectorized main effect and interaction effect for Figure 2C
% Load interaction map and vectorize
pos_interaction_Tmap = load_nii([spm_model_folder filesep 'spmT_0008.nii']);
pos_interaction_Tmap = pos_interaction_Tmap.img;
pos_interaction_Tmap_vectorized = pos_interaction_Tmap(:);

% Load main effect map and vectorize
pos_main_Tmap = load_nii([spm_model_folder filesep 'spmT_0007.nii']);
pos_main_Tmap = pos_main_Tmap.img;
pos_main_Tmap_vectorized = pos_main_Tmap(:);

% Load mask and vectorize
mask = load_nii([spm_model_folder filesep 'mask.nii']);
mask = mask.img;
mask = logical(mask);
mask_vectorized = mask(:);

% Extract T values and write as csv
pos_interaction_Tmap_vectorized = pos_interaction_Tmap_vectorized(mask_vectorized);
writematrix(pos_interaction_Tmap_vectorized, [vectorized_csv_folder filesep 'factorial_model_FC_interaction_effect_vectorized.csv']);

pos_main_Tmap_vectorized = pos_main_Tmap_vectorized(mask_vectorized);
writematrix(pos_main_Tmap_vectorized, [vectorized_csv_folder filesep 'factorial_model_FC_main_effect_vectorized.csv']);
