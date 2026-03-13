%% Full Factorial Design Primer Emotion x Conscious

%Find FirstLevel Contrasts
clear                                                                                               
Data_Path = fullfile('/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/');     

MDD_Subjects = {'sub-007','sub-008','sub-009','sub-012','sub-020','sub-035','sub-036','sub-037','sub-038','sub-039',...
    'sub-042','sub-044','sub-048','sub-049','sub-061','sub-064','sub-065','sub-066','sub-072','sub-075','sub-076','sub-077',...
    'sub-081','sub-082','sub-084','sub-087','sub-092','sub-094','sub-095','sub-097','sub-098','sub-100','sub-102','sub-104',...
    'sub-106','sub-107','sub-108','sub-109','sub-110','sub-111','sub-113','sub-114','sub-115','sub-116','sub-117','sub-118',...
    'sub-121','sub-122','sub-124','sub-128','sub-129','sub-130','sub-131'};

% Get Patient Contrasts
for i = 1:numel(MDD_Subjects)
    subName = MDD_Subjects{i};
    MDD_happy_happy{i,:} = fullfile(Data_Path, subName,'con_0001.nii,1');
    MDD_happy_sad{i,:} = fullfile(Data_Path, subName,'con_0002.nii,1');
    MDD_sad_sad{i,:} = fullfile(Data_Path, subName,'con_0003.nii,1');
    MDD_sad_happy{i,:} = fullfile(Data_Path, subName,'con_0004.nii,1');
end

%% Define Design
matlabbatch{1}.spm.stats.factorial_design.dir = {'/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/MDD'};
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'emotion_primer';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;        % happy = 1, sad = 2
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;                                          
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;      % varianzengleichheit ja = 1 nein = 0
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'emotion_target';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;        % happy = 1, sad = 2
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;

%% MDD %%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = MDD_happy_happy;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = MDD_happy_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = MDD_sad_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = MDD_sad_happy;

%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov.files = {'/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/MDD/patient_regressors_spm.txt'};
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% Estimate created Batch
matlabbatch{2}.spm.stats.fmri_est.spmmat = {'/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/MDD/SPM.mat'};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% Run created Batch
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
