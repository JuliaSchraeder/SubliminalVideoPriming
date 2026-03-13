

%% Full Factorial Design Primer Emotion x Conscious x HC/MDD

%Find FirstLevel Contrasts
clear                                                                                               
Data_Path = fullfile('/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/');     

HC_Subjects = {'sub-004','sub-006','sub-010','sub-011','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019',...
    'sub-022','sub-024','sub-025','sub-027','sub-028','sub-029','sub-030','sub-031','sub-032','sub-033','sub-034','sub-041',...
    'sub-043','sub-045','sub-046','sub-047','sub-050','sub-051','sub-052','sub-053','sub-054','sub-056','sub-057','sub-059',...
    'sub-062','sub-068','sub-069','sub-070','sub-071','sub-073','sub-074','sub-079','sub-080','sub-083','sub-085','sub-086',...
    'sub-089','sub-090','sub-091','sub-093','sub-096','sub-101','sub-103','sub-105','sub-119','sub-123','sub-125',...
    'sub-126','sub-127'};

MDD_Subjects = {'sub-007','sub-008','sub-009','sub-012','sub-020','sub-035','sub-036','sub-037','sub-038','sub-039',...
    'sub-042','sub-044','sub-048','sub-049','sub-061','sub-064','sub-065','sub-066','sub-072','sub-075','sub-076','sub-077',...
    'sub-081','sub-082','sub-084','sub-087','sub-092','sub-094','sub-095','sub-097','sub-098','sub-100','sub-102','sub-104',...
    'sub-106','sub-107','sub-108','sub-109','sub-110','sub-111','sub-113','sub-114','sub-115','sub-116','sub-117','sub-118',...
    'sub-121','sub-122','sub-124','sub-128','sub-129','sub-130','sub-131'};

% Get HC Contrasts
for i = 1:numel(HC_Subjects)                                                                           
    subName = HC_Subjects{i};  
    HC_happy_happy{i,:} = fullfile(Data_Path, subName,'con_0001.nii,1');
    HC_happy_sad{i,:} = fullfile(Data_Path, subName,'con_0002.nii,1');
    HC_sad_sad{i,:} = fullfile(Data_Path, subName,'con_0003.nii,1');
    HC_sad_happy{i,:} = fullfile(Data_Path, subName,'con_0004.nii,1');
end

% Get Patient Contrasts
for i = 1:numel(MDD_Subjects)
    subName = MDD_Subjects{i};
    MDD_happy_happy{i,:} = fullfile(Data_Path, subName,'con_0001.nii,1');
    MDD_happy_sad{i,:} = fullfile(Data_Path, subName,'con_0002.nii,1');
    MDD_sad_sad{i,:} = fullfile(Data_Path, subName,'con_0003.nii,1');
    MDD_sad_happy{i,:} = fullfile(Data_Path, subName,'con_0004.nii,1');
end

%% Define Design
matlabbatch{1}.spm.stats.factorial_design.dir = {'/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original'};
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

matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).name = 'group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).levels = 2;        % HC = 1, Patient = 2  
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).ancova = 0;

%% HC %%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                    1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = HC_happy_happy;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1
                                                                    2
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = HC_happy_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
                                                                    2
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = HC_sad_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
                                                                    1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = HC_sad_happy;

%% MDD %%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [1
                                                                    1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = MDD_happy_happy;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [1
                                                                    2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = MDD_happy_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [2
                                                                    2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = MDD_sad_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [2
                                                                    1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = MDD_sad_happy;

%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov.files = {'/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/regressor_video_age_gender.txt'};
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% Estimate created Batch
matlabbatch{2}.spm.stats.fmri_est.spmmat = {'/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/SPM.mat'};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


% Run created Batch
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
