function runEM_5_withPriors(subjPars, posteriorDir, flags, header, imagedata, brainmask)

suffix = '.nii.gz';

csfT     = loadAnalyze(subjPars.priorCSF, 'Real');
gmT      = loadAnalyze(subjPars.priorCortex, 'Real');
wmT1     = loadAnalyze(subjPars.priorWM1, 'Real');
wmT2     = loadAnalyze(subjPars.priorWM2, 'Real');
outlierT = loadAnalyze(subjPars.priorOutlier, 'Real');

[csfT, wmT1, wmT2, cortexT, outlierT] = preProcPriors_5(csfT, wmT1, wmT2, gmT, outlierT);

% EM segmentation


% set up mixture model
ncentres = 5;
input_dim = 1;
mix = gmm(input_dim, ncentres, 'full');
mix.header = header;
mix.offset = [-1 0 0; 1 0 0; 0 -1 0; 0 1 0; 0 0 -1; 0 0 1];

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

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, label);

filename = fullfile(subjPars.resultDir, [prefix '_cortex_seg' suffix]);
saveAnalyze(uint32(largestComponent), header, filename, 'Grey');

filename = fullfile(subjPars.resultDir, ['cortex_seg_5classes' suffix]);
saveAnalyze(uint32(label3D), header, filename, 'Grey');

volumeThreshold = 200;
label = [3 4];

[label3D, largestComponent] = RegionVolumeFilter_cortex(LabeledSeg, header, label);

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
