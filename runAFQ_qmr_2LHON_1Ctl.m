function runAFQ_qmr_2LHON_1Ctl
%
% Run AFQ on LHON1, 2 and Ctl8214
%
%

%% set subjects
baseDir = '/peach/shumpei/qMRI';
subs    = {'LHON1-CV-76M-20141205_8504_nims','LHON2-RC-62M-20140128_8763',...
    'Ctl8214-RL'};

%% Make directory structure for each subject
for ii = 1:length(subs)
    sub_dirs{ii} = fullfile(baseDir, subs{ii},'/DTI/dti96trilin');
end

sub_group = [1 1 0];

% Now create and afq structure
afq = AFQ_Create('sub_dirs', sub_dirs, 'sub_group', sub_group, 'clip2rois', 0);
afq.params.track.algorithm = 'mrtrix';
afq.params.outdir  = '/peach/shumpei/qMRI/AFQ_dwi96ls';
afq.params.outname = 'afq_2LHON_1Ctl_02112015.mat';

%% set image files
% SIR
for ii = 1:length(sub_dirs),
    t1Path{ii} = fullfile(baseDir,subs{ii}, '/OutPutFiles_1/BrainMaps/SIR_map.nii.gz');
end
afq = AFQ_set(afq, 'images', t1Path);

% T1_map_lsq.nii.gz
for ii = 1:length(sub_dirs),
    t1Path{ii} = fullfile(baseDir,subs{ii}, '/OutPutFiles_1/BrainMaps/T1_map_lsq.nii.gz');
end
afq = AFQ_set(afq, 'images', t1Path);

% TV.nii.gz
for ii = 1:length(sub_dirs),
    t1Path{ii} = fullfile(baseDir,subs{ii}, '/OutPutFiles_1/BrainMaps/TV_map.nii.gz');
end
afq = AFQ_set(afq, 'images', t1Path);

% VIP_map.nii.gz
for ii = 1:length(sub_dirs),
    t1Path{ii} = fullfile(baseDir,subs{ii}, '/OutPutFiles_1/BrainMaps/VIP_map.nii.gz');
end
afq = AFQ_set(afq, 'images', t1Path);

% WF_map.nii.gz
for ii = 1:length(sub_dirs),
    t1Path{ii} = fullfile(baseDir,subs{ii}, '/OutPutFiles_1/BrainMaps/WF_map.nii.gz');
end
afq = AFQ_set(afq, 'images', t1Path);

%% Run AFQ on these subjects
afq = AFQ_run(sub_dirs, sub_group, afq);

%%





