function preproc_VideoMask_Julia(subName)
addpath '/bif/storage/storage1/projects/emocon/Scripts'                     %add path of scripts

%define Paths
processing_folder    = '/bif/storage/storage1/projects/emocon/';            %find project folder
study_folder   = '/bif/storage/storage1/projects/emocon/Data/BIDS';         %find Bids data
script_folder  = '/bif/storage/storage1/projects/emocon/Scripts';           %find scripts

%Go to project folder
cd (processing_folder)                                                      %go to project folder
CWD            = pwd;                                                       %define this folder as CWD and come back at the end of the script

%create Outputpath for every subject 
if ~exist(fullfile(processing_folder, 'Preproc', 'VideoMask', subName), 'dir') %create output folder if this doesnt exist
mkdir(fullfile(processing_folder, 'Preproc', 'VideoMask', subName));
end
preprocDir = fullfile(processing_folder, 'Preproc', 'VideoMask', subName);  %define this output folder als preprocessing directory


spm('Defaults','fMRI');
spm_jobman('initcfg');
clear matlabbatch

%select batch with fieldmapping, realignment, coregistration, normalisation
%and smooting
preprocfile    = fullfile(script_folder, 'Preprocessing.mat');              %open the preprocessing matlab batch
load(preprocfile);

%% Select epi files

epiPath = fullfile(study_folder,subName,'ses-001', 'func');                 %path to my epi images
epiName = strcat(subName,'_ses-001_task-VideoMask_run-001_bold.nii');       %name of my epi images
epiZipName = strcat(subName,'_ses-001_task-VideoMask_run-001_bold.nii.gz'); %name of the image i have to unzip
gunzip(fullfile(epiPath, epiZipName));                                      %unzip Epi images

epiFileArrayAll = spm_select('expand', fullfile(epiPath,epiName));          %select my unzipped epi image in spm
number_EpiFiles = length(epiFileArrayAll);                                  %get length of my epi array (number of measured epi files)
nessesary_epiFiles = cellstr(epiFileArrayAll(4:number_EpiFiles,:));         %change the "1" if you want to skip the first epi files but change this in the first level script too!
first_epiFile = cellstr(epiFileArrayAll(4,:));                              %get the first epi image for the fieldmapping

%% Select anatomy file
anatomyPath = fullfile(study_folder,subName,'ses-001', 'anat');             %path to my anatomical image
anatName = strcat(subName,'_ses-001_run-001_T1w.nii');                      %name of the anatomical image
anatZipName = strcat(subName,'_ses-001_run-001_T1w.nii.gz');                %name of the image i have to unzip

gunzip(fullfile(anatomyPath,anatZipName));                                  %unzip the compressed nifti file
anatomyFile= spm_select('ExtFPList', anatomyPath,anatName);                 %select T1 image

%% Select fieldmap files
greyfieldPath = fullfile(study_folder,subName,'ses-001', 'fmap');           %path to my grefield images
cd (greyfieldPath)                                                          %go to my grefied images
filename = strcat(subName,'_ses-001_magnitude1.nii.gz');                    %name of the image i maybe have to unzip

if isfile(filename)                                                         %check if this nii.gz file exists and if yes, unzip all needed images
fmapZipName1 = strcat(subName,'_ses-001_magnitude1.nii.gz'); 
gunzip(fullfile(greyfieldPath,fmapZipName1));                               %unzip the magnitude1 image
fmapZipName2 = strcat(subName,'_ses-001_magnitude2.nii.gz');
gunzip(fullfile(greyfieldPath,fmapZipName2));                               %unzip the magnitude2 image
fmapZipName3 = strcat(subName,'_ses-001_phasediff.nii.gz');
gunzip(fullfile(greyfieldPath,fmapZipName3));                               %unzip the phasediff image
end
cd (processing_folder)                                                      %go back do my project folder

magnName = strcat(subName,'_ses-001_magnitude1.nii');                       %name of my magnitude file
magPath = fullfile(greyfieldPath,magnName);                                 %path to my magnitude file
magnitudeFile = spm_select('expand',magPath);                               %select the magnitude file


phaseName = strcat(subName,'_ses-001_phasediff.nii');                       %name of the phasediff file
phasePath = fullfile(greyfieldPath,phaseName);                              %path to my phasediff file
phaseFile = spm_select('expand',phasePath);                                 %select the phasediff file

%% Define Batch Inputs
%Fieldmap
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase     = cellstr(phaseFile);                 %select the phasediff file
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = cellstr(magnitudeFile);             %select the magnitude file
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session.epi                   = first_epiFile;                      % select the first epi file, dont need {} because variable is already a char
%Realignment
matlabbatch{2}.spm.spatial.realignunwarp.data.scans                               = cellstr(nessesary_epiFiles);        %select all the epi files you want to use
%Coregistration
matlabbatch{3}.spm.spatial.coreg.estwrite.source                                  = cellstr(anatomyFile);               %select the anatomical image

%% Move files to Preprocessing Folder %%
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{1}));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(2) = cfg_dep('Realign & Unwarp: Realignment Param File (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(3) = cfg_dep('Realign & Unwarp: Unwarp Params File (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','dsfile'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(4) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(5) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(6) = cfg_dep('Coregister: Estimate & Reslice: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(7) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(8) = cfg_dep('Normalise: Estimate & Write: Deformation (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(9) = cfg_dep('Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.files(10) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {preprocDir}; %put the files in my output folder

%save Batch
cd(preprocDir)                                                              %go to output folder
preproc_filename = sprintf('preproc_%s.mat',subName);                       %rename the generated script 
save(preproc_filename, 'matlabbatch')                                       %save as matlab batch

%run created batch
spm_jobman('run', matlabbatch);

%move back
cd(CWD);

