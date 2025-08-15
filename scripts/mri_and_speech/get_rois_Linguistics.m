%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define and extract ROIs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%addpath 'C:\Users\juhoffmann\Desktop\spm12'

% Initialize SPM and MarsBaR
spm('Defaults','fMRI');
spm_jobman('initcfg');
%marsbar('on');

% Define your ROIs with their coordinates, categories, and functions
rois = {
    'Amygdala', [-18, -6, -12], [], 'Emotion processing';
    'Caudate_nucleus',[-12, -4, 14], [-16, 16, 8],'Motor execution (suppressing unintended motor activity)';
    'Subcallosal_gyrus_BA34', [26, 6, -10], [], 'Emotion and autonomic function';
    'IFG_pOp_BA44', [54, 8, 6], [48, 8, 15], 'Short-term memory and integrating inputs, sequencing motor activity';
    'IFG_pOp_BA44_2', [-42, 2, 6], [-44, 14, 10], 'Short-term memory and integrating inputs, sequencing motor activity';

    'IFG_pTri_BA45', [-46, 22, 12], [], 'Semantic decisions/semantic reading';

    'IFG_pOrb_BA47', [48,14, 0], [46,20,2], 'Selection/retrieval of semantic concepts/words';
    'IFG_pOrb_BA47_2', [38,26,0], [], 'Selection/retrieval of semantic concepts/words';
    'IFG_pOrb_BA47_3', [40,22,-2], [], 'Selection/retrieval of semantic concepts/words';

    'Insula_BA13', [], [54, -36, 20], 'Control of breathing during production of speech';
    'aInsula_BA13', [-32,22,2], [-32,18,6], 'Control of breathing during production of speech';
    'aInsula_BA13_2', [], [42,8,12], 'Control of breathing during production of speech';

    'aSTG_BA22', [54,0,4], [], 'Early auditory processing of complex sounds';
    'aSTG_BA22_2', [-50, 10, 2], [], 'Early auditory processing of complex sounds';
    
    'pSTG_BA22', [46, -24, 0], [-48, -46, 12], 'Auditory processing/word retrieval with minimal semantics';
    'pSTG_BA22_2', [46, -32, 4], [46, -24, 0], 'Auditory processing/word retrieval with minimal semantics';
    'pSTG_BA22_3', [56,-44,4], [], 'Auditory processing/word retrieval with minimal semantics';

    'Heschls_gyrus_BA41', [], [48, -32, 8], 'Early auditory processing';

    'MTG_BA21', [44, -4, -16], [], 'Accessing semantics during word production tasks';

    'MFG_BA9', [48, 16, 28], [46, 14, 30], 'Retrieving words for speech production';
    'MFG_BA9_2', [], [-40, 6, 34], 'Retrieving words for speech production';

    'MFG_BA10', [34, 36, 10], [], 'Retrieving words for speech production';

    'SMA_BA6',[8, 18, 50], [4, 16, 48], 'Sequencing execution of motor movements (speech and fingers)';
    'SMA_BA6_2', [], [8, 26, 42], 'Sequencing execution of motor movements (speech and fingers)';
    'SMA_BA6_3', [0, 14, 48], [], 'Sequencing execution of motor movements (speech and fingers)';

    'Claustrum', [], [26, 16, 4], 'Sensory integration';
    'Thalamus', [-8, -6, 10], [], 'Control of breathing during speech production';
    'Putamen', [-22, 14, -12], [], 'Timing of motor output';
    'Parahippocampal_gyrus_BA28', [16,-10,-12], [], 'Timing of motor output';

    'SMG_BA40_7', [36, -54, 46], [36, -58, 48], 'Articulatory loop, auditory expectations';
    'SMG_BA40_7_2', [-46,-56, 42], [], 'Articulatory loop, auditory expectations';

    'SMG_BA40', [-30, -50, 38], [-30, -50, 40], 'Articulatory loop, auditory expectations';
    'SMG_BA40_2', [], [-36, -44, 38], 'Articulatory loop, auditory expectations';

    'Cerebellum', [18, -64, -16], [2, -70, -10], 'Retrieving words for speech production';
    'Cerebellum_2', [], [-22, -60, -21], 'Retrieving words for speech production';
    'Cerebellum_3', [], [-6, -74, -18], 'Retrieving words for speech production';
    
    'Cuneus_BA17', [], [0, -82, 8], 'Visual processing';
};

% Define the radius for the spheres
radius = 6;  % Radius of the sphere in mm

% Loop over each ROI, create the sphere, and save it as a .nii file
for i = 1:size(rois, 1)
    roi_name = rois{i, 1};
    
    % Process Affective Prosody coordinates (AP) (choose only rois that have
    % coordinates in the second column
    if ~isempty(rois{i, 2})
        coords = rois{i, 2};
        save_name = sprintf('AP_%s.nii', roi_name);
        create_sphere_and_save(coords, radius, save_name);
    end
    
    % Process Lingustic Prosody coordinates (LP) (choose only rois that have
    % coordinates in the third column
    if ~isempty(rois{i, 3})
        coords = rois{i, 3};
        save_name = sprintf('LP_%s.nii', roi_name);
        create_sphere_and_save(coords, radius, save_name);
    end
end

disp('ROI .nii files created successfully.');

% Function to create a sphere and save the .nii file
function create_sphere_and_save(coords, radius, save_name)
    % Load a template image to define the space (use any MNI/standard image)
    V = spm_vol(fullfile(spm('Dir'), 'canonical', 'avg152T1.nii')); 
    [x, y, z] = ndgrid(1:V.dim(1), 1:V.dim(2), 1:V.dim(3));
    x = x * V.mat(1,1) + V.mat(1,4);
    y = y * V.mat(2,2) + V.mat(2,4);
    z = z * V.mat(3,3) + V.mat(3,4);
    
    % Calculate the distance of each voxel from the center of the sphere
    dist = sqrt((x - coords(1)).^2 + (y - coords(2)).^2 + (z - coords(3)).^2);
    
    % Create a binary mask for the sphere
    sphere_mask = dist <= radius;
    
    % Write the sphere mask to a NIfTI file
    V.fname = save_name;
    V.dt = [spm_type('uint8') spm_platform('bigend')];
    V.descrip = 'ROI sphere';
    spm_write_vol(V, sphere_mask);
end
