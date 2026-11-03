%%% Run linear mixed-effects model to test for interaction between Group (HC, MDD) and
%%% Similarity type (within, between)
%%% Linear mixed-effects models (fitlme) predicting the z-standardised similarity values
%%% (column atanh of T_insula.csv / T_temporal.csv) from Group, Similarity type and their
%%% interaction, with a random intercept and random slopes for Group and Similarity type per
%%% participant. Fixed effects are reported with Satterthwaite degrees of freedom. The model
%%% is run for the insula and for the temporal cortex (control region). See 'Predicting Similarity by
%%% Group x Similarity type (within vs. between)' in the Supplementary Information.
%%% Input: T_insula.csv and T_temporal.csv (output of '2 - Similarity', provided in
%%% '2 - Similarity/output')
%%% Requires: MATLAB (Statistics and Machine Learning Toolbox)

%% USER SETTINGS: adjust the paths below to your local system
result_folder = '/path/to/2 - Similarity/output';   % folder containing T_insula.csv and T_temporal.csv
out_folder = '/path/to/output_models';   % output folder for the fitted models and fixed-effects tables

% Insula
T_insula = readtable([result_folder filesep 'T_insula.csv'],'HeaderLines',0,'ReadVariableNames',true);

%prepare data
T_model = T_insula;
T_model.atanh = normalize(T_model.atanh); % normalize to get standardized betas  
T_model.Subj_ID = nominal(T_model.Subj_ID);
T_model.Group = nominal(T_model.Group);
T_model.within = nominal(T_model.within);

%run LME
lm_insula_within = fitlme(T_model, 'atanh ~ 1 + Group*within + (1 + Group + within | Subj_ID)');

[beta, betanames, insula_within] = fixedEffects(lm_insula_within, 'DFMethod', 'Satterthwaite');
insula_within

%export
save([out_folder filesep 'lm_insula_within.mat'],'lm_insula_within')
save([out_folder filesep 'insula_within.mat'],'insula_within')

clearvars T_model



% Temporal
T_temporal = readtable([result_folder filesep 'T_temporal.csv'],'HeaderLines',0,'ReadVariableNames',true);

%prepare data
T_model = T_temporal;
T_model.atanh = normalize(T_model.atanh); % normalize to get standardized betas  
T_model.Subj_ID = nominal(T_model.Subj_ID);
T_model.Group = nominal(T_model.Group);
T_model.within = nominal(T_model.within);

%run LME
lm_temporal_within = fitlme(T_model, 'atanh ~ 1 + Group*within + (1 + Group + within | Subj_ID)');

[beta, betanames, temporal_within] = fixedEffects(lm_temporal_within, 'DFMethod', 'Satterthwaite');
temporal_within

%export
save([out_folder filesep 'lm_temporal_within.mat'],'lm_temporal_within')
save([out_folder filesep 'temporal_within.mat'],'temporal_within')

