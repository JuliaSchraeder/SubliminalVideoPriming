%Define Contrasts for VideoMask Paradigm%
%Happy and sad Videos were presented. A primer with a happy or sad face was
%presented unconsciously for 16ms during the video%

clear all;

DataPath = fullfile('/bif/storage/storage1/projects/emocon/FirstLevel/VideoMask');
Subjects = dir(fullfile(DataPath, 's*'));
 
%Subjects = Subjects([1:2]);

spm_jobman('initcfg');
spm('defaults', 'FMRI');
global defaults;

%pmod happy happy : 005
%pmod happy sad   : 005, 011
%pmod sad happy   : 005 
%pmod sad sad     : 005, 007

% pmods ans Ende schreiben für Kontraste die p mod haben (mkconfile)

 for i = 9:numel(Subjects)
     PatPath = fullfile(DataPath, Subjects(i).name);
     
      %Define contrasts
      matlabbatch{1}.spm.stats.con.spmmat = {fullfile(PatPath, 'SPM.mat')};
      % t constrasts
% happy happy, happy sad, sad happy, sad sad, primer %
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'happy_happy';          % primer happy, video happy
matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = [1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'happy_sad';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [0 0 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'sad_happy'; 
matlabbatch{1}.spm.stats.con.consess{3}.tcon.convec = [0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'sad_sad'; 
matlabbatch{1}.spm.stats.con.consess{4}.tcon.convec = [0 0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';


%% 
matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'congruent';            %congruent trials
matlabbatch{1}.spm.stats.con.consess{5}.tcon.convec = [1 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'incongruent';         %incongruent trials
matlabbatch{1}.spm.stats.con.consess{6}.tcon.convec = [0 0 1 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'cong>incon';          %congruent minus incongruent
matlabbatch{1}.spm.stats.con.consess{7}.tcon.convec = [1 0 -1 0 1 0 -1];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
% .... %
matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'incon>cong';           %incongruent minus congtuent
matlabbatch{1}.spm.stats.con.consess{8}.tcon.convec = [-1 0 1 0 -1 0 1];
matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';


matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'happy';               %happy videos 
matlabbatch{1}.spm.stats.con.consess{9}.tcon.convec = [1 0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'sad';                 %sad videos 
matlabbatch{1}.spm.stats.con.consess{10}.tcon.convec = [0 0 1 0 1];
matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'happy>sad'; 
matlabbatch{1}.spm.stats.con.consess{11}.tcon.convec = [1 0 -1 0 -1 0 1];
matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'sad>happy'; 
matlabbatch{1}.spm.stats.con.consess{12}.tcon.convec = [-1 0 1 0 1 0 -1];
matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';


matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'sad>happy_con';       %sad videos minus happy videos durin congruent trials
matlabbatch{1}.spm.stats.con.consess{13}.tcon.convec = [-1 0 0 0 1];        %happy happy = -1, sad sad = 1
matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{14}.tcon.name = 'sad>happy_incon';     %sad videos minus happy videos durin incongruent trials
matlabbatch{1}.spm.stats.con.consess{14}.tcon.convec = [0 0 1 0 0 0 -1];    %happy sad = 1, sad happy = -1
matlabbatch{1}.spm.stats.con.consess{14}.tcon.sessrep = 'none';


matlabbatch{1}.spm.stats.con.consess{15}.tcon.name = 'happy>sad_con';       %happy videos minus sad videos durin congruent trials
matlabbatch{1}.spm.stats.con.consess{15}.tcon.convec = [1 0 0 0 -1];        %happy happy = 1, sad sad = -1
matlabbatch{1}.spm.stats.con.consess{15}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{16}.tcon.name = 'happy>sad_incon';     %happy videos minus sad videos durin incongruent trials
matlabbatch{1}.spm.stats.con.consess{16}.tcon.convec = [0 0 -1 0 0 0 1];    %happy sad = -1, sad happy = 1
matlabbatch{1}.spm.stats.con.consess{16}.tcon.sessrep = 'none';



matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'happy_happy_pmod';     %rating as modulator for trials with happy video, happy primer
matlabbatch{1}.spm.stats.con.consess{17}.tcon.convec = [0 1];
matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{18}.tcon.name = 'happy_sad_pmod';
matlabbatch{1}.spm.stats.con.consess{18}.tcon.convec = [0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{18}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{19}.tcon.name = 'sad_happy_pmod'; 
matlabbatch{1}.spm.stats.con.consess{19}.tcon.convec = [0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{19}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{20}.tcon.name = 'sad_sad_pmod'; % sub 7 fehler
matlabbatch{1}.spm.stats.con.consess{20}.tcon.convec = [0 0 0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{20}.tcon.sessrep = 'none';





%1. nicht da
% matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'happy_sad_pmod';
% matlabbatch{1}.spm.stats.con.consess{17}.tcon.convec = [0 0 0 1];
% matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
% 
% matlabbatch{1}.spm.stats.con.consess{18}.tcon.name = 'sad_happy_pmod'; 
% matlabbatch{1}.spm.stats.con.consess{18}.tcon.convec = [0 0 0 0 0 1];
% matlabbatch{1}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
% 
% matlabbatch{1}.spm.stats.con.consess{19}.tcon.name = 'sad_sad_pmod'; % sub 7 fehler
% matlabbatch{1}.spm.stats.con.consess{19}.tcon.convec = [0 0 0 0 0 0 0 1];
% matlabbatch{1}.spm.stats.con.consess{19}.tcon.sessrep = 'none';



% %2. nicht da
% 
% matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'happy_happy_pmod';     %rating as modulator for trials with happy video, happy primer
% matlabbatch{1}.spm.stats.con.consess{17}.tcon.convec = [0 1];
% matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
% 
% matlabbatch{1}.spm.stats.con.consess{18}.tcon.name = 'sad_happy_pmod'; 
% matlabbatch{1}.spm.stats.con.consess{18}.tcon.convec = [0 0 0 0 0 1];
% matlabbatch{1}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
% 
% matlabbatch{1}.spm.stats.con.consess{19}.tcon.name = 'sad_sad_pmod'; % sub 7 fehler
% matlabbatch{1}.spm.stats.con.consess{19}.tcon.convec = [0 0 0 0 0 0 0 1];
% matlabbatch{1}.spm.stats.con.consess{19}.tcon.sessrep = 'none';


matlabbatch{1}.spm.stats.con.delete = 1; %auf 0 wenn man nur einen Kontrast hinzufügen will und alte behalten will

spm_jobman('run', matlabbatch);
clear matlabbatch;

end
