function qmr_SO_ORPipeline
% this pipeline make raw optic fibers clean.
% Exclude fibers
% 1) by anotomical location (waypoint roi)
% 2) distance from fiber core (AFQ_removefiberoutliers)
%
% Input
% id  = subject number of tamagawa sbuject list. See Tama_subj
% If you need to create waypoint ROI
% ROI = 1 or true.   See also SO_GetROIs
%
% See also runSO_DivideFibersAcordingToFiberLength_percentile_Tama2


%% Set directory
% [P,N,E] = fileparts(pwd);

% homeDir = '/peach/shumpei/qMRI';
% subDir  = 'LHON1-CV-76M-20141205_8504';

 [homeDir,subDir] = fileparts(pwd);

%% make waypoit ROI and directory its directory
% if ROI,
% make NOT ROI
RoiDir = fullfile(homeDir,subDir,'/DTI/ROIs');
% ROI file names you want to merge
for hemisphere = 1:2
    switch(hemisphere)
        case  1 % Left-WhiteMatter
            roiname = {...'Brain-Stem',...
                '*_Right-Cerebellum-White-Matter.mat'
                '*_Right-Cerebellum-Cortex.mat'
                '*_Left-Cerebellum-White-Matter.mat'
                '*_Left-Cerebellum-Cortex.mat'
                '*_Left-Hippocampus.mat'
                '*_Right-Hippocampus.mat'
                '*_Left-Lateral-Ventricle.mat'
                '*_Right-Lateral-Ventricle.mat'
                '*_Left-Cerebral-White-Matter.mat'};
            
        case 2 % Right-WhiteMatter
            roiname = {...'Brain-Stem',...
                '*_Right-Cerebellum-White-Matter.mat'
                '*_Right-Cerebellum-Cortex.mat'
                '*_Left-Cerebellum-White-Matter.mat'
                '*_Left-Cerebellum-Cortex.mat'
                '*_Left-Hippocampus.mat'
                '*_Right-Hippocampus.mat'
                '*_Left-Lateral-Ventricle.mat'
                '*_Right-Lateral-Ventricle.mat'
                '*_Right-Cerebral-White-Matter.mat'};
    end
    
    % load ROIs to merge
    for j = 1:length(roiname)
        cur_roi = dir(fullfile(RoiDir,roiname{j}));
        roi{j} = dtiReadRoi(fullfile(RoiDir,cur_roi.name));
        
        % make sure ROI
        if 1 == isempty(roi{j}.coords)
            disp(roi{j}.name)
            disp('number of corrds = 0')
            %                     return
        end
    end
    
    % Merge ROI one by one
    newROI = roi{1,1};
    for kk=2:length(roiname)
        newROI = dtiMergeROIs(newROI,roi{1,kk});
    end
    % naming
    switch(hemisphere)
        case 1 % Left-WhiteMatter
            newROI.name = 'Lh_NOT1201';
        case 2 % Right-WhiteMatter
            newROI.name = 'Rh_NOT1201';
    end
    % Save Roi
    dtiWriteRoi(newROI,fullfile(RoiDir,newROI.name),1)
    clear roi newROI
end

% end
%% clean naughty fibers up
fgDir  = fullfile(homeDir,subDir,'/DTI/dti96trilin/fibers/conTrack/OR_100K');

for hemisphere = 1:2
    
    fgF = {'Rt-LGN4*.pdb','*Lt-LGN4*.pdb'};
    
    % load fg and ROI
    fg  = dir(fullfile(fgDir,fgF{hemisphere}));
    [~,ik] = sort(cat(2,fg.datenum),2,'ascend');
    fg = fg(ik);
    fg  = fgRead(fullfile(fgDir,fg(1).name));
    
    % Load waypoint roi
    ROIname = {'Lh_NOT1201.mat','Rh_NOT1201.mat'};
    ROIf = fullfile(RoiDir, ROIname{hemisphere});
    ROI = dtiReadRoi(ROIf);
    
    % dtiIntersectFibers
    [fgOut1,~, keep1, ~] = dtiIntersectFibersWithRoi([], 'not', [], ROI, fg);
    keep = ~keep1;
    for l =1:length(fgOut1.params)
        fgOut1.params{1,l}.stat=fgOut1.params{1,l}.stat(keep);
    end
    fgOut1.pathwayInfo = fgOut1.pathwayInfo(keep);
    
    % save new fg.pdb file    
    savefilename = sprintf('%s.pdb',fgOut1.name);
    mtrExportFibers(fgOut1,fullfile(fgDir,savefilename),[],[],[],2);    
    
    % remove outlier based on distance from fiber core
    maxDist = 4;
    maxLen = 4;
    numNodes = 25;
    M = 'mean';
    count = 1;
    show = 1;
    
    [fgclean ,keep] =  AFQ_removeFiberOutliers(fgOut1,maxDist,maxLen,numNodes,M,count,show);
    
    for l =1:length(fgclean.params)
        fgclean.params{1,l}.stat=fgclean.params{1,l}.stat(keep);
    end
    fgclean.pathwayInfo = fgclean.pathwayInfo(keep);
    
    % Align fiber direction from Anterior to posterior
    fgclean = SO_AlignFiberDirection(fgclean,'AP');
    
    % save new fg.pdb file
    fibername       = sprintf('%s_D%dL%d.pdb',fgclean.name,maxDist,maxLen);
    mtrExportFibers(fgclean,fullfile(fgDir,fibername),[],[],[],2);
    switch hemisphere
        case {1}
            fibername = 'ROR1206_D4L4';
        case {2}
            fibername = 'LOR1206_D4L4';
    end
    mtrExportFibers(fgclean,fullfile(fgDir,fibername),[],[],[],2);

end
% return
%% clean naughty fibers up D3L2
% fgDir  = fullfile(homeDir,subDir,'/DTI/dti96trilin/fibers/conTrack/OR_100K');
RoiDir = fullfile(homeDir,subDir,'/DTI/ROIs');
fgDir  = fullfile(homeDir,subDir,'/DTI/dti96trilin/fibers/conTrack/OR_100K');

for hemisphere = 1:2
    
    fgF = {'Rt-LGN4*.pdb','*Lt-LGN4*.pdb'};
    
    % load fg and ROI
    fg  = dir(fullfile(fgDir,fgF{hemisphere}));
    [~,ik] = sort(cat(2,fg.datenum),2,'ascend');
    fg = fg(ik);
    fg  = fgRead(fullfile(fgDir,fg(1).name));
    
    % Load waypoint roi
    ROIname = {'Lh_NOT1201.mat','Rh_NOT1201.mat'};
    ROIf = fullfile(RoiDir, ROIname{hemisphere});
    ROI = dtiReadRoi(ROIf);
    
    % dtiIntersectFibers
    [fgOut1,~, keep1, ~] = dtiIntersectFibersWithRoi([], 'not', [], ROI, fg);
    keep = ~keep1;
    for l =1:length(fgOut1.params)
        fgOut1.params{1,l}.stat=fgOut1.params{1,l}.stat(keep);
    end
    fgOut1.pathwayInfo = fgOut1.pathwayInfo(keep);
    
    % save new fg.pdb file    
    savefilename = sprintf('%s.pdb',fgOut1.name);
    mtrExportFibers(fgOut1,fullfile(fgDir,savefilename),[],[],[],2);    
    
    % remove outlier based on distance from fiber core
    maxDist =3;
    maxLen =2;
    numNodes = 25;
    M = 'mean';
    count = 1;
    show = 1;
    
    [fgclean ,keep] =  AFQ_removeFiberOutliers(fgOut1,maxDist,maxLen,numNodes,M,count,show);
    
    for l =1:length(fgclean.params)
        fgclean.params{1,l}.stat=fgclean.params{1,l}.stat(keep);
    end
    fgclean.pathwayInfo = fgclean.pathwayInfo(keep);
    
    % Align fiber direction from Anterior to posterior
    fgclean = SO_AlignFiberDirection(fgclean,'AP');
    
    % save new fg.pdb file
    fibername       = sprintf('%s_D%dL%d.pdb',fgclean.name,maxDist,maxLen);
    mtrExportFibers(fgclean,fullfile(fgDir,fibername),[],[],[],2);
%     switch hemisphere
%         case {1}
%             fibername = 'ROR1206_D4L4';
%         case {2}
%             fibername = 'LOR1206_D4L4';
%     end
%     mtrExportFibers(fgclean,fullfile(fgDir,fibername),[],[],[],2);

end
return

%% check fg look
    SubDir = fullfile(homeDir,subDir);
%     fgDir  = fullfile(SubDir,'/DTI/dti96trilin/fibers/conTrack/OR_100K');

    % get .pdb filename
    ORf1 = dir(fullfile(fgDir,'*Lt-LGN*_D4L4.pdb*'));
    ORf2 = dir(fullfile(fgDir,'*Rt-LGN*_D4L4.pdb*'));
    
    figure; hold on;    
    % load fg 
        fg1 = fgRead(fullfile(fgDir,ORf1.name));
        fg2 = fgRead(fullfile(fgDir,ORf2.name));
        % render fibers
        AFQ_RenderFibers(fg1,'numfibers',50,'newfig',0);
        AFQ_RenderFibers(fg2,'numfibers',50,'newfig',0);
    
        hold off;
    camlight 'headlight'



%% Copy generated fg to fiberDirectory for AFQ analysis

for i =id
    SubDir = fullfile(homeDir,subDir{i});
    fgDir  = fullfile(SubDir,'/dwi_2nd/fibers/conTrack/OR_Top100K_V1_3mm_clipped_LGN4mm');
    
    % get .pdb filename
    LORf = dir(fullfile(fgDir,'*Lt-LGN4*_MD4.pdb'));
    RORf = dir(fullfile(fgDir,'*Rt-LGN4*_MD4.pdb'));
    
    %      ORf = dir('*_D5_L4.pdb');
    %     for ij = 1:2
    %         cd(newDir)
    fgL = fgRead(fullfile(fgDir,LORf.name));
    fgR = fgRead(fullfile(fgDir,RORf.name));
    
    
    %         fgWrite(fgL,[fgL.name ,'.pdb'],'.pdb')
    mtrExportFibers(fgL, fullfile(fgDir,fgL.name), [], [], [], 2);
    mtrExportFibers(fgR, fullfile(fgDir,fgR.name), [], [], [], 2);
    %         fgWrite(fgR,'ROR1206_D4L4.pdb','.pdb')
    %     end
end

%% measure diffusion properties
% see runSO_DivideFibersAcordingToFiberLength_3SD

% %% AFQ_removeFiberOutliers
% for i =id
%     SubDir = fullfile(homeDir,subDir{i});
%     fgDir  = fullfile(SubDir,'/dwi_2nd/fibers/conTrack/OR_Top100K_V1_3mm_clipped_LGN4mm');
%     
%     % get .pdb filename
%     ORf(1) = dir(fullfile(fgDir,'*fg_OR_Top100K_V1_3mm_clipped_LGN4mm_Rt-LGN4*NOT1201.pdb'));
%     ORf(2) = dir(fullfile(fgDir,'*fg_OR_Top100K_V1_3mm_clipped_LGN4mm_Lt-LGN4*NOT1201.pdb'));
%     
%     for ij = 1:2
%         fg = fgRead(fullfile(fgDir,ORf(ij).name));
%         
%         % remove outlier fiber
%         maxDist =4;
%         maxLen = 2;
%         numNodes = 50;
%         M = 'mean';
%         count = 1;
%         show = 1;
%         
%         [fgclean ,keep] =  AFQ_removeFiberOutliers(fg,maxDist,maxLen,numNodes,M,count,show);
%         
%         for l =1:length(fgclean.params)
%             fgclean.params{1,l}.stat=fgclean.params{1,l}.stat(keep);
%         end
%         fgclean.pathwayInfo = fgclean.pathwayInfo(keep);
%         
%         % Align fiber direction from Anterior to posterior
%         fgclean = SO_AlignFiberDirection(fgclean,'AP');
%         
%         % save new fg.pdb file
%         fibername       = sprintf('%s_D4L2.pdb',fgclean.name);
%         mtrExportFibers(fgclean,fullfile(fgDir,fibername),[],[],[],2);
%         
%         %         %% to save the pdb file.
%         %         cd(newDir)
%         %         fibername       = sprintf('%s_D4_L2.pdb',fgclean.name);
%         %         mtrExportFibers(fgclean,fibername,[],[],[],2);
%         
%         %         end
%     end
% end
