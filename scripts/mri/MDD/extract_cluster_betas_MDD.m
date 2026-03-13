%% Extract mean contrast values per MDD subject per condition within cluster
% Uses a VOI .mat from the MDD-only SPM model to define the cluster,
% then extracts the mean contrast value of each condition within that cluster
% for every MDD subject.
%
% BEFORE RUNNING: save a VOI in SPM from the MDD results:
%   SPM -> Results -> load MDD SPM.mat -> select contrast -> threshold
%   -> right-click in results table -> "save VOI" -> save as VOI_EOI_MDD.mat
%   in new_mri/MDD/results/
%
% Conditions (First Level):
%   con_0001 = happy_primer_happy_target
%   con_0002 = happy_primer_sad_target
%   con_0003 = sad_primer_sad_target
%   con_0004 = sad_primer_happy_target

clear

%% ---- Settings ------------------------------------------------------------
firstlevel_path = '/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/';
voi_file        = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/MDD/VOI_EOI_MDD.mat';
output_csv      = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/MDD/cluster_betas_MDD.csv';

con_files  = {'con_0001.nii', 'con_0002.nii', 'con_0003.nii', 'con_0004.nii'};
con_labels = {'happy_primer_happy_target', 'happy_primer_sad_target', ...
              'sad_primer_sad_target',     'sad_primer_happy_target'};

MDD_Subjects = {'sub-007','sub-008','sub-009','sub-012','sub-020','sub-035','sub-036','sub-037','sub-038','sub-039',...
    'sub-042','sub-044','sub-048','sub-049','sub-061','sub-064','sub-065','sub-066','sub-072','sub-075','sub-076','sub-077',...
    'sub-081','sub-082','sub-084','sub-087','sub-092','sub-094','sub-095','sub-097','sub-098','sub-100','sub-102','sub-104',...
    'sub-106','sub-107','sub-108','sub-109','sub-110','sub-111','sub-113','sub-114','sub-115','sub-116','sub-117','sub-118',...
    'sub-121','sub-122','sub-124','sub-128','sub-129','sub-130','sub-131'};

%% ---- Load VOI ------------------------------------------------------------
fprintf('Loading VOI: %s\n', voi_file);
voi   = load(voi_file);
XYZmm = voi.xY.XYZmm;   % 3 x N_voxels (MNI mm)
fprintf('Cluster size: %d voxels\n\n', size(XYZmm, 2));

%% ---- Extract -------------------------------------------------------------
fid = fopen(output_csv, 'w');
fprintf(fid, 'subject,condition,mean_contrast\n');

for s = 1:numel(MDD_Subjects)
    subName = MDD_Subjects{s};

    for cond = 1:numel(con_files)
        con_path = fullfile(firstlevel_path, subName, con_files{cond});

        if ~exist(con_path, 'file')
            fprintf('WARNING: %s not found, skipping.\n', con_path);
            fprintf(fid, '%s,%s,NaN\n', subName, con_labels{cond});
            continue
        end

        V       = spm_vol(con_path);
        XYZ_vox = V.mat \ [XYZmm; ones(1, size(XYZmm, 2))];
        vals    = spm_get_data(V, XYZ_vox(1:3, :));
        vals    = vals(~isnan(vals));

        mean_val = mean(vals);
        fprintf(fid, '%s,%s,%.6f\n', subName, con_labels{cond}, mean_val);
    end

    fprintf('Done: %s\n', subName);
end

fclose(fid);
fprintf('\nCSV saved to: %s\n', output_csv);
