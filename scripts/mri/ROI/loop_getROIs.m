%% ROI extraction
clear
addpath('/bif/storage/storage1/projects/emocon/Scripts');                  
DataPath = '/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask';              
subjects = dir(fullfile(DataPath, 's*'));    

for i = 1:length(subjects)
   get_ROIs(subjects(i).name)
end
