%% ROI extraction

addpath('C:/Users/jschraeder/Desktop/emocon/Scripts');                  
DataPath = 'C:/Users/jschraeder/Desktop/emocon/FirstLevel/VideMask';              
subjects = dir(fullfile(DataPath, 's*'));    

for i = 1:length(subjects)
   get_ROIs(subjects(i).name)
end
