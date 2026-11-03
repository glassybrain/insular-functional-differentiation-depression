%%% Create the quality-control (QC) vector and covariate structure (FC.mat) used in all
%%% subsequent scripts
%%% Imaging and covariate data are matched by subject ID to extract group (MDD = 1, HCP = 0),
%%% age, sex, site and body-coil information. For every participant, the whole-brain mean
%%% of the Fisher z-transformed ROI-to-ROI connectivity is calculated. Participants pass QC
%%% (FC.qQC = 1) if their mean connectivity is < 0.2 (to exclude motion-related
%%% hyperconnectivity) and they were not scanned with the body coil.
%%% See 'Participants' in the Methods and Figure S1.
%%% Requires: MATLAB

% create QC vector to use in other script
clear all

%% USER SETTINGS: adjust the paths below to your local system
roi_conn_file = '/path/to/Whole_brain_ROI_Conn_sorted';   % ROI-to-ROI connectivity matrices (ROI_conn_sorted; output of script 3)
covariates_file = '/path/to/PsyMRI_Covariates';            % covariate table of the FOR2107 sample (Covariates)
subject_IDs_file = '/path/to/subject_IDs_sorted';          % sorted subject IDs (subject_IDs_num)
out_folder = '/path/to/Bilateral_insula_FC';               % output folder for FC.mat
motion_file = '/path/to/FD_HM.xlsx';                       % mean framewise displacement per participant

load(roi_conn_file)
load(covariates_file)
load(subject_IDs_file);
motion = readtable(motion_file,'ReadVariableNames',true);

%create intersecting between MR and COV sample 
COV = Covariates(Covariates.Group<3,:);
[logic.FC_ID, logic.FC_Ia, logic.FC_Ib] = intersect(subject_IDs_num,COV.SubjectID);
FC.Bodycoil = COV.Bodycoil(logic.FC_Ib);
FC.Group = COV.Group(logic.FC_Ib)-1;%group vector, MDD=1, HC=0
FC.Age = COV.Age(logic.FC_Ib);
FC.Female = COV.Sex(logic.FC_Ib) - 1;
FC.Site = COV.Site(logic.FC_Ib) -1; 
FC.SubjectID = logic.FC_ID;

%run similarity and get summary stats for IDs
for i_ID = 1:length(FC.Group)
    
    [~,~,FC_vec] = find(triu(ROI_conn_sorted(:,:,i_ID),1));
    vFC(i_ID,:) = FC_vec';
    
end

vzFC = atanh(vFC);
ID.M_vzFC = mean(vzFC,2);

%create logical with nanmean <.2 and without bodycoil
FC.qQC = ID.M_vzFC<.2 & FC.Bodycoil~=1;

save([out_folder filesep 'FC.mat'],'FC')

clear vFC FC_vec i_ID ID logic 


