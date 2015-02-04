function afq = runAFQ_onesub
%
% This script gives you WholeBrainFG using mrtricks and Ants.
%
% Requirement
% move to subject directory

%% set params

[p,f,e] = fileparts(pwd);

sub_dirs{1} = fullfile(p,f,'/DTI/dti96trilin');
afq = AFQ_Create('sub_dirs',sub_dirs,'sub_group',1,'clip2rois', 0,'normalization','ants');
% Set to overwrite previous fibers
afq=AFQ_set(afq,'outdir',fullfile(p,f,'AFQ'),'outname',sprintf('afq_%s',f));

afq.params.track.algorithm = 'mrtrix';
%% run afq
afq = AFQ_run(sub_dirs,1,afq);
%%
% save AFQ_LHON1CV_mrtrix afq