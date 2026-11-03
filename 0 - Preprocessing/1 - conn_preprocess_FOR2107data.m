%%% Preprocessing and denoising of the resting-state fMRI data with the CONN toolbox (v18a)
%%% For each participant, the functional (rest.nii) and structural (mprage.nii) images are
%%% located and the default CONN preprocessing pipeline is applied: functional realignment &
%%% unwarping, centering, slice-timing correction (ascending), outlier detection (ART),
%%% direct segmentation & normalisation to MNI space (2 mm isotropic) and structural
%%% centering, segmentation & normalisation.
%%% Denoising regresses out white matter and CSF signals (aCompCor, 5 components each),
%%% realignment parameters (and their first-order derivatives) and scrubbing regressors,
%%% followed by band-pass filtering (0.01-0.1 Hz) and linear detrending. The denoised
%%% voxel-wise data are then exported to NIfTI (conn_matc2nii).
%%% See 'Preprocessing' in the Supplementary Information.
%%% Requires: MATLAB, SPM12, CONN toolbox v18a

clear
clc
close all

%% USER SETTINGS: adjust the paths below to your local system
data_folder = '/path/to/raw_data';   % folder with one subfolder per participant (named by subject code) containing rest.nii and mprage.nii
conn_folder = '/path/to/conn18a';    % installation folder of the CONN toolbox v18a (contains the 'rois' folder)

Subject_code= {'ENTER SUBJECT CODE HERE'};

for subject_index = 1
    folder_name = Subject_code{subject_index};
    cwd = [data_folder filesep folder_name];
    cd(cwd);
    NSUBJECTS = 1;
    
    %% FIND functional/structural files
    cwd=pwd;
    FUNCTIONAL_FILE=cellstr(conn_dir('rest.nii*')); % conn_dir will look on all the subdirectory
    STRUCTURAL_FILE=cellstr(conn_dir('mprage.nii*'));
    if rem(length(FUNCTIONAL_FILE),NSUBJECTS),error('mismatch number of functional files %n', length(FUNCTIONAL_FILE));end
    if rem(length(STRUCTURAL_FILE),NSUBJECTS),error('mismatch number of anatomical files %n', length(FUNCTIONAL_FILE));end
    
    nsessions=1;
    
    FUNCTIONAL_FILE=reshape(FUNCTIONAL_FILE,[NSUBJECTS,nsessions]);
    STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
    disp([num2str(size(FUNCTIONAL_FILE,1)),' subjects']);
    disp([num2str(size(FUNCTIONAL_FILE,2)),' sessions']);
    
    TR=2; 
    
    %% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS
    %% Prepares batch structure
    clear batch;
    batch.filename=fullfile(cwd,'conn_preprocess.mat');            % New conn_*.mat experiment name
    batch.filename=fullfile(cwd,sprintf('conn_preprocess.mat'));            % New conn_*.mat experiment name
    
    %% SETUP & PREPROCESSING step (using default values for most parameters, see help conn_batch to define non-default values)
    % CONN Setup
    % CONN Setup.preprocessing
    batch.Setup.isnew=1;
    batch.setup.acquisitiontype = 1; % continious recording
    batch.Setup.nsubjects=NSUBJECTS; % number of subjects
    batch.Setup.RT=TR;  % TR (seconds)
    batch.setup.analysis = [1 2]; % 1 for ROI to ROI and 2 for seed to voxel
    batch.setup.outputfiles = [0 1 0];
    
    % functional data
    batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       % Point to functional volumes for each subject/session
    for nsub=1:NSUBJECTS,
        for nses=1:nsessions,
            batch.Setup.functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nsub,nses};
        end
    end %note: each subject's data is defined by three sessions and one single (4d) file per session
    
    batch.Setup.structurals=STRUCTURAL_FILE;                  % Point to anatomical volumes for each subject
    
    
    batch.setup.rois.names = {'atlas','networks'};
    batch.setup.rois.dimensions = {1,1};
    batch.setup.rois.files{1} = [conn_folder filesep 'rois' filesep 'atlas.nii'];
    batch.setup.rois.files{2} = [conn_folder filesep 'rois' filesep 'networks.nii'];
    
    
    nconditions=nsessions;
    if nconditions==1
        batch.Setup.conditions.names={'rest'};
        for ncond=1,
            for nsub=1:NSUBJECTS,
                for nses=1:nsessions,
                    batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0;
                    batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
                end;
            end;
        end     % rest condition (all sessions)
    else
        batch.Setup.conditions.names=[{'rest'}, arrayfun(@(n)sprintf('Session%d',n),1:nconditions,'uni',0)];
        for ncond=1,
            for nsub=1:NSUBJECTS,
                for nses=1:nsessions,
                    batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0;
                    batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
                end;
            end;
        end     % rest condition (all sessions)
        for ncond=1:nconditions,
            for nsub=1:NSUBJECTS,
                for nses=1:nsessions,
                    batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=[];
                    batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=[];
                end;
            end;
        end
        for ncond=1:nconditions,
            for nsub=1:NSUBJECTS,
                for nses=ncond,
                    batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=0;
                    batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=inf;
                end;
            end;
        end % session-specific conditions
    end
    
    
    batch.Setup.preprocessing.steps = {'functional_realign&unwarp','functional_center' , 'functional_slicetime', 'functional_art','functional_segment&normalize_direct','structural_center',...
        'structural_segment&normalize'};
    batch.Setup.preprocessing.sliceorder='ascending';
%     batch.Setup.preprocessing.fwhm = 6;
    batch.Setup.preprocessing.voxelsize = 2;
    batch.Setup.preprocessing.coregtomean = 1;
    batch.Setup.preprocessing.boundingbox = [-90,-126,-72;90,90,108];
    batch.Setup.preprocessing.art_thresholds(1:2) = [3 .5];
    batch.Setup.done=1;
    batch.Setup.overwrite='Yes';
    
    % uncomment the following 3 lines if you prefer to run one step at a time:
    conn_batch(batch); % runs Preprocessing and Setup steps only
    clear batch;
    batch.filename=fullfile(cwd,'conn_preprocess.mat');            % Existing conn_*.mat experiment name
    
    %% DENOISING step
    % CONN Denoising                                    %    
    batch.Denoising.confounds.names = {'White Matter', 'CSF', 'realignment', 'scrubbing'};
    batch.Denoising.confounds.dimensions= {5, 5, [ ], [ ]};
    batch.Denoising.confounds.deriv= {0, 0, 1,0 }; % derivatives order of each effect listed above (cell array of values, leave empty a particular value to set to the default value
    batch.Denoising.confounds.power= {1, 1, 1,1 };
    batch.Denoising.confounds.filter = {0, 0, 0,0};
    batch.Denoising.function = 1; % after regression 
    batch.Denoising.filter=[0.01, 0.1];                 % frequency filter (band-pass values, in Hz)
    batch.Denoising.done=1;
    batch.Denoising.overwrite='Yes';
    batch.Denoising.detrending = 1;
    batch.Denoising.despiking = 0;
    batch.Denoising.done=1;
    batch.Denoising.overwrite='Yes';
    
    % % uncomment the following 3 lines if you prefer to run one step at a time:
    conn_batch(batch); % runs Denoising step only
    clear batch;
    batch.filename=fullfile(cwd,'conn_preprocess.mat');            % Existing conn_*.mat experiment name
    

    %% conevrting matc files to nii for coonfound free voxel data
    conn_matc2nii
end


