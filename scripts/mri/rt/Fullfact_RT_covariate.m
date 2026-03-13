%% Full Factorial Design + RT as covariate
%
% Same design as Fullfact_VideoMask.m (primer x target x group),
% but with condition-specific RT (mean-centered) as additional covariate.
%
% This tests whether group/interaction effects in neural activation
% survive after controlling for reaction time.
%
% Subjects: 102 (53 HC + 49 MDD) — subjects without RT data excluded.
% Covariate file: rt_fullfact_cov.txt  [408 rows x 3 cols: RT age gender]
%   Row order matches SPM scan order:
%     HC_HH, HC_HS, HC_SS, HC_SH, MDD_HH, MDD_HS, MDD_SS, MDD_SH
%   (within each cell: same subject order as HC_subs_rt.txt / MDD_subs_rt.txt)
%--------------------------------------------------------------------------

clear

%% Paths
Data_Path  = '/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/';
Out_Dir    = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/rt/results_fullfact/';
Cov_File   = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/rt/rt_fullfact_cov.txt';
HC_list    = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/rt/HC_subs_rt.txt';
MDD_list   = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/rt/MDD_subs_rt.txt';

%% Read subject lists from txt files
fid = fopen(HC_list, 'r');
if fid == -1, error('Cannot open: %s', HC_list); end
HC_Subjects = {};
while ~feof(fid)
    line = strtrim(fgetl(fid));
    if ischar(line) && ~isempty(line)
        HC_Subjects{end+1} = line;
    end
end
fclose(fid);

fid = fopen(MDD_list, 'r');
if fid == -1, error('Cannot open: %s', MDD_list); end
MDD_Subjects = {};
while ~feof(fid)
    line = strtrim(fgetl(fid));
    if ischar(line) && ~isempty(line)
        MDD_Subjects{end+1} = line;
    end
end
fclose(fid);

fprintf('HC: %d, MDD: %d subjects\n', numel(HC_Subjects), numel(MDD_Subjects));

%% Build contrast file lists
% con_0001=HH, con_0002=HS, con_0003=SS, con_0004=SH
for i = 1:numel(HC_Subjects)
    subName = HC_Subjects{i};
    HC_happy_happy{i,:} = fullfile(Data_Path, subName, 'con_0001.nii,1');
    HC_happy_sad{i,:}   = fullfile(Data_Path, subName, 'con_0002.nii,1');
    HC_sad_sad{i,:}     = fullfile(Data_Path, subName, 'con_0003.nii,1');
    HC_sad_happy{i,:}   = fullfile(Data_Path, subName, 'con_0004.nii,1');
end

for i = 1:numel(MDD_Subjects)
    subName = MDD_Subjects{i};
    MDD_happy_happy{i,:} = fullfile(Data_Path, subName, 'con_0001.nii,1');
    MDD_happy_sad{i,:}   = fullfile(Data_Path, subName, 'con_0002.nii,1');
    MDD_sad_sad{i,:}     = fullfile(Data_Path, subName, 'con_0003.nii,1');
    MDD_sad_happy{i,:}   = fullfile(Data_Path, subName, 'con_0004.nii,1');
end

%% SPM batch
if ~exist(Out_Dir, 'dir'), mkdir(Out_Dir); end

matlabbatch{1}.spm.stats.factorial_design.dir = {Out_Dir};

% ── Factors ──────────────────────────────────────────────────────────────
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name     = 'emotion_primer';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels   = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept     = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca    = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova   = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name     = 'emotion_target';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels   = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept     = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca    = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova   = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).name     = 'group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).levels   = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).dept     = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).gmsca    = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).ancova   = 0;

% ── Cells: HC (group=1) ───────────────────────────────────────────────────
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1;1;1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans  = HC_happy_happy;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1;2;1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans  = HC_happy_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2;2;1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans  = HC_sad_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2;1;1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans  = HC_sad_happy;

% ── Cells: MDD (group=2) ─────────────────────────────────────────────────
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [1;1;2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans  = MDD_happy_happy;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [1;2;2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans  = MDD_happy_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [2;2;2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans  = MDD_sad_sad;

matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [2;1;2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans  = MDD_sad_happy;

matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;

% ── Covariates: RT + age + gender ────────────────────────────────────────
% rt_fullfact_cov.txt: 3 columns (RT_centered, age_centered, gender)
% iCFI=1: no interaction with factor (pooled across groups)
% iCC=5:  no additional centering (already centered in Python)
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov.files = {Cov_File};
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCFI  = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCC   = 5;

% ── Masking & globals ────────────────────────────────────────────────────
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none     = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im             = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em             = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit         = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm        = 1;

% ── Estimate ─────────────────────────────────────────────────────────────
matlabbatch{2}.spm.stats.fmri_est.spmmat          = {fullfile(Out_Dir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% Run
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

fprintf('\nDone. Model saved to: %s\n', Out_Dir);
fprintf('Add contrasts manually in SPM or run Add_contrasts_fullfact.m\n');
