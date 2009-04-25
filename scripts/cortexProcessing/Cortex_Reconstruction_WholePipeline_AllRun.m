function Cortex_Reconstruction_WholePipeline_AllRun(subjDir, noOfClasses, appDir)

if (noOfClasses == 5)
  Prepare_membershipFunction(subjDir)
end

Prepare_Cortex_Reconstruction(subjDir, noOfClasses);
disp('Cortex_Reconstruction_WholePipeline_AllRun');
disp(subjDir);
disp(['No of Classes : ' num2str(noOfClasses)]);


% perpare data for reconstruction
%         runflag = 0;
%         filename = 'enhanced_gm_membership.hdr';
%         if ( isempty(dir(filename))==1 )
%             runflag = 1;
%         else
%             [GM_Enhanced, header_GM] = LoadAnalyze(filename, 'Grey');
%         end
%         
%         filename = 'wm_membership_roi.hdr';
%         [wm, header_WM] = LoadAnalyze(filename, 'Real');
% 
%         if ( exist('header_GM') )
%             
%             if ( header_GM.xsize~=header_WM.xsize )
%                 runflag = 1;
%             end
%             
%             if ( header_GM.ysize~=header_WM.ysize )
%                 runflag = 1;
%             end
% 
%             if ( header_GM.zsize~=header_WM.zsize )
%                 runflag = 1;
%             end
%         end
        
%         filename = 'External_levelset_Result.hdr';
%         if ( isempty(dir(filename))==1 )
%             runflag = 1;
%         end
        
        % -----------------------------------------------------------------
        % internal surface
        %bValue = 0.02;
        bValue = 0.05;
        accuracy = 'medium';
        tMax_ReIntialize = 3;
        errorMax = 0.05;
        resultDir = 'levelset_Internal';

        %tMax = 2;                   % End time.
        tMax = 4;                   % End time.
        
        tPlot = 0.1;
        prefix = 'Internal';
        flag_outside = 0; % target surface must be outside the data0 surface
        flag_inside = 0; % target surface must be inside the data0 surface
        factorCFL = 0.5;
        reInitialStep = 0.25;

        InternalSurfaces_NoTopologyPreserving(subjDir, noOfClasses, appDir);

        % -----------------------------------------------------------------
        % GM Enhancement
        ratio_csf = 0.9;
        bValue = 0.02;
        accuracy = 'low';
        tMax_ReIntialize = 3;
        errorMax = 0.001;
        resultDir = 'levelset_GM_Enhancement';

        tMax = 4;                   % End time.

        plotSteps = 20;              % How many intermediate plots to produce?
        tPlot = 0.5;
        factorCFL = 0.1;
        prefix = 'GM_Enhanced';
        shockThreshold = 0.8;
        tp = 0.32;
        GM_Enhancement_Cruise
        % -----------------------------------------------------------------
        % external surface        
        bValue = 0.02;
        accuracy = 'medium';
        tMax_ReIntialize = 3;
        errorMax = 0.05;
        resultDir = 'levelset_External_TH';

        tMax = 3;                   % End time.
        
        tPlot = 0.1;
        factorCFL = 0.5;
        reInitialStep = 0.2;
        prefix = 'External';
        flag_outside = 1; % target surface must be outside the data0 surface
        flag_inside = 0; % target surface must be inside the data0 surface
        saveFlag = 0;

        minThickness_flag = 1;
        minThickness = 0.5;
        maxThickness = 5;
        
        Reconstruction_External_GM_Enhanced_TH
        % -----------------------------------------------------------------
