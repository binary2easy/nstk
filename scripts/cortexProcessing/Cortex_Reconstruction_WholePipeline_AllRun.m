function Cortex_Reconstruction_WholePipeline_AllRun(subjDir, noOfClasses, appDir)

if (noOfClasses == 5)
  Prepare_membershipFunction(subjDir)
end

Prepare_Cortex_Reconstruction(subjDir, noOfClasses, appDir);
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

        lsParams.factorCFL = 0.5;
        lsParams.accuracy = 'medium';
        lsParams.bValue = 0.05; %bValue = 0.02;
        lsParams.errorMax = 0.05;
        lsParams.tMax = 4; % end time
        lsParams.tPlot = 0.1;
        lsParams.prefix = 'Internal';
        lsParams.reInitialStep = 0.25;
        lsParams.tMax_ReIntialize = 3;
%        lsParams.resultDir = 'levelset_Internal';
        lsParams.resultDir = [subjDir '/cortexRecon'];
        lsParams.flag_outside = 0; % target surface must be outside the data0 surface
        lsParams.flag_inside = 0; % target surface must be inside the data0 surface
        
        InternalSurfaces_NoTopologyPreserving(subjDir, noOfClasses, appDir, lsParams);

        clear lsParams;
        
        
        % -----------------------------------------------------------------
        % GM Enhancement
        
        lsParams.factorCFL = 0.1;
        lsParams.accuracy = 'low';
        lsParams.bValue = 0.02;
        lsParams.errorMax = 0.001;
        lsParams.tMax = 4;                   % End time.
        lsParams.tPlot = 0.5;
        lsParams.prefix = 'GM_Enhanced';
        lsParams.tMax_ReIntialize = 3;
%        lsParams.resultDir = 'levelset_GM_Enhancement';
        lsParams.resultDir = [subjDir '/cortexRecon'];
        
        lsParams.ratio_csf = 0.9;
        lsParams.plotSteps = 20;              % How many intermediate plots to produce?
        lsParams.shockThreshold = 0.8;
        lsParams.tp = 0.32;
        
        GM_Enhancement_Cruise(subjDir, noOfClasses, appDir, lsParams)

        clear lsParams;
        
        % -----------------------------------------------------------------
        % external surface        
        

        lsParams.factorCFL = 0.5;
        lsParams.accuracy = 'medium';
        lsParams.bValue = 0.02;
        lsParams.errorMax = 0.05;
        lsParams.tMax = 3;                   % End time.
        lsParams.tPlot = 0.1;
        lsParams.prefix = 'External';
        lsParams.tMax_ReIntialize = 3;
%        lsParams.resultDir = 'levelset_External_TH';
        lsParams.resultDir = [subjDir '/cortexRecon'];
       
        lsParams.reInitialStep = 0.2;
        lsParams.flag_outside = 1; % target surface must be outside the data0 surface
        lsParams.flag_inside = 0; % target surface must be inside the data0 surface
        lsParams.saveFlag = 0;
        lsParams.minThickness_flag = 1;
        lsParams.minThickness = 0.5;
        lsParams.maxThickness = 5;
        
        Reconstruction_External_GM_Enhanced_TH(subjDir, noOfClasses, appDir, lsParams)
        % -----------------------------------------------------------------
