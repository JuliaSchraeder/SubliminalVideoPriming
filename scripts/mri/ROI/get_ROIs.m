function get_ROIs(subName)

%% Adapt paths if necessary!! %%

%addpath('');                  

% Define Paths
processing_folder    = '/bif/storage/storage1/projects/emocon/';                        % find project folder
script_folder  = '/bif/storage/storage1/projects/emocon/Scripts/VideoMask/ROI';        % find script folder
firstlevel_path = '/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/'; 


% Go to project folder
cd (processing_folder)                                                      % go to my project folder
CWD            = pwd;    

% % Create outputpath for every subject 
% if ~exist(fullfile(firstlevel_path, subName), 'dir')                        % create folder for preprocessing files for each participant if this doesnt exist
% mkdir(fullfile(firstlevel_path, subName));
% end

spm('Defaults','fMRI');
spm_jobman('initcfg');
clear matlabbatch

spm_mat_dir = fullfile(firstlevel_path, subName, 'SPM.mat');
amygdala_r_dir = fullfile(script_folder,'R_Amy.nii,1');
amygdala_l_dir = fullfile(script_folder,'L_Amy.nii,1');

dlPFC_L_mask_dir = fullfile(script_folder, 'L_DLPFC.nii,1');
dlPFC_R_mask_dir = fullfile(script_folder, 'R_DLPFC.nii,1');

lACC_mask_dir = fullfile(script_folder, 'L_ACC.nii,1');
rACC_mask_dir = fullfile(script_folder, 'R_ACC.nii,1');

%% Amygdala R

matlabbatch{1}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{1}.spm.util.voi.adjust = 0;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'Amygdala_R';                        
matlabbatch{1}.spm.util.voi.roi{1}.mask.image = {amygdala_r_dir};
matlabbatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{1}.spm.util.voi.expression = 'i1';


%% Amygdala L

matlabbatch{2}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{2}.spm.util.voi.adjust = 0;
matlabbatch{2}.spm.util.voi.session = 1;
matlabbatch{2}.spm.util.voi.name = 'Amygdala_L';                        
matlabbatch{2}.spm.util.voi.roi{1}.mask.image = {amygdala_l_dir};
matlabbatch{2}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{2}.spm.util.voi.expression = 'i1';


%% dlPFC L

matlabbatch{3}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{3}.spm.util.voi.adjust = 0;
matlabbatch{3}.spm.util.voi.session = 1;
matlabbatch{3}.spm.util.voi.name = 'dlPFC_L';                        
matlabbatch{3}.spm.util.voi.roi{1}.mask.image = {dlPFC_L_mask_dir};
matlabbatch{3}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{3}.spm.util.voi.expression = 'i1';


%% dlPFC R

matlabbatch{4}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{4}.spm.util.voi.adjust = 0;
matlabbatch{4}.spm.util.voi.session = 1;
matlabbatch{4}.spm.util.voi.name = 'dlPFC_R';                        
matlabbatch{4}.spm.util.voi.roi{1}.mask.image = {dlPFC_R_mask_dir};
matlabbatch{4}.spm.util.voi.roi{1}.mask.threshold = 0.05;
matlabbatch{4}.spm.util.voi.expression = 'i1';


%%
% MNI Space: Evans, A. C., Collins, D. L., Mills, S. R., Brown, E. D., Kelly, R. L., & Peters, T. M. (1993, October). 3D statistical neuroanatomical models from 305 MRI volumes. 
% In 1993 IEEE conference record nuclear science symposium and medical imaging conference (pp. 1813-1817). IEEE.
% The spherical ROI was centered in the anterior cingulate cortex at MNI coordinates (±4, 34, 24). Coordinates are reported in Montreal Neurological Institute (MNI) stereotaxic space (Evans et al., 1993). 
% The selected region corresponds to the dorsal/rostral ACC implicated in affective processing and cognitive control (Shackman et al., 2011)

%% ACC L 

matlabbatch{5}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{5}.spm.util.voi.adjust = 0;
matlabbatch{5}.spm.util.voi.session = 1;
matlabbatch{5}.spm.util.voi.name = 'ACC_L';                        
matlabbatch{5}.spm.util.voi.roi{1}.mask.image = {lACC_mask_dir};
matlabbatch{5}.spm.util.voi.roi{1}.mask.threshold = 0.05;
% define ROI as sphere
matlabbatch{5}.spm.util.voi.roi{1}.sphere.centre = [-4 34 24];           
matlabbatch{5}.spm.util.voi.roi{1}.sphere.radius = 5;                       % other regions have 5mm sphere too, all regions should have the same size                             
matlabbatch{5}.spm.util.voi.roi{1}.sphere.move.fixed = 1;

matlabbatch{5}.spm.util.voi.expression = 'i1';

%% ACC R

matlabbatch{6}.spm.util.voi.spmmat = {spm_mat_dir};
matlabbatch{6}.spm.util.voi.adjust = 0;
matlabbatch{6}.spm.util.voi.session = 1;
matlabbatch{6}.spm.util.voi.name = 'ACC_R';                        
matlabbatch{6}.spm.util.voi.roi{1}.mask.image = {rACC_mask_dir};
matlabbatch{6}.spm.util.voi.roi{1}.mask.threshold = 0.05;
% define ROI as sphere
matlabbatch{6}.spm.util.voi.roi{1}.sphere.centre = [4 34 24];           
matlabbatch{6}.spm.util.voi.roi{1}.sphere.radius = 5;                       % other regions have 5mm sphere too, all regions should have the same size                   
matlabbatch{6}.spm.util.voi.roi{1}.sphere.move.fixed = 1;

matlabbatch{6}.spm.util.voi.expression = 'i1';

%% execute batch
% run created Batch
spm_jobman('run', matlabbatch); 

% print info
fprintf(1, 'ROI extraction for subject %s successful.\n', subName);

% move back to starting directory
cd(CWD);


