%%% Spatial smoothing of the preprocessed (denoised) functional images
%%% Applies a 6 mm FWHM isotropic Gaussian kernel (SPM12) to the 4D functional image of
%%% every participant. Smoothed images are written into the same folder with the prefix
%%% 'smoothed_'.
%%% See 'Preprocessing' in the Supplementary Information.
%%% Requires: MATLAB, SPM12

%% USER SETTINGS: adjust the path below to your local system
FunImgFolder = ('/path/to/preprocessed');   % folder containing the preprocessed 4D functional image of every participant

% Prepare list of subjects
subjects = dir(FunImgFolder);
subjects = subjects(arrayfun(@(x) x.name(1), subjects) ~= '.');

matlabbatch{1}.spm.spatial.smooth.data = '';
matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 'smoothed_';

for subjnum = 1:length(subjects)
    
    disp('---------------------------------------')
    disp(' ')
    disp(['Smoothing subject ' num2str(subjnum) ' of ' num2str(length(subjects))])
    disp(' ')
    disp('---------------------------------------') 
    
    subj = subjects(subjnum).name;
    
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',[FunImgFolder,filesep],subj));
    spm_jobman('run',matlabbatch);
    
end
