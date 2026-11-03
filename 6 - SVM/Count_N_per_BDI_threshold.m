%%% Count the number of MDD participants retained at each BDI inclusion threshold of the
%%% SVM classification (BDI >= 0 to BDI >= 29; Table S1 in the Supplementary Information)
%%% Requires the variables FC (from MDD_BDI_Cov.mat) and SVM_data_mdd in the workspace, i.e.
%%% run the first section of Run_SVM_BDI_with_permutation.m (loading the data and separating
%%% MDD and HCP) before running this script.

for i = 1:30 %based on bdi score
    log_sel = FC.sBDI >= i-1;%
    %get mdd based on bdi score
    mdd_included = SVM_data_mdd(log_sel,:);
    length = height(mdd_included);
    disp(['BDI:' num2str(i) ' Participants:' num2str(length)]);
end

for i = 1:30 %based on bdi score
    log_sel = FC.sBDI >= i-1;%
    %get mdd based on bdi score
    mdd_included = SVM_data_mdd(log_sel,:);
    length = height(mdd_included);
    disp(num2str(length));
end