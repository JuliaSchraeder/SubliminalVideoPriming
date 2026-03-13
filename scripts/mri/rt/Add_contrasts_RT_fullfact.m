%% Add contrasts to Full Factorial + RT model
%
% Copies contrast definitions from the original Fullfact SPM.mat
% and pads the contrast vectors for the new RT covariate column.
%
% Original covariate columns: [age, gender]         (2 cols)
% New model covariate columns: [RT, age, gender]    (3 cols)
% -> one extra zero is inserted before age/gender in each contrast vector.
%--------------------------------------------------------------------------

clear

%% Paths
Orig_SPM  = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/SPM.mat';
New_SPM   = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/rt/results_fullfact/SPM.mat';

%% Load both SPMs
orig = load(Orig_SPM);
new  = load(New_SPM);

n_orig = size(orig.SPM.xX.X, 2);   % number of parameters in original model
n_new  = size(new.SPM.xX.X,  2);   % number of parameters in new model

fprintf('Original model: %d parameters\n', n_orig);
fprintf('New model:      %d parameters\n', n_new);
fprintf('Difference:     %d (should be 1 = RT covariate)\n', n_new - n_orig);

if (n_new - n_orig) ~= 1
    warning('Parameter count difference is %d, expected 1. Check covariate setup.', n_new - n_orig);
end

% The RT covariate is the FIRST covariate column in the new model.
% In SPM Full Factorial, covariate columns come after the cell/factor columns.
% Find where covariates start in the original model.
% The extra column is inserted at position n_orig (1 before the last col of original)
% i.e. insert at: n_orig - (nCov_orig) + 1
% Simpler: pad at position n_orig (insert before the last column of original = before gender)
% Actually: Original has [factor_cols | age | gender]
%           New has      [factor_cols | RT  | age | gender]
% So the RT column is at position (n_orig - 1) in the new model (0-indexed),
% i.e., insert a zero at position (n_new - 2) relative to original.

% Insert position for the new RT column (1-indexed in MATLAB):
% original: [...factor_params..., age, gender]
%                                  ^col n_orig-1  ^col n_orig
% new:      [...factor_params..., RT, age, gender]
%                                  ^insert here = position (n_orig - 1)
insert_pos = n_orig - 1;   % insert zero at this position (1-indexed)

fprintf('Inserting RT zero column at position %d\n', insert_pos);

%% Build new contrast list
matlabbatch = {};
matlabbatch{1}.spm.stats.con.spmmat = {New_SPM};
matlabbatch{1}.spm.stats.con.delete = 1;   % delete any existing contrasts first

nCon = numel(orig.SPM.xCon);
fprintf('Copying %d contrasts from original model...\n', nCon);

for k = 1:nCon
    con = orig.SPM.xCon(k);
    ctype = con.STAT;   % 'T' or 'F'

    if strcmp(ctype, 'T')
        % T-contrast: row vector
        old_vec = con.c';   % [1 x n_orig]
        new_vec = [old_vec(1:insert_pos-1), 0, old_vec(insert_pos:end)];

        matlabbatch{1}.spm.stats.con.consess{k}.tcon.name    = con.name;
        matlabbatch{1}.spm.stats.con.consess{k}.tcon.convec  = new_vec;
        matlabbatch{1}.spm.stats.con.consess{k}.tcon.sessrep = 'none';

    elseif strcmp(ctype, 'F')
        % F-contrast: matrix [rows x n_orig]
        old_mat = con.c';   % [rows x n_orig]
        new_mat = [old_mat(:, 1:insert_pos-1), zeros(size(old_mat,1),1), old_mat(:, insert_pos:end)];

        matlabbatch{1}.spm.stats.con.consess{k}.fcon.name    = con.name;
        matlabbatch{1}.spm.stats.con.consess{k}.fcon.convec  = new_mat;
        matlabbatch{1}.spm.stats.con.consess{k}.fcon.sessrep = 'none';
    end

    fprintf('  [%s] %s\n', ctype, con.name);
end

%% Run
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

fprintf('\nDone. %d contrasts added to:\n  %s\n', nCon, New_SPM);
