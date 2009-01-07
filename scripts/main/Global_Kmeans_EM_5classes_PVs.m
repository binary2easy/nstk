function Global_Kmeans_EM_5classes_PVs(subjPars, posteriorDir, flags, header, imagedata, brainmask)

suffix = '.nii.gz';

[kmeans_label, kmeansHeader] = loadAnalyze(subjPars.kmeansLabels5, 'Grey');

[csflabel, cortexlabel, wmlabel1, wmlabel2, outlierlabel] = GetClassLabel_5classes(imagedata, kmeans_label);

wmlabel = [wmlabel1 wmlabel2];
pvlabel = 0;

neighborwidth = 3;

% LabeledSeg = LabelPVs_Seg(double(kmeans_label), header, ...
%                         csflabel, wmlabel, cortexlabel, pvlabel,...
%                         nonbrainlabel, neighborwidth);
LabeledSeg = kmeans_label;
% create simulated atlas

% csflabel = 5;
% wmlabel1 = 3;
% wmlabel2 = 4;
% gmlabel = 2;
% outlierlabel = 1;

csfSeg = zeros(size(LabeledSeg), 'uint8');
csfSeg(find(LabeledSeg==csflabel)) = 1;

wmSeg1 = zeros(size(LabeledSeg), 'uint8');
wmSeg1(find(LabeledSeg==wmlabel1)) = 1;

wmSeg2 = zeros(size(LabeledSeg), 'uint8');
wmSeg2(find(LabeledSeg==wmlabel2)) = 1;

gmSeg = zeros(size(LabeledSeg), 'uint8');
gmSeg(find(LabeledSeg==cortexlabel)) = 1;

outlierSeg = zeros(size(LabeledSeg), 'uint8');
outlierSeg(find(LabeledSeg==outlierlabel)) = 1;

sigmaCSF = 2*header.xvoxelsize;
sigmaWM1 = 2*header.xvoxelsize;
sigmaWM2 = 2*header.xvoxelsize;

sigmaCortex = 2*header.xvoxelsize;
sigmaOutlier = header.xvoxelsize;

% Can probably ditch the following, and in 4 class version
halfwidthCsf = 3;
halfwidthWm1 = 3;
halfwidthWm2 = 2;
halfwidthCortex = 3;
halfwidthOutlier = 2;

clear LabeledSeg

[csfT, wmT1, wmT2, cortexT, outlierT] = CreateTemplates_5classes_Gaussian(header, csfSeg, wmSeg1, wmSeg2, gmSeg, outlierSeg, ...
                    sigmaCSF, sigmaWM1, sigmaWM2, sigmaCortex, sigmaOutlier);


% EM segmentation

% set up mixture model
ncentres = 5;
input_dim = 1;
mix = gmm(input_dim, ncentres, 'full');
mix.header = header;
mix.offset = [-1 0 0; 1 0 0; 0 -1 0; 0 1 0; 0 0 -1; 0 0 1];

clear csfSeg wmSeg1 wmSeg2 gmSeg outlierSeg
% brainmask = mask;
options = [];
initType = 'mcd';
initParameters.minimalP = 0.6;
initParameters.eps = 0.02;
[mix, x, indexes] = gmminit_5classes_image(mix, imagedata, header,...
                            csfT, cortexT, wmT1, wmT2, outlierT, brainmask, ...
                            options, initType, initParameters);
clear csfT cortexT wmT1 wmT2 outlierT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up options for GMM EM.

options = zeros(1,18);
% Display error values
options(1) = 1;
% Maximum number of iterations
options(14) = 35;
%%% PA TEMP CHANGE FOR DEBUGGING.
% options(14) = 1;
% Min change in error function for the stopping condition.
options(3) = 1.0e-3;
% Reset covariance matrix to original value when any of its singular
% values is too small.
options(5) = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[mix, options, errlog] = gmmem_image_PVs_WM2CSF(mix, x, options);

% compute the posterior probablities
[post, a] = gmmpost_image(mix, x);


prefix = 'prefix';


results = After_gmmem_step_5classes(imagedata, header, mix, post, subjPars);

% ====================================================== %
% detect PVs
pvlabel       = 0;
csflabel      = 1;
cortexlabel   =  2;
wmlabel       = [3 4];
nonbrainlabel = 5;

neighborwidth = 3;

LabeledSeg = LabelPVs_Seg_slow_fillLabeledSeg(double(results), header, ...
                                    csflabel, wmlabel, cortexlabel, pvlabel,...
                                    nonbrainlabel, neighborwidth);

filename = fullfile(subjPars.resultDir, [prefix '_segResult_5classes_PVs' suffix]);
saveAnalyze(uint32(LabeledSeg), header, filename, 'Grey');


volumeThreshold = 200;
label = [2];

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, volumeThreshold, label);

filename = fullfile(subjPars.resultDir, [prefix '_cortex_seg' suffix]);
saveAnalyze(uint32(largestComponent), header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, ['cortex_seg_5classes' suffix]);
saveAnalyze(uint32(label3D), header, filename, 'Grey');

volumeThreshold = 200;
label = [3 4];

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, volumeThreshold, label);

filename = fullfile(subjPars.resultDir, [prefix '_wm_seg' suffix]);
saveAnalyze(uint32(largestComponent), header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, ['wm_seg_5classes' suffix]);
saveAnalyze(uint32(label3D), header, filename, 'Grey');

label3D = zeros(size(LabeledSeg), 'uint32');
label3D(LabeledSeg == csflabel) = 1;

filename = fullfile(subjPars.resultDir, [prefix '_csf_seg' suffix]);
saveAnalyze(label3D, header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, ['csf_seg_5classes' suffix]);
saveAnalyze(label3D, header, filename, 'Grey');

clear LabeledSeg post label3D largestComponent
