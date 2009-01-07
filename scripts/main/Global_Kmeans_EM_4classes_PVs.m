function Global_Kmeans_EM_4classes_PVs(subjPars, posteriorDir, flags, header, imagedata, brainmask)

suffix = '.nii.gz';

[kmeans_label, kmeansHeader] = loadAnalyze(subjPars.kmeansLabels4, 'Grey');

[csfLabel, cortexLabel, wmLabel, outlierLabel] = GetClassLabel_4classes(imagedata, kmeans_label);

% pvlabel = 0;
% neighborwidth = 3;

% create simulated atlas

% wmSeg = zeros(size(kmeans_label), 'uint8');
% gmSeg = zeros(size(kmeans_label), 'uint8');
% csfSeg = zeros(size(kmeans_label), 'uint8');
% outlierSeg = zeros(size(kmeans_label), 'uint8');
% 
% wmSeg(find(kmeans_label==wmLabel)) = 1;
% gmSeg(find(kmeans_label==cortexLabel)) = 1;
% csfSeg(find(kmeans_label==csfLabel)) = 1;
% outlierSeg(find(kmeans_label==outlierLabel)) = 1;

wmSeg      = uint8(kmeans_label == wmLabel);
gmSeg      = uint8(kmeans_label == cortexLabel);
csfSeg     = uint8(kmeans_label == csfLabel);
outlierSeg = uint8(kmeans_label == outlierLabel);

sigmaCSF     = header.xvoxelsize;
sigmaWM      = 2 * header.xvoxelsize;
sigmaCortex  = 2 * header.xvoxelsize;
sigmaOutlier = header.xvoxelsize;
% 
% halfwidthCsf     = 2;
% halfwidthWm      = 3;
% halfwidthCortex  = 3;
% halfwidthOutlier = 2;

[csfT, wmT, cortexT, outlierT] = CreateTemplates_4classes_Gaussian(header, csfSeg, wmSeg, gmSeg, outlierSeg, ...
                    sigmaCSF, sigmaWM, sigmaCortex, sigmaOutlier);
                
clear wmSeg gmSeg csfSeg outlierSeg kmeans_label

% run EM to refine results
ncentres  = 4;
input_dim = 1;

% Use the Netlab tool to generate a GMM structure.
mix = gmm(input_dim, ncentres, 'full');
mix.header = header;
mix.offset = [-1 0 0; 1 0 0; 0 -1 0; 0 1 0; 0 0 -1; 0 0 1];

options = [];
initType = 'mcd';
% A starting threshold for tissue probability when seeking voxels with the
% highest probabilty values, see findHighProb.m.
initParameters.minimalP = 0.6;

% Minimum value for probability maps.
initParameters.eps = 0.02;
[mix, x, indexes] = gmminit_4classes_image(mix, imagedata, header,...
                        csfT, cortexT, wmT, outlierT, brainmask, ...
                        options, initType, initParameters);

clear csfT cortexT wmT outlierT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up options for GMM EM.

options = zeros(1,18);
% Display error values
options(1) = 1;
% Maximum number of iterations
options(14) = 35;
%%% PA TEMP CHANGE FOR DEBUGGING.
% options(14) = 1;
%%%
% Min change in error function for the stopping condition.
options(3) = 1e-3;
% Reset covariance matrix to original value when any of its singular
% values is too small.
options(5) = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[mix, options, errlog] = gmmem_image_PVs_WM2CSF(mix, x, options);

% compute the posterior probablities
[post, a] = gmmpost_image(mix, x);


prefix = 'prefix';

% filename = fullfile(subjPars.resultDir, [prefix '_segResult_4classes' suffix]);

results = After_gmmem_step_4classes(imagedata, header, mix, post, subjPars);


% ====================================================== %
% detect PVs
pvlabel       = 0;
csfLabel      = 1;
cortexLabel   = 2;
wmLabel       = 3;
nonbrainlabel = 4;

neighborwidth = 3;


LabeledSeg = LabelPVs_Seg_slow_fillLabeledSeg(double(results), header, ...
                                    csfLabel, wmLabel, cortexLabel, pvlabel,...
                                    nonbrainlabel, neighborwidth);

filename = fullfile(subjPars.resultDir, [ prefix '_segResult_4classes_PVs' suffix]);
saveAnalyze(uint32(LabeledSeg), header, filename, 'Grey');


volumeThreshold = 200;
label = [2];

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, volumeThreshold, label);

filename = fullfile(subjPars.resultDir, [ prefix '_cortex_seg' suffix]);
saveAnalyze(uint32(largestComponent), header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, [ 'cortex_seg_4classes' suffix]);
% Previously also saved largest component. Changed to saving label3D to
% make consistent with WM below.
saveAnalyze(uint32(label3D), header, filename, 'Grey');


volumeThreshold = 200;
label = [3];

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, volumeThreshold, label);

filename = fullfile(subjPars.resultDir, [ prefix '_wm_seg' suffix]);
saveAnalyze(uint32(largestComponent), header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, [ 'wm_seg_4classes' suffix]);
saveAnalyze(uint32(label3D), header, filename, 'Grey');


label3D = zeros(size(LabeledSeg), 'uint32');
label3D(LabeledSeg == csfLabel) = 1;

filename = fullfile(subjPars.resultDir, [ prefix '_csf_seg' suffix]);
saveAnalyze(label3D, header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, [ 'csf_seg_4classes' suffix]);
saveAnalyze(label3D, header, filename, 'Grey');


clear LabeledSeg post label3D largestComponent
