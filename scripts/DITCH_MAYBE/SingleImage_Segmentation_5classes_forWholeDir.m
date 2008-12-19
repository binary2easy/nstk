% algorithm parameters

% TryNumber = 5;
trynumber = TryNumber;

Kmeans_InitialCentres = [];

Low_Thres = 0.8;
volumeThres = 8;
partsNumber = 14;
initialCentres = [];
posteriorDir = 'posterior_5classes';
% ============================================================== %
Four_classes_flag = 0;
Five_classes_flag = 1;

Global_flag = 1; 
Local_flag = 0;

Atlas_flag_Global = 0;
Atlas_flag_Local = 0;

Kmeans_flag_Global = 1;
Kmeans_flag_Local = 1;

MRF_flag_Global = 0;
MRF_flag_Local = 0;

GMM_PVs_flag = 1;
GMM_PVs_flag_Local = 1;

Save_flag = 1;
% ============================================================== %
% ==================================================================== %
% parse the parameters
prefix = CreatePrefix(home, Global_flag, Local_flag, Atlas_flag_Global, Atlas_flag_Local,...
    Kmeans_flag_Global, Kmeans_flag_Local, MRF_flag_Global, MRF_flag_Local, Four_classes_flag, ...
    Five_classes_flag, partsNumber, GMM_PVs_flag, GMM_PVs_flag_Local);
prefix
if ( Four_classes_flag )
    classnumber = 4;
end

if ( Five_classes_flag )
    classnumber = 5;
end

% ==================================================================== %
% load images

[brainmask, header] = LoadAnalyze(brainMaskfile,'Grey');
[imagedata, header] = LoadAnalyze(imagefile,'Grey');

% read kmeans intialization centres
if ( classnumber == 5 )
    Kmeansfile = [KmeansDir 'Kmeans_InitialCentres_5classes.txt'];
    KmeansResultFile = [KmeansDir '5classes_kmeansResult.hdr'];
end

if ( classnumber == 4 )
    Kmeansfile = [KmeansDir 'Kmeans_InitialCentres_4classes.txt'];
    KmeansResultFile = [KmeansDir '4classes_kmeansResult.hdr'];
end
Kmeans_InitialCentres = [];

% ==================================================================== %
Global_Kmeans_EM_5classes_PVs
