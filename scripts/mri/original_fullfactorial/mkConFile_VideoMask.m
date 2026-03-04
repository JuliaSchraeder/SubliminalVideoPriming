
function [names, onsets, durations, pmod] = mkConFile_VideoMask(subName)
root = '/bif/storage/storage1/projects/emocon/Data/';
projectfolder = '/bif/storage/storage1/projects/emocon';
logDir = fullfile(root,'Behav_data','Logfiles_Video');                      %Input directory

subjects = dir(fullfile(logDir, '*.csv')); %finde  csv file
subs = length(subjects);                                                    %get number of subjects
csv_names = {subjects(1:subs).name};                                        %extract csv file names
csv_names = csv_names';                                                     %convert 1x3 to 3x1

subNumber = extractAfter(subName, 3);                                       %get number of subjects extract it after the 3. value
Index = find(contains(csv_names,subNumber)) ;                                %find row number of subName in "csv_names"

 
logName = csv_names(Index);                                                 %get specific name of csv file for subName
logName = char(logName);                                                    %convert cell to string

%%Output Directory festlegen 
if ~exist(fullfile(projectfolder, 'ConFileFolder',subName))
    mkdir(fullfile(projectfolder, 'ConFileFolder',subName));
end
outputFolder = fullfile(projectfolder,'ConFileFolder',subName);             %Output directory

%% *** Dateneinlesen und codieren *** %%

% fileName = fullfile(logDir,logName); 
% fileID = fopen(fileName,'r','n','UTF-8');
% %read in all cells as strings %71 rows for sub<sub-015
% %formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s';
% %read in all cells as strings %72 rows for sub>sub-015
% formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s';
% 
% % if subName == 'sub-016' %16 open with tab
% %     seperator = '\t';
% % else seperator = ';';
% % end
% 
% fseek(fileID, 3, 'bof');                                                    %open the file
% data = textscan(fileID, formatSpec, 'Delimiter', ';', 'TextType', 'string', 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine','\r\n');
% fclose(fileID);
%'whitespace',
%change NaNs to 99
%data = data(isnan(data))== 99;

%Get FrameRate
%FrameRate_row = double(data{1,71});
%FrameRate = FrameRate_row(1,:);

data = readtable((fullfile(logDir,logName)));

%% For Sub 17
%Transform strings to numbers
MR_Onset_row = data.MR_trigger_time;
MR_Onset = MR_Onset_row(~isnan(MR_Onset_row));                              %get the tim of the MR Onset by deleting all other NaNs
ISI_row = data.polygon_ISI_started;
ISI_start = ISI_row(3,1);                                                   %End of Introduction!
Primer_Onset_row = data.primerImage_started;                                %get row of primer onsets
Video_Onset_row = data.polygon_stopped;                                     %get row of video onsets
end_Video_row = data.response_started;                                      %get end time of video
Slider_Rating = data.Rating;                                                %get End Rating of Slider response from column 46

%Get Stimulus Condition string
strPrimer_Emotion = data.primeEmotion;                                      %get string if primer Face happy or sad?
strTarget_Emotion = data.targetEmotion;                                     %get information (string) of Video happy or sad?

%Transform Stimulus Condition from string to number
%Primer_Emotion = strrep(strPrimer_Emotion, 'neutral', '1'); %rename string to number
Primer_Emotion = strrep(strPrimer_Emotion, 'sad', '2');                     %sad = 2
Primer_Emotion = strrep(Primer_Emotion, 'happy', '3');                      %happy = 3
Primer_Emotion = str2double(Primer_Emotion);                                %transform this renamed string now to double

%Target_Emotion = strrep(strTarget_Emotion, 'neutral', '1'); %rename string to number
Target_Emotion = strrep(strTarget_Emotion, 'sad', '2');                     %sad = 2
Target_Emotion = strrep(Target_Emotion, 'happy', '3');                      %happy = 3
Target_Emotion = str2double(Target_Emotion);                                %transform this string to double


%Delete first two example rows and NaN in last row:
Primer_Onset_row([1,2,63],:) = []; 
Video_Onset_row([1,2,63],:) = [];

Primer_Emotion([1,2,63],:) = [];
Target_Emotion([1,2,63],:) = [];
end_Video_row([1,2,63],:) = [];

Slider_Rating([1,2,63],:) = [];

%Substract Onsets with MR Onset
Video_Onset_row = Video_Onset_row - MR_Onset;
Primer_Onset_row = Primer_Onset_row - MR_Onset;
end_Video_row = end_Video_row - MR_Onset;

%Get Onsets
onsets_happy_happy = Video_Onset_row(Primer_Emotion == 3 & Target_Emotion == 3);
onsets_happy_sad = Video_Onset_row(Primer_Emotion == 3 & Target_Emotion == 2);
onsets_sad_sad = Video_Onset_row(Primer_Emotion == 2 & Target_Emotion == 2);
onsets_sad_happy = Video_Onset_row(Primer_Emotion == 2 & Target_Emotion == 3);
onsets_primer = Primer_Onset_row;
onsets_intro = 0;

%Get Duration
duration_Video = end_Video_row - Video_Onset_row;
duration_happy_happy = duration_Video(Primer_Emotion == 3 & Target_Emotion == 3);
duration_happy_sad = duration_Video(Primer_Emotion == 3 & Target_Emotion == 2);
duration_sad_sad = duration_Video(Primer_Emotion == 2 & Target_Emotion == 2);
duration_sad_happy = duration_Video(Primer_Emotion == 2 & Target_Emotion == 3);
duration_primer = {};
duration_intro = ISI_start - MR_Onset;

%Primer is always 0.016
for i= 1:length(onsets_primer)
    duration_primer{i,1} = 0.016;
end
duration_primer = cell2mat(duration_primer);

%Get Ratings for different conditions
rating_happy_happy = Slider_Rating(Primer_Emotion == 3 & Target_Emotion == 3);
rating_happy_sad = Slider_Rating(Primer_Emotion == 3 & Target_Emotion == 2);
rating_sad_sad = Slider_Rating(Primer_Emotion == 2 & Target_Emotion == 2);
rating_sad_happy = Slider_Rating(Primer_Emotion == 2 & Target_Emotion == 3);

%% Create cells for Conditionsfile

names{1} = 'happy_happy';                                                   % primer = happy, target = happy
names{2} = 'happy_sad';
names{3} = 'sad_sad';
names{4} = 'sad_happy';
names{5} = 'primer';
names{6} = 'intro';

onsets{1} = onsets_happy_happy;  % primer = happy, target = happy
onsets{2} = onsets_happy_sad;
onsets{3} = onsets_sad_sad;
onsets{4} = onsets_sad_happy;
onsets{5} = onsets_primer;
onsets{6} = onsets_intro;

durations{1} = duration_happy_happy;  % primer = happy, target = happy
durations{2} = duration_happy_sad;
durations{3} = duration_sad_sad;
durations{4} = duration_sad_happy;
durations{5} = duration_primer;
durations{6} = duration_intro;

%pmod(1) = Modulation für 1. Kontrast
%name {1} = 1. Modulation für diesen Kontrast
pmod(1).name{1}     = onsets_happy_happy; 
pmod(1).param{1}    = rating_happy_happy;                                   %rating aller videos mit happy video, happy primer
pmod(1).poly{1}     =  1;

pmod(2).name{1}     = onsets_happy_sad; 
pmod(2).param{1}    = rating_happy_sad;                                     %rating aller videos mit happy video, sad primer
pmod(2).poly{1}     =  1;



pmod(3).name{1}     = onsets_sad_sad; 
pmod(3).param{1}    = rating_sad_sad;                                       %rating aller videos mit sad video, sad primer
pmod(3).poly{1}     =  1;

pmod(4).name{1}     = onsets_sad_happy; 
pmod(4).param{1}    = rating_sad_happy;                                     %rating aller videos mit sad video, sad primer
pmod(4).poly{1}     =  1;


save(fullfile(outputFolder,'ConFile_VideoMask'), 'names', 'onsets','durations','pmod');
end

