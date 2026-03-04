%-----------------------------------------------------------------------
% Job saved on 06-Jun-2019 15:39:38 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%% Skript for a fullfactorial design in Backward Mask Paradigm
% to analyse difference between emotion, congruence, and group difference. Emotion, congruence, and group as levels 
% Patients are : sub-007,008,009,012,013,020,026,035,036
 

% Haupteffekte : gruppenvergleich, alle congruenten gegen alle incongruenten, alle
% conscious vs unconscious (alle in beide Richtungen)

% alle mit target z.b. happy HC gegen happy depressiv


%% Find FirstLevel Contrasts
clear all                                                                                               %clear Workspace

HC_Path = fullfile('/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/Groups/HC');          %path do FirstLevel Data from Healthy Controls
HC_Subjects = dir(fullfile(HC_Path, 's*'));                                                             %get HC subjects
HC_Subjects = HC_Subjects([1:length(HC_Subjects)]);                                             

Pat_Path = fullfile('/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/Groups/Patient');    %path to FirstLevel Data from Patients
Pat_Subjects = dir(fullfile(Pat_Path, 's*'));                                                           %get Patient subjects
Pat_Subjects = Pat_Subjects([1:length(Pat_Subjects)]);


%% Get HC Contrasts
% Generate variables with paths to find the contrast files
for i = 1:numel(HC_Subjects)                                                    %for every subject in the HC directory
    subName = HC_Subjects(i).name;                                              %take the name as SubName
    
    HC_h_h{i,:} = fullfile(Pat_Path, subName,'con_0001.nii,1');
    HC_h_s{i,:} = fullfile(Pat_Path, subName,'con_0002.nii,1');
    HC_s_h{i,:} = fullfile(Pat_Path, subName,'con_0003.nii,1');
    HC_s_s{i,:} = fullfile(Pat_Path, subName,'con_0004.nii,1');
end

%% Get Patient Contrasts
for i = 1:numel(Pat_Subjects)
    subName = Pat_Subjects(i).name;
    
    Pat_h_h{i,:} = fullfile(Pat_Path, subName,'con_0001.nii,1');
    Pat_h_s{i,:} = fullfile(Pat_Path, subName,'con_0002.nii,1');
    Pat_s_h{i,:} = fullfile(Pat_Path, subName,'con_0003.nii,1');
    Pat_s_s{i,:} = fullfile(Pat_Path, subName,'con_0004.nii,1');
    
end


%% Define Design
matlabbatch{1}.spm.stats.factorial_design.dir = {'/bif/storage/storage1/projects/emocon/SecondLevel/FullFact/Video/2emo2congr2group'};
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'emotion';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2; %sad = 2, happy = 3
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;                                          
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0; %varianzengleichheit ja = 1 nein = 0
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'congruence';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2; % congruent = 1, incongruent = 2
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;


matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).name = 'group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).levels = 2; %HC = 1, patient = 2
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).ancova = 0;




%% HC %%
%% Congruent
%happy happy 
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                    1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = HC_h_h;

%sad sad 
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [2
                                                                    1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = HC_s_s;

%% Incongruent
%happy sad
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
                                                                    2
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = HC_h_s;

%sad happy
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [1
                                                                    2
                                                                    1];                                                              
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = HC_s_h;


%% Patient %%

%% Congruent
%happy happy 
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [1
                                                                    1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = Pat_h_h;

%sad sad 
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [2
                                                                    1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = Pat_s_s;

%% Incongruent
%happy sad
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [2
                                                                    2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = Pat_h_s;

%sad happy
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [1
                                                                    2
                                                                    2];                                                              
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = Pat_s_h;


%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%Estimate created Batch
matlabbatch{2}.spm.stats.fmri_est.spmmat = {'/bif/storage/storage1/projects/emocon/SecondLevel/FullFact/Video/2emo2congr2group/SPM.mat'};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


% Run created Batch
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

%File "/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask/Groups/Patient/sub-004/con_0001.nii" does not exist.

