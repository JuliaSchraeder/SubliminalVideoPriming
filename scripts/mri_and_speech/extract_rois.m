%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract ROIs for each participant and create one .mat file with all time
% series data including the group information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the SPM.mat file
load('/bif/storage/storage1/projects/emocon/SecondLevel/VideoMask/FullFact/SPM.mat');

% Define the directory containing the ROI masks
roi_dir = '/bif/storage/storage1/projects/emocon/Scripts/mri_speech';  % Directory where the .nii ROI masks are stored

% Initialize a structure to store the extracted data per ROI
all_roi_data = struct();

% List all ROI masks (assuming you named them as 'Linguistic_ROI.nii', etc.)
roi_files = dir(fullfile(roi_dir, '*.nii'));

% Initialize a structure to hold the extracted data
extracted_data = struct();

% Loop over each ROI mask
for r = 1:length(roi_files)
    % Load the ROI mask
    roi_file = fullfile(roi_dir, roi_files(r).name);
    roi_V = spm_vol(roi_file);
    roi_mask = spm_read_vols(roi_V) > 0;  % Binary mask (1 = inside ROI, 0 = outside)

    % Extract the name of the ROI from the file name
    [~, roi_name, ~] = fileparts(roi_files(r).name);

    % Initialize storage for this ROI across all participants
    extracted_data.(roi_name) = struct();

    % Loop over each participant
    for i = 1:length(SPM.xY.VY)
        % Get the path to the participant's functional data from SPM.mat
        participant_file = SPM.xY.VY(i).fname;
        contrast_name = SPM.xY.VY(i).descrip;
        contrast_name = extractAfter(contrast_name, ":");
        contrast_name = erase(contrast_name, " ");
        
        % Extract participant name from the file path (e.g., 'sub-004')
        [~, participant_folder] = fileparts(fileparts(participant_file));
        participant_name = erase(participant_folder, "-");

        % Load the participant's functional data
        func_V = spm_vol(participant_file);
        func_data = spm_read_vols(func_V);

        % Check if dimensions match and if not, reslice the roi to match
        % the functional images
        if ~isequal(roi_V.dim, func_V.dim) || any(roi_V.mat(:) ~= func_V.mat(:))
            % Reslice ROI mask to match functional data dimensions
            spm_reslice({func_V.fname, roi_V.fname}, struct('mean', false, 'which', 1, 'interp', 0));
            % Reload the resliced ROI mask
            roi_V = spm_vol(roi_file);  % Assuming ROI file has been overwritten
            roi_mask = spm_read_vols(roi_V) > 0;
        end

        % Apply the ROI mask to the functional data
        roi_values = func_data(roi_mask);
        roi_values = roi_values(~isnan(roi_values)); % Remove NaNs

        % Compute the mean value within the ROI
        mean_value = mean(roi_values);

        % Store the result in the structure
        if ~isfield(extracted_data.(roi_name), contrast_name)
            extracted_data.(roi_name).(contrast_name) = struct();
        end
        extracted_data.(roi_name).(contrast_name).(participant_name) = mean_value;
    end
    
% Progress update for each ROI
disp(['Finished processing ROI: ', roi_name]);

end

% Save the extracted data for further analysis
save('extracted_roi_data.mat', 'extracted_data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
