%% Extract ROI condition values for R analysis (AAL3 masks, bilateral)
% Purpose:
%   Extract mean first-level condition contrast values (con_0001..con_0004)
%   for each subject and each a priori ROI mask (L/R Amygdala, ACC, dlPFC).
%
% Output (long-format CSV):
%   subject,group,group_num,roi,hemisphere,condition,con_file,con_index,
%   primer,target,congruency,mean_contrast,image_path
%
% Notes:
%   - Update the path section below to your environment.
%   - This script is for ROI-value extraction (signal-level analysis in R),
%     complementary to voxel-wise SVC.

clear

%% --------------------------- Paths ----------------------------------------
% This script supports two common setups:
% 1) Server paths (project-internal /bif structure)
% 2) Local repo execution (this file in scripts/mri/ROI)

server_firstlevel = '/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/';
server_roi_folder = '/bif/storage/storage1/projects/emocon/Scripts/VideoMask/ROI/';

this_file = mfilename('fullpath');
if isempty(this_file)
    this_file = pwd;
end
local_roi_folder = fileparts(this_file);

if exist(server_firstlevel, 'dir') && exist(server_roi_folder, 'dir')
    firstlevel_path = server_firstlevel;
    script_folder   = server_roi_folder;
else
    firstlevel_path = '/Users/julia/Desktop/Git/SubliminalVideoPriming/data/mri/firstlevel/';
    script_folder   = local_roi_folder;
end

output_csv = fullfile(local_roi_folder, 'results', 'roi_condition_values_long.csv');

%% ----------------------- Subject lists ------------------------------------
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

all_subjects = [HC_Subjects, MDD_Subjects];
all_groups   = [repmat({'HC'}, 1, numel(HC_Subjects)), repmat({'MDD'}, 1, numel(MDD_Subjects))];
all_groupnum = [ones(1, numel(HC_Subjects)), 2 * ones(1, numel(MDD_Subjects))];

%% ---------------------- ROI definitions -----------------------------------
roi_names  = {'R_Amy','L_Amy','R_DLPFC','L_DLPFC','R_ACC','L_ACC'};
roi_files  = {'R_Amy.nii','L_Amy.nii','R_DLPFC.nii','L_DLPFC.nii','R_ACC.nii','L_ACC.nii'};
hemis      = {'R','L','R','L','R','L'};

%% -------------------- Condition/contrast map -------------------------------
% Mapping from your first-level model
con_files     = {'con_0001.nii','con_0002.nii','con_0003.nii','con_0004.nii'};
condition_lbl = {'happy_happy','happy_sad','sad_sad','sad_happy'};
primer_lbl    = {'happy','happy','sad','sad'};
target_lbl    = {'happy','sad','sad','happy'};
congruency    = {'congruent','incongruent','congruent','incongruent'};

%% -------------------- Init SPM + output file ------------------------------
spm('Defaults','fMRI');
spm_jobman('initcfg');

out_dir = fileparts(output_csv);
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

fid = fopen(output_csv, 'w');
if fid == -1
    error('Could not open output CSV: %s', output_csv);
end

fprintf(fid, 'subject,group,group_num,roi,hemisphere,condition,con_file,con_index,primer,target,congruency,mean_contrast,image_path\n');

%% ------------------------- Extraction loop --------------------------------
n_written = 0;
n_missing = 0;

for s = 1:numel(all_subjects)
    subject_id = all_subjects{s};
    group_id   = all_groups{s};
    group_num  = all_groupnum(s);

    for r = 1:numel(roi_names)
        roi_name = roi_names{r};
        hemi     = hemis{r};
        roi_path = fullfile(script_folder, roi_files{r});

        if ~exist(roi_path, 'file')
            warning('Missing ROI mask: %s', roi_path);
            continue
        end

        for c = 1:numel(con_files)
            img_path = fullfile(firstlevel_path, subject_id, con_files{c});

            if ~exist(img_path, 'file')
                n_missing = n_missing + 1;
                fprintf('WARNING missing image: %s\n', img_path);
                fprintf(fid, '%s,%s,%d,%s,%s,%s,%s,%d,%s,%s,%s,NaN,%s\n', ...
                    subject_id, group_id, group_num, roi_name, hemi, condition_lbl{c}, con_files{c}, c, ...
                    primer_lbl{c}, target_lbl{c}, congruency{c}, img_path);
                continue
            end

            try
                mean_val = spm_summarise(img_path, roi_path, @mean);
            catch ME
                warning('spm_summarise failed for %s | %s: %s', img_path, roi_path, ME.message);
                mean_val = NaN;
            end

            fprintf(fid, '%s,%s,%d,%s,%s,%s,%s,%d,%s,%s,%s,%.6f,%s\n', ...
                subject_id, group_id, group_num, roi_name, hemi, condition_lbl{c}, con_files{c}, c, ...
                primer_lbl{c}, target_lbl{c}, congruency{c}, mean_val, img_path);
            n_written = n_written + 1;
        end
    end

    fprintf('Done %s (%s)\n', subject_id, group_id);
end

fclose(fid);

fprintf('\nExtraction complete.\n');
fprintf('Rows written: %d\n', n_written);
fprintf('Missing images: %d\n', n_missing);
fprintf('Output CSV: %s\n', output_csv);
