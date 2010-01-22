function runEM_4_withPriors(subjPars, posteriorDir, flags, header, imagedata, brainmask)

suffix = '.nii.gz';

csfT     = loadAnalyze(subjPars.priorCSF, 'Real');
gmT      = loadAnalyze(subjPars.priorCortex, 'Real');
wmT      = loadAnalyze(subjPars.priorWM, 'Real');
outlierT = loadAnalyze(subjPars.priorOutlier, 'Real');

[csfT, wmT, cortexT, outlierT] = preProcPriors_4(csfT, wmT, gmT, outlierT);


% pvlabel = 0;
% neighborwidth = 3;

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


% volumeThreshold = 200;
label = [2];

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, label);

filename = fullfile(subjPars.resultDir, [ prefix '_cortex_seg' suffix]);
saveAnalyze(uint32(largestComponent), header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, [ 'cortex_seg_4classes' suffix]);
% Previously also saved largest component. Changed to saving label3D to
% make consistent with WM below.
saveAnalyze(uint32(label3D), header, filename, 'Grey');


% volumeThreshold = 200;
label = [3];

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, label);

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
