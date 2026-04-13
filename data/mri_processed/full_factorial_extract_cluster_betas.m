%% Extract mean contrast values per subject per condition within cluster
% Uses the VOI .mat (from SPM Results -> eigenvariate) to define the cluster,
% then extracts the mean contrast value of each condition within that cluster
% for every subject. Output: CSV for plotting in Python / R.
%
% Conditions (from First Level):
%   con_0001 = happy_primer_happy_target
%   con_0002 = happy_primer_sad_target
%   con_0003 = sad_primer_sad_target
%   con_0004 = sad_primer_happy_target

clear

%% ---- Settings ------------------------------------------------------------
firstlevel_path = '/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/';
voi_file        = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/results/VOI_EOI_original.mat';
% if you want to use the MDD>HC VOI instead, change to:
% voi_file = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/results/VOI_MDD_over_HC_VOI_New.mat';

output_csv = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/results/cluster_betas_per_subject.csv';

con_files   = {'con_0001.nii', 'con_0002.nii', 'con_0003.nii', 'con_0004.nii'};
con_labels  = {'happy_primer_happy_target', 'happy_primer_sad_target', ...
               'sad_primer_sad_target',     'sad_primer_happy_target'};

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

%% ---- Load VOI: get cluster voxel coordinates ----------------------------
fprintf('Loading VOI: %s\n', voi_file);
voi = load(voi_file);

% SPM VOI .mat contains xY with XYZmm (MNI coordinates of cluster voxels)
XYZmm = voi.xY.XYZmm;   % 3 x N_voxels  (MNI mm)
fprintf('Cluster size: %d voxels\n\n', size(XYZmm, 2));

%% ---- Write CSV header ----------------------------------------------------
fid = fopen(output_csv, 'w');
fprintf(fid, 'subject,group,condition,mean_contrast\n');

%% ---- Extract values: HC --------------------------------------------------
all_subjects = [HC_Subjects, MDD_Subjects];
all_groups   = [repmat({'HC'}, 1, numel(HC_Subjects)), repmat({'MDD'}, 1, numel(MDD_Subjects))];

for s = 1:numel(all_subjects)
    subName = all_subjects{s};
    group   = all_groups{s};

    for cond = 1:numel(con_files)
        con_path = fullfile(firstlevel_path, subName, con_files{cond});

        if ~exist(con_path, 'file')
            fprintf('WARNING: %s not found, skipping.\n', con_path);
            fprintf(fid, '%s,%s,%s,NaN\n', subName, group, con_labels{cond});
            continue
        end

        % Load contrast image header
        V = spm_vol(con_path);

        % Extract values at cluster voxel coordinates
        % spm_get_data expects voxel-space coordinates -> transform via inv(mat)
        XYZ_vox = V.mat \ [XYZmm; ones(1, size(XYZmm, 2))];  % 4 x N
        vals    = spm_get_data(V, XYZ_vox(1:3, :));           % 1 x N

        % Remove NaN (voxels outside brain mask for this subject)
        vals = vals(~isnan(vals));

        if isempty(vals)
            mean_val = NaN;
            fprintf('WARNING: all NaN for %s %s\n', subName, con_files{cond});
        else
            mean_val = mean(vals);
        end

        fprintf(fid, '%s,%s,%s,%.6f\n', subName, group, con_labels{cond}, mean_val);
    end

    fprintf('Done: %s (%s)\n', subName, group);
end

fclose(fid);
fprintf('\nCSV saved to: %s\n', output_csv);
fprintf('Ready for plotting in Python / R.\n');
