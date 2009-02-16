function singleImageSegmentation(noOfClasses, subjPars)

% algorithm parameters

% TryNumber = 5;
% trynumber = TryNumber;
% Kmeans_InitialCentres = [];

% Low_Thres = 0.8;
% volumeThres = 8;
% partsNumber = 14;
% initialCentres = [];

posteriorDir = ['post' num2str(noOfClasses)];
% ============================================================== %
% See bottom of file for the original flag names, these were all global
% variables.

if (noOfClasses == 4)
    flags.fourClasses = 1;
    flags.fiveClasses = 0;
elseif (noOfClasses == 5)
    flags.fourClasses = 1;
    flags.fiveClasses = 0;
else
    disp('singleImageSegmentation.m : ');
    error('Incorrect number of classes specified, must be 4 or 5.');
end

flags.global = 1;
flags.local  = 0;
flags.atlasGlobal = 0;
flags.atlasLocal  = 0;
flags.kmeansGlobal = 1;
flags.kmeansLocal  = 1;
flags.mrfGlobal = 0;
flags.mrfLocal  = 0;
flags.gmmPVs = 1;
flags.gmmPVsLocal = 1;
flags.save = 1;

% ============================================================== %
% ==================================================================== %
% parse the parameters
% prefix = CreatePrefix(home, Global_flag, Local_flag, Atlas_flag_Global, Atlas_flag_Local,...
%     Kmeans_flag_Global, Kmeans_flag_Local, MRF_flag_Global, MRF_flag_Local, Four_classes_flag, ...
%     Five_classes_flag, partsNumber, GMM_PVs_flag, GMM_PVs_flag_Local);
% prefix

% ==================================================================== %
% load images

[brainmask, header] = loadAnalyze(subjPars.brainMaskfile,'Grey');
[imagedata, header] = loadAnalyze(subjPars.imagefile,'Grey');

% read kmeans intialization centres
% if ( noOfClasses == 5 )
%     Kmeansfile = [subjPars.kmeansDir 'Kmeans_InitialCentres_5classes.txt'];
%     KmeansResultFile = [KmeansDir '5classes_kmeansResult.hdr'];
% end
% 
% if ( noOfClasses == 4 )
%     Kmeansfile = [KmeansDir 'Kmeans_InitialCentres_4classes.txt'];
%     KmeansResultFile = [KmeansDir '4classes_kmeansResult.hdr'];
% end
% Kmeans_InitialCentres = [];


% ==================================================================== %
if (noOfClasses == 4)
    Global_Kmeans_EM_4classes_PVs(subjPars, posteriorDir, flags, header, imagedata, brainmask);
end

if (noOfClasses == 5)
    Global_Kmeans_EM_5classes_PVs(subjPars, posteriorDir, flags, header, imagedata, brainmask);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OLD FLAG NAMES FOR GLOBAL VARIABLES.
% Four_classes_flag = 1;
% Five_classes_flag = 0;

% Global_flag = 1; 
% Local_flag = 0;

% Atlas_flag_Global = 0;
% Atlas_flag_Local = 0;

% Kmeans_flag_Global = 1;
% Kmeans_flag_Local = 1;

% MRF_flag_Global = 0;
% MRF_flag_Local = 0;

% GMM_PVs_flag = 1;
% GMM_PVs_flag_Local = 1;

% Save_flag = 1;
