%% Small Volume Correction (SVC) - ROI analysis on existing whole-brain model
% Uses the original Full Factorial SPM.mat.
% For each contrast x ROI:
%   1. Gets all suprathreshold voxels (p<0.001 unc) within the ROI mask
%   2. Computes proper SVC-FWE threshold using Gaussian Field Theory
%      corrected for the ROI search volume (using RPV.nii)
%   3. Reports peaks to console + one combined CSV
%
% This is statistically equivalent to SPM's "small volume correction" button.

clear

%% ---- Settings (adapt paths if needed) ------------------------------------
original_spm = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/original/SPM.mat';
ROI_folder   = '/bif/storage/storage1/projects/emocon/Scripts/VideoMask/ROI/';
output_dir   = '/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/SVC_results/';

roi_names = {'R_Amy',     'L_Amy',     'R_DLPFC',     'L_DLPFC',     'R_ACC',     'L_ACC'};
roi_files = {'R_Amy.nii', 'L_Amy.nii', 'R_DLPFC.nii', 'L_DLPFC.nii', 'R_ACC.nii', 'L_ACC.nii'};

unc_thresh = 0.001;  % initial threshold to find candidate voxels
fwe_thresh = 0.05;   % SVC-FWE alpha level
extent_k   = 0;      % minimum cluster size

%% ---- Init ----------------------------------------------------------------
spm('Defaults','fMRI');
if ~exist(output_dir,'dir'); mkdir(output_dir); end

%% ---- Load SPM ------------------------------------------------------------
fprintf('Loading SPM.mat...\n');
load(original_spm, 'SPM');
n_con = numel(SPM.xCon);
fprintf('Found %d contrasts.\n\n', n_con);
for c = 1:n_con
    fprintf('  [%02d] %s (%s)\n', c, SPM.xCon(c).name, SPM.xCon(c).STAT);
end
fprintf('\n');

%% ---- Load RPV for resel computation --------------------------------------
RPV_file = fullfile(fileparts(original_spm), 'RPV.nii');
if exist(RPV_file,'file')
    Vrpv   = spm_vol(RPV_file);
    rpv_vol = spm_read_vols(Vrpv);
    use_rpv = true;
    fprintf('RPV.nii found - using exact resel counts for SVC.\n\n');
else
    use_rpv = false;
    warning('RPV.nii not found - resel counts will be approximated.');
end

%% ---- Output CSV ----------------------------------------------------------
out_csv = fullfile(output_dir, 'SVC_results_all.csv');
fid = fopen(out_csv, 'w');
fprintf(fid, 'ROI,ContrastNr,ContrastName,STAT,x_MNI,y_MNI,z_MNI,StatVal,p_unc,p_FWE_SVC,survives_FWE_SVC\n');

%% ---- Main loop -----------------------------------------------------------
for r = 1:numel(roi_names)

    roi_name  = roi_names{r};
    Vmask     = spm_vol(fullfile(ROI_folder, roi_files{r}));
    roi_vol   = spm_read_vols(Vmask);
    n_roi_vox = sum(roi_vol(:) > 0);

    % Resel count for this ROI
    % (RPV.nii and ROI mask may have different voxel grids -> resample ROI to RPV space)
    if use_rpv
        [xi,yi,zi]   = ndgrid(1:size(rpv_vol,1), 1:size(rpv_vol,2), 1:size(rpv_vol,3));
        XYZ_rpv_vox  = [xi(:)'; yi(:)'; zi(:)'];
        XYZmm_rpv    = Vrpv.mat(1:3,:) * [XYZ_rpv_vox; ones(1, size(XYZ_rpv_vox,2))];
        roi_vals     = spm_get_data(Vmask, Vmask.mat \ [XYZmm_rpv; ones(1, size(XYZmm_rpv,2))]);
        roi_mask_rpv = reshape(roi_vals > 0, size(rpv_vol));
        rpv_in_roi   = rpv_vol .* roi_mask_rpv;
        R_roi = sum(rpv_in_roi(~isnan(rpv_in_roi(:))));
    end

    fprintf('=== ROI: %-10s  (%d voxels) ===\n', roi_name, n_roi_vox);

    for c = 1:n_con

        con_name = SPM.xCon(c).name;
        STAT     = SPM.xCon(c).STAT;

        % Get thresholded results at p<0.001 unc
        xSPM_in = struct(...
            'swd',       fileparts(original_spm), ...
            'title',     '', ...
            'Ic',        c, ...
            'n',         1, ...
            'Im',        [], ...
            'pm',        [], ...
            'Ex',        [], ...
            'u',         unc_thresh, ...
            'k',         extent_k, ...
            'thresDesc', 'none');

        try
            [~, xSPM] = spm_getSPM(xSPM_in);
        catch ME
            fprintf('  [%02d] %-35s  ERROR: %s\n', c, con_name, ME.message);
            continue
        end

        if isempty(xSPM.Z)
            fprintf('  [%02d] %-35s  no voxels at p<%.3f unc.\n', c, con_name, unc_thresh);
            continue
        end

        % Find voxels inside ROI mask
        XYZmm = xSPM.XYZmm;
        Z_all = xSPM.Z;
        df    = xSPM.df;

        in_roi = false(1, size(XYZmm,2));
        for v = 1:size(XYZmm,2)
            vox = round(Vmask.mat \ [XYZmm(:,v); 1]);
            ix=vox(1); iy=vox(2); iz=vox(3);
            if ix>=1 && iy>=1 && iz>=1 && ...
               ix<=size(roi_vol,1) && iy<=size(roi_vol,2) && iz<=size(roi_vol,3)
                if roi_vol(ix,iy,iz) > 0
                    in_roi(v) = true;
                end
            end
        end

        Z_roi   = Z_all(in_roi);
        XYZ_roi = XYZmm(:, in_roi);

        if isempty(Z_roi)
            fprintf('  [%02d] %-35s  no voxels inside ROI.\n', c, con_name);
            continue
        end

        % If RPV not available: scale resels proportionally
        if ~use_rpv
            R_roi = xSPM.R * (n_roi_vox / xSPM.S);
        end

        % SVC-FWE critical threshold
        u_svc = spm_uc(fwe_thresh, df, STAT, R_roi, 1);

        % Report global peak within ROI
        [~, peak_idx] = max(Z_roi);
        z_peak   = Z_roi(peak_idx);
        xyz_peak = XYZ_roi(:, peak_idx);

        % p-values
        p_unc_peak = spm_P(1, 0, z_peak, df, STAT, xSPM.R, 1, xSPM.S);   % whole-brain unc
        p_fwe_svc  = spm_P(1, 0, z_peak, df, STAT, R_roi,  1, n_roi_vox); % SVC-FWE

        survives = z_peak >= u_svc;

        fprintf('  [%02d] %-35s  [%4.0f %4.0f %4.0f]  %s=%.2f  p_unc=%.4f  p_FWE_SVC=%.4f  %s\n', ...
            c, con_name, xyz_peak(1), xyz_peak(2), xyz_peak(3), ...
            STAT, z_peak, p_unc_peak, p_fwe_svc, ...
            string(survives).replace('1','*** SIGN ***').replace('0',''));

        fprintf(fid, '%s,%d,%s,%s,%.1f,%.1f,%.1f,%.3f,%.4f,%.4f,%d\n', ...
            roi_name, c, con_name, STAT, ...
            xyz_peak(1), xyz_peak(2), xyz_peak(3), ...
            z_peak, p_unc_peak, p_fwe_svc, survives);

    end % contrast loop
    fprintf('\n');
end % ROI loop

fclose(fid);
fprintf('=== Done. Results saved to: %s ===\n', out_csv);
