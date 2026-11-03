%%% Run SVM classification with 10-fold cross-validation and get median Area Under the Curve
%%% across 10 runs as performance criterion
%%% Run permutation test to obtain significance permutation
%%% Build subsamples based on increasing BDI score in MDD group (first
%%% subsample equal to full sample as all participants have a minimum BDI
%%% of 1)
%%% For each of the 30 BDI inclusion thresholds (BDI >= 0 to BDI >= 29), an equally sized
%%% random HCP sample is drawn (randperm; full HCP sample if more than 417 MDD participants
%%% are retained). The SVM (fitcsvm, default settings) is trained on the 9 AIC-PIC similarity
%%% predictors and evaluated with 10-fold cross-validation, repeated 10 times (median AUC).
%%% Significance is assessed with 1000 permutations of the group labels (datasample). A
%%% linear model (fitlm) of median AUC by (standardised) BDI threshold is fitted to the true
%%% and permuted AUCs to test whether accuracy scales with symptom severity.
%%% Input: SVM_data.mat (output of svm_prep.m) and MDD_BDI_Cov.mat (BDI scores of the MDD
%%% group), both provided in the 'data' folder
%%% Output: written to result_folder (.mat and slope_perm_median.csv) and to the current
%%% working directory (average_auc_perm_median.csv)
%%% See 'Classification' in the Methods and Figure 4.
%%% Requires: MATLAB (Statistics and Machine Learning Toolbox)

clear all

%% USER SETTINGS: adjust the paths below to your local system
% setup paths
result_folder = '/path/to/6 - SVM/output';   % output folder
data_folder = '/path/to/6 - SVM/data';   % folder containing MDD_BDI_Cov.mat and SVM_data.mat

load([data_folder filesep 'MDD_BDI_Cov.mat'])
load([data_folder filesep 'SVM_data.mat']);

% separate data for MDD and HC
mdd = (SVM_data.Group == 1);
SVM_data_mdd = SVM_data(mdd,:); 

hc = (SVM_data.Group == 0);
SVM_data_hc = SVM_data(hc, :);

nPerms = 1000; 
Y_perm = [];


%% run SVM 
% median of 10 runs
% 10-fold cross-validation
% 1000 permuted runs

for i = 1:30 %based on bdi score
    log_sel = FC.sBDI >= i-1;%
    %get mdd based on bdi score
    mdd_included = SVM_data_mdd(log_sel,:);
    
    %get representative hc sample (random)(same n as mdd, depends on severity of mdd included)
    if size(mdd_included, 1) > 417
        selected_hc = SVM_data_hc;
    else
        k = randperm(417, size(mdd_included,1));
        selected_hc  = SVM_data_hc(k, :);
    end
    
    %combine selected mdd and hc
    bdi_comb = [mdd_included; selected_hc];
   
    for j = 1:10 
    %run model
    mdlSVM_bdi = fitcsvm(bdi_comb, 'Group');
    
    %cross validate with k = 10
    cv_10 = crossval(mdlSVM_bdi, 'KFold',10);
    missclass_rate_cv10(i,j,:) = kfoldLoss(cv_10)*100;
    
    [predicted_cv_10, ~] = kfoldPredict(cv_10);
    
    % Calculate ROC curve and AUC
    [Xsvm_cv_10(i,j,:), Ysvm_cv_10(i,j,:), ~, AUCsvm_cv_10(i,j,:)] = perfcurve(bdi_comb.Group, predicted_cv_10,1); 
   
  
   end
   
     for i_perm = 1:nPerms
        
        
        for z = 1:10
            disp(['Running BDI ' num2str(i) ', perm # ' num2str(i_perm) ' and try number ' num2str(z) ])
        
        % permute labels (mdd/hc)
        Y_perm(:,i_perm) = datasample(bdi_comb.Group,length(bdi_comb.Group),'Replace',false);
        bdi_perm = bdi_comb;
    
        bdi_perm.Group = Y_perm(:,i_perm);
    
        %run model
         mdlSVM_bdi_perm = fitcsvm(bdi_perm, 'Group');
    
        %cross validate with k = 10
        cv_10_perm = crossval(mdlSVM_bdi_perm, 'KFold',10);
        missclass_rate_cv10_perm(z, :) = kfoldLoss(cv_10_perm)*100;
    
        [predicted_cv_10_perm, ~] = kfoldPredict(cv_10_perm);
    
        [~,~, ~, AUCsvm_cv_10_perm(z, :)] = perfcurve(bdi_comb.Group, predicted_cv_10_perm,1); 
        
        end
        
        missclass_rate_perm_median(i,i_perm,:) = median(missclass_rate_cv10_perm);
        AUC_perm_median(i,i_perm,:) = median(AUCsvm_cv_10_perm);
    
     end

   clear Y_perm 

end

AUC_cv10_median = median(AUCsvm_cv_10,2);
missclass_rate_median = median(missclass_rate_cv10,2);

save([result_folder, filesep,'AUC_perm_median.mat'],'AUC_perm_median');
save([result_folder, filesep,'AUC_cv10_median.mat'],'AUC_cv10_median');
save([result_folder, filesep,'missclass_rate_median.mat'],'missclass_rate_median');
save([result_folder, filesep,'missclass_rate_perm_median.mat'],'missclass_rate_perm_median');


%save results
colNames = {'AUC','Misclassification_rate'};
results_sev_based = array2table([AUC_cv10_median missclass_rate_median],'VariableNames',colNames);

auc_median = results_sev_based;
auc_median.Misclassification_rate = [];
mean_AUC_perm_median = mean(AUC_perm_median,2);
prct_AUC_perm_median = prctile(AUC_perm_median,95,2);

bdi = (1:30)';
auc_median.bdi = bdi;
auc_median.mean_AUC_perm = mean_AUC_perm_median;
auc_median.prct_AUC_perm = prct_AUC_perm_median;

save([result_folder, filesep,'average_auc_perm_median.mat'],'auc_median');
writetable(auc_median, 'average_auc_perm_median.csv')



%% get coefficients of fitted slopes
lm_pred_median = fitlm(normalize(auc_median.bdi),auc_median.AUC); % normalize to get standardized betas   
slope_pred_median = lm_pred_median.Coefficients.Estimate(2);
CI_pred_median = coefCI(lm_pred_median);

for i = 1:1000
    
    lm_perm = fitlm(normalize(auc_median.bdi), AUC_perm_median(:,i));   
    slope_perm(i,:) = lm_perm.Coefficients.Estimate(2);
    
end

save([result_folder filesep 'slope_perm_median.mat'],'slope_perm')
csvwrite([result_folder filesep 'slope_perm_median.csv'], slope_perm)

%calculate p-value for slopes
p_perm_slope_median = 1 - (sum(slope_pred_median > slope_perm)/nPerms); %p = 0.000


%calculate p-value for AUC
for i = 1:30
    
        p_perm_auc_median(i,:) = 1 -(sum(auc_median.AUC(i,:)> AUC_perm_median(i,:))/nPerms);
    
end

save([result_folder filesep 'p_perm_auc_median.mat'],'p_perm_auc_median')
