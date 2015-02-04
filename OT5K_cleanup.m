function OT5K_cleanup
% To get the Optic Tract is able to analyse.

%% exclude fibers depend on anatomical location (waypoint ROI)

% homeDir ='/peach/shumpei/qMRI';
[homeDir, subDir] = fileparts(pwd);


fgDir = fullfile(homeDir,subDir,'/DTI/dti96trilin/fibers/conTrack/OT_5K');
roiDir =fullfile(homeDir,subDir,'/DTI/ROIs');

fgf = {'*Lt-LGN4*.pdb'
    '*Rt-LGN4*.pdb'};
%% contrack scoring
for j = 1:2
    %
    fgF = dir(fullfile(fgDir,fgf{j}));
%     fg = fgRead((fullfile(fgDir,fgF.name)));
    cd(fgDir)
    % conTrack scoring
    nFiber=100;
    % get .txt and .pdb filename
    identifier = fgF.name(end-8:end-4);
    dTxtF = ['*',identifier,'*.txt'];
    dTxt = dir(fullfile(fgDir,dTxtF));
    dPdb = fullfile(fgDir,fgF.name);
    
    % give filename to output f group
    [~,f] = fileparts(fgF.name);
    outputfibername = fullfile(fgDir, sprintf('%s_Ctrk%d.pdb',f,nFiber));
    
    % score the fibers to particular number
    ContCommand = sprintf('contrack_score.glxa64 -i %s -p %s --thresh %d --sort %s', ...
        dTxt(end).name, outputfibername, nFiber, dPdb);
    %         contrack_score.glxa64 -i ctrSampler.txt -p scoredFgOut_top5000.pdb --thresh 5000 --sort fgIn.pdb
    % run contrack
    system(ContCommand);
    
    %% AFQ_removeoutlier    
    % Load contrack scored fiber
    fg  = fgRead(outputfibername);
    maxDist = 3;
    maxLen  = 2;
    
    [fgclean, keep2]=AFQ_removeFiberOutliers(fg,maxDist,maxLen,25,'mean',1, 5,[]);
    % keep pathwayInfo and Params.stat for contrack scoring
    for l = 1:length(fgclean.params)
        fgclean.params{1,l}.stat=fgclean.params{1,l}.stat(keep2);
    end
    fgclean.pathwayInfo = fgclean.pathwayInfo(keep2);
    fgclean.name = sprintf('%s_D%dL%d.pdb',fgclean.name,maxDist,maxLen);
    
    % align fiber direction comes from anrterior to posterior
    fg = SO_AlignFiberDirection(fgclean,'AP');
    fgWrite(fg,[fgclean.name],'pdb')
%     if shapeCheck,
      AFQ_RenderFibers(fg,'numfibers',10);
%     end;    
    
    % give a simple name to this fg
    fgN = {'LOTD3L2','ROTD3L2'};
    % save a cleaned fiber
    fg.name = fgN{j};
    fgWrite(fg,[fg.name,'.pdb'],'pdb')
%     close H
end
cd(fullfile(homeDir, subDir)) 



% %% check generated OT shape
% if show_flag;
%     for i = id
%         % INPUTS
%         SubDir   = fullfile(homeDir,subDir{i});
%         %     fgDir    = (fullfile(SubDir,'/dwi_2nd/fibers/conTrack/OT_5K'));
%         fiberDir = fullfile(SubDir,'/dwi_2nd/fibers');
%         roiDir = fullfile(SubDir,'/dwi_2nd/ROIs');
%         %     cd(fgDir)
%         % load fg and calcurate nFiber
%
%         fgN = {'LOTD4L4_1206*','ROTD4L4_1206*'};
%
%         % Render OT fig
%         figure; hold on;
%         for j= 1:2
%             cd(fiberDir)
%
%             fgF = dir(fgN{j});
%             fg  = fgRead(fgF.name);
%             AFQ_RenderFibers(fg,'numfibers',10,'newfig',0)
%
%         end
%         camlight 'headlight';
%         axis off
%         axis image
%         hold off;
%
%     end
% end
% %% AFQ_removeoutlier
% for i = id
%     % INPUTS
%     SubDir=fullfile(homeDir,subDir{i});
%     fgDir = (fullfile(SubDir,'/dwi_2nd/fibers/conTrack/OT_5K'));
%     roiDir = fullfile(SubDir,'/dwi_2nd/ROIs');
%     cd(fgDir)
%     % load fg and calcurate nFiber
%     fgf = {...
%         '*fg_OT_5K_Optic-Chiasm_Lt-LGN4*Right-Cerebral-White-Matter_Ctrk100.pdb'
%         '*fg_OT_5K_Optic-Chiasm_Rt-LGN4*Left-Cerebral-White-Matter_Ctrk100.pdb'};
%     for j= 1:2
%         fgF = dir(fgf{j});
%         fg  = fgRead(fgF.name);
%
%         [fgclean, keep2]=AFQ_removeFiberOutliers(fg,3,2,25,'mean',1, 5,[]);
%         % keep pathwayInfo and Params.stat for contrack scoring
%         for l = 1:length(fgclean.params)
%             fgclean.params{1,l}.stat=fgclean.params{1,l}.stat(keep2);
%         end
%         fgclean.pathwayInfo = fgclean.pathwayInfo(keep2);
%         fgclean.name = sprintf('%s_AFQD3L2_%d.pdb',fgclean.name,length(fgclean.fibers));
%         mtrExportFibers(fgclean, fgclean.name,[],[],[],2)
%     end
% end
%
% %% SO_AlignFiberDirection
% for i = id
%     % INPUTS
%     SubDir   = fullfile(homeDir,subDir{i});
%     fgDir    = (fullfile(SubDir,'/dwi_2nd/fibers/conTrack/OT_5K'));
%     fiberDir = fullfile(SubDir,'/dwi_2nd/fibers');
%     roiDir = fullfile(SubDir,'/dwi_2nd/ROIs');
%     cd(fgDir)
%     % load fg and calcurate nFiber
%     fgf = {...
%         '*Lt-LGN4*Right-Cerebral-White-Matter_Ctrk100_AFQD3L2*'
%         '*Rt-LGN4*Left-Cerebral-White-Matter_Ctrk100_AFQD3L2*'};
%     fgN = {'LOTD3L2_1206','ROTD3L2_1206'};
%
%     for j= 1:2
%         cd(fgDir)
%
%         fgF = dir(fgf{j});
%         fg  = fgRead(fgF.name);
%         fg = SO_AlignFiberDirection(fg,'AP');
%         % AFQ_RenderFibers(fg,'numfibers',10)
%
%         cd(fiberDir)
%         fg.name = fgN{j};
%         fgWrite(fg,[fg.name '.pdb'],'pdb')
%     end
% end
% %% check generated OT shape
% if show_flag == true;
%     for i = id
%         % INPUTS
%         SubDir   = fullfile(homeDir,subDir{i});
%         %     fgDir    = (fullfile(SubDir,'/dwi_2nd/fibers/conTrack/OT_5K'));
%         fiberDir = fullfile(SubDir,'/dwi_2nd/fibers');
%         roiDir = fullfile(SubDir,'/dwi_2nd/ROIs');
%         %     cd(fgDir)
%         % load fg and calcurate nFiber
%
%         fgN = {'LOTD3L2_1206*','ROTD3L2_1206*'};
%
%         % Render OT fig
%         figure; hold on;
%         for j= 1:2
%             cd(fiberDir)
%
%             fgF = dir(fgN{j});
%             fg  = fgRead(fgF.name);
%             AFQ_RenderFibers(fg,'numfibers',10,'newfig',0)
%
%         end
%         camlight 'headlight';
%         axis off
%         axis image
%         hold off;
%
%     end
% end
