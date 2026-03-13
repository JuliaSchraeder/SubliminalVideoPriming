%% Whole-brain regression: RT -> neural activation (per condition)
%
% Design: SPM multiple regression, one model per condition
%   Scans:      first-level contrast images (con_000x.nii), 102 subjects
%               (subjects without behavioral data excluded)
%   Regressors (from regressors_<cond>.txt, columns):
%               [1] RT (mean-centered)       <- main predictor of interest
%               [2] group (0=HC, 1=MDD)      <- nuisance
%               [3] age  (mean-centered)     <- nuisance
%               [4] gender (1=male, 2=female) <- nuisance
%
% Contrasts (parameter order in SPM: intercept, RT, group, age, gender):
%   [0  1  0  0  0]  RT_positive  (slower -> more activation)
%   [0 -1  0  0  0]  RT_negative  (faster -> more activation)
%   [0  0  1  0  0]  group MDD > HC  (controlling for RT)
%   [0  0 -1  0  0]  group HC > MDD  (controlling for RT)
%
% Addresses reviewer comment: is occipital hyperactivation simply a
% correlate of slower RT in MDD?
%--------------------------------------------------------------------------

clear

%% Paths
Data_Path  = '/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/';
OutBase    = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/RT_regression/';
RegBase    = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/RT_regression/';
% RegBase is where the regressors_<cond>.txt and regressors.csv files live

%% Conditions
conditions = {'happy_happy', 'happy_sad', 'sad_sad', 'sad_happy'};
con_files  = {'con_0001.nii', 'con_0002.nii', 'con_0003.nii', 'con_0004.nii'};

%% Run one model per condition
for c = 1:numel(conditions)
    cond_label = conditions{c};
    con_file   = con_files{c};

    fprintf('\n=== Processing condition: %s ===\n', cond_label);

    % ── Load subject IDs for this condition from CSV ──────────────────────
    % reads col 1 (ID) where col 3 (Condition) matches cond_label
    csv_path = fullfile(RegBase, 'regressors.csv');
    fid = fopen(csv_path, 'r');
    if fid == -1
        error('Cannot open file: %s\nCheck that RegBase path is correct and the file exists.', csv_path);
    end
    fgetl(fid);   % skip header
    subIDs = {};
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(line)
            parts = strsplit(line, ',');
            if strcmp(strtrim(parts{3}), cond_label)
                subIDs{end+1} = strtrim(parts{1});
            end
        end
    end
    fclose(fid);

    n_sub = numel(subIDs);
    fprintf('  Subjects: %d\n', n_sub);

    % ── Load numeric regressors (tab-separated txt, no header) ───────────
    % Columns: rt_centered  group  age_centered  gender
    reg_file = fullfile(RegBase, ['regressors_' cond_label '.txt']);
    if ~exist(reg_file, 'file')
        error('Regressor file not found: %s', reg_file);
    end
    R = load(reg_file);   % [n_sub x 4]

    if size(R, 1) ~= n_sub
        error('Row mismatch: CSV %d subjects, txt %d rows', n_sub, size(R,1));
    end

    rt_centered  = R(:, 1);
    grp_vec      = R(:, 2);
    age_centered = R(:, 3);
    gender_vec   = R(:, 4);

    % ── Build scan list (same order as txt / CSV) ─────────────────────────
    scans = cell(n_sub, 1);
    for s = 1:n_sub
        scans{s} = fullfile(Data_Path, subIDs{s}, [con_file ',1']);
    end

    % ── Output directory ──────────────────────────────────────────────────
    out_dir = fullfile(OutBase, cond_label);
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    %% SPM batch ──────────────────────────────────────────────────────────
    matlabbatch = {};

    % --- Multiple regression design ---
    matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scans;

    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c     = rt_centered;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'RT';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).iCC   = 5;  % no additional centering (already centered)

    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).c     = grp_vec;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).cname = 'group';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).iCC   = 5;  % no centering

    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(3).c     = age_centered;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(3).cname = 'age';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(3).iCC   = 5;  % no additional centering

    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(4).c     = gender_vec;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(4).cname = 'gender';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(4).iCC   = 5;  % no centering

    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;  % include intercept

    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none     = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im             = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em             = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit         = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm        = 1;

    % --- Estimate ---
    matlabbatch{2}.spm.stats.fmri_est.spmmat          = {fullfile(out_dir, 'SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % --- Contrasts ---
    % SPM parameter order: [intercept, RT, group, age, gender]
    %                           1        2    3     4     5
    matlabbatch{3}.spm.stats.con.spmmat = {fullfile(out_dir, 'SPM.mat')};

    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name    = 'RT_positive';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec  = [0  1  0  0  0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name    = 'RT_negative';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec  = [0 -1  0  0  0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name    = 'group_MDD_gt_HC';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec  = [0  0  1  0  0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name    = 'group_HC_gt_MDD';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec  = [0  0 -1  0  0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.delete = 0;

    %% Run
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);

    fprintf('  Done: %s\n', out_dir);
end

fprintf('\n=== All conditions complete ===\n');
