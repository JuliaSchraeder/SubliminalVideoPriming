%% Copy contrasts from original SPM.mat to all ROI models
% Loads contrast definitions from the original whole-brain SPM.mat and
% applies the identical contrasts to each ROI model.

clear

%% Paths
original_spm  = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/SPM.mat';
output_base   = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/ROI/';
roi_names     = {'R_Amy', 'L_Amy', 'R_DLPFC', 'L_DLPFC', 'R_ACC', 'L_ACC'};

spm('Defaults', 'fMRI');
spm_jobman('initcfg');

%% Load original contrasts
orig = load(original_spm);
xCon_orig = orig.SPM.xCon;
fprintf('Found %d contrasts in original SPM.mat\n', numel(xCon_orig));

for c = 1:numel(xCon_orig)
    fprintf('  [%02d] %s (%s)\n', c, xCon_orig(c).name, xCon_orig(c).STAT);
end

%% Apply to each ROI model
for r = 1:numel(roi_names)

    roi_name     = roi_names{r};
    roi_spm_path = fullfile(output_base, roi_name, 'SPM.mat');

    if ~exist(roi_spm_path, 'file')
        warning('SPM.mat not found for ROI %s, skipping.\n', roi_name);
        continue
    end

    fprintf('\n=== Adding contrasts for ROI: %s ===\n', roi_name);

    clear matlabbatch

    for c = 1:numel(xCon_orig)
        con = xCon_orig(c);

        matlabbatch{1}.spm.stats.con.spmmat = {roi_spm_path};

        if strcmp(con.STAT, 'T')
            matlabbatch{1}.spm.stats.con.consess{c}.tcon.name    = con.name;
            matlabbatch{1}.spm.stats.con.consess{c}.tcon.weights = con.c';   % row vector
            matlabbatch{1}.spm.stats.con.consess{c}.tcon.sessrep = 'none';
        elseif strcmp(con.STAT, 'F')
            matlabbatch{1}.spm.stats.con.consess{c}.fcon.name    = con.name;
            matlabbatch{1}.spm.stats.con.consess{c}.fcon.weights = con.c';
            matlabbatch{1}.spm.stats.con.consess{c}.fcon.sessrep = 'none';
        end
    end

    matlabbatch{1}.spm.stats.con.delete = 1;   % delete existing contrasts first (clean slate)

    spm_jobman('run', matlabbatch);
    fprintf('Done: %s\n', roi_name);
end

fprintf('\nAll contrasts added.\n');
