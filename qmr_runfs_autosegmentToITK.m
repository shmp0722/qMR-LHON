function qmr_runfs_autosegmentToITK

%%
% change directory to a subject you want to make segmantation file using freesurfer

%% Set directory
[~,subDir] = fileparts(pwd);
% subDir  = 'Ctl8214-RL';
% fsDir   =  getenv('SUBJECTS_DIR');
t1 = fullfile(pwd,'/OutPutFiles_1/T1w/T1wfs_4.nii.gz');

%% autosegmentation with freesurfer
fs_autosegmentToITK(subDir, t1)