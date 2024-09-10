function [matlabbatch]=firstlevel_VideoMask_Julia(subName)
%-----------------------------------------------------------------------
% Job saved on 22-Mar-2017 20:39:47 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

addpath('/bif/storage/storage1/projects/emocon/Scripts');                                           %add path
projectfolder       = '/bif/storage/storage1/projects/emocon';                                      %define project folder
subDirPreproc       = fullfile(projectfolder, 'Preproc', 'VideoMask', subName);                     %define preprocessing folder
subDirSmooth        = fullfile(subDirPreproc);                                                      %find the smoothed images
outputFirstlevel    = fullfile(projectfolder,'FirstLevel','VideoMask', subName);                    %define output folder for FirstLevel analysis

%create folder
if ~exist(outputFirstlevel, 'dir'); mkdir(outputFirstlevel); end                                    %if this output folder doesnt exist, create one

% Create mulitple condition files with the mkConfile Function
mkConFile_VideoMask(subName);                                                                       %call function to create condition file 
conditionFile       = fullfile(projectfolder,'ConFileFolder',subName, 'ConFile_VideoMask.mat');     %save condition file in confilefolder

% specify files and arrays: functional images, realignment parameter text file
smoothName         = strcat('swu',subName, '_ses-001_task-VideoMask_run-001_bold.nii');             %name of my smoothed images
subPreprocFiles    = spm_select('expand', fullfile(subDirSmooth, smoothName));                      %select preprocessed files
realignmentName    = strcat('rp_',subName, '_ses-001_task-VideoMask_run-001_bold.txt');             %name of the file with realignment parameter
realignmentFile    = spm_select('FPListRec',subDirSmooth,realignmentName);                          %select file with realignment parameter

number_smoothed_EpiFiles = length(subPreprocFiles);                                                 %get number of EPI files 
nessesary_smoothed_epiFiles = cellstr(subPreprocFiles(4:number_smoothed_EpiFiles,:));               %get smoothed images into a cellstring


%% Fill matlab batch %%
matlabbatch{1}.spm.stats.fmri_spec.dir = {outputFirstlevel};                                        %define directory to finde preprocessed images
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';                                           %unit in seconds
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;                                                   %TR is 2 seconds
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

matlabbatch{1}.spm.stats.fmri_spec.sess.scans =  cellstr(nessesary_smoothed_epiFiles);              %select functional scans

%% regressors
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {},'pmod', {});     % you can also include this:, 'tmod', {}, 'pmod', {}, 'orth', {}); if you have this in your condition file
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {conditionFile};                                    %select the condition file
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {realignmentFile};                              %select the realignment file

%% high pass filter
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

%% temporal derivative
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

fprintf(1, 'Created matlabbatch for subject %s.\nMatlabbatch is being executed now.\n', subName);   %print information in matlab window
tStart = tic;    
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
toc(tStart);

%matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(outputFirstlevel,'SPM.mat')};
%matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
%matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

cd(outputFirstlevel);                                                                               %go to output folder
load('SPM.mat');                                                                                    %load the generated SPM.mat file
SPM = spm_spm(SPM);                                                                                 %run the SPM.mat

%write information in matlab window
fprintf(1, 'Created matlabbatch for subject %s.\nMatlabbatch is being estimated now.\n', subName);

fprintf(1, 'First-level analysis for subject %s successful.\n', subName);
