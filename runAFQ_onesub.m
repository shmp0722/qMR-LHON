function afq = runAFQ_onesub(BrainMap)
%
% This script gives you WholeBrainFG using mrtricks and Ants.
%
% Requirement
% move to subject directory

%% set params

[p,f,e] = fileparts(pwd);

sub_dirs{1} = fullfile(p,f,'/DTI/dti96trilin');
afq = AFQ_Create('sub_dirs',sub_dirs,'sub_group',1,'clip2rois', 0,'normalization','ants');
% afq = AFQ_Create('sub_dirs',sub_dirs,'sub_group',1,'clip2rois', 0);%,'normalization','ants');

% Set to overwrite previous fibers
afq = AFQ_set(afq,'outdir',fullfile(p,f,'AFQ'));
% afq = AFQ_set(afq','outname',sprintf('afq_%s',f));

afq.params.track.algorithm = 'mrtrix';


%% add images

if BrainMap,
    BrainMapPath = fullfile(sub_dirs,'../../OutPutFiles_1/BrainMaps');
    T1Path  = fullfile(BrainMapPath, 'T1_map_lsq.nii.gz');
    TVPath  = fullfile(BrainMapPath, 'TV_map.nii.gz');
    VIPPath = fullfile(BrainMapPath, 'VIP_map.nii.gz');
    WFPath  = fullfile(BrainMapPath, 'WF_map.nii.gz');
    
    % set images
    afq = AFQ_set(afq, 'images', T1Path);
    afq = AFQ_set(afq, 'images', TVPath);
    afq = AFQ_set(afq, 'images', VIPPath);
    afq = AFQ_set(afq, 'images', WFPath);
end
%% run afq

afq = AFQ_run(sub_dirs,1,afq);

%% Add OT and OR

FG = {'LOTD3L2.pdb','ROTD3L2.pdb','LOR1206_D4L4.pdb','ROR1206_D4L4.pdb'};

% afq = AFQ_AddNewFiberGroup(afq, fgName, roi1Name, roi2Name, [cleanFibers = true], ...
%          [computeVals = true], [showFibers = false], [segFgName = 'WholeBrainFG.mat'] ...
%          [overwrite = false])

% L-optic tract
fgName =  FG{1};
roi1Name = '85_Optic-Chiasm.mat';
roi2Name = 'Lt-LGN4.mat';

afq = SO_AFQ_AddNewFiberGroup(afq, fgName, roi1Name, roi2Name, 0, 1,0,[],0);

% R-optic tract
fgName =  FG{2};
roi1Name = '85_Optic-Chiasm.mat';
roi2Name = 'Rt-LGN4.mat';

afq = SO_AFQ_AddNewFiberGroup(afq, fgName, roi1Name, roi2Name, 0, 1,0,[],0);

% L-optic radiation
fgName =  FG{3};
roi1Name = 'Lt-LGN4.mat';
roi2Name = 'lh_V1_smooth3mm_NOT.mat';

afq = SO_AFQ_AddNewFiberGroup(afq, fgName, roi1Name, roi2Name, 0, 1,0,[],0);

% L-optic radiation
fgName =  FG{3};
roi1Name = 'Rt-LGN4.mat';
roi2Name = 'rh_V1_smooth3mm_NOT.mat';

afq = SO_AFQ_AddNewFiberGroup(afq, fgName, roi1Name, roi2Name, 0, 1,0,[],0);






