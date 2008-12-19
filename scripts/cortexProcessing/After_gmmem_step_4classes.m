function results = After_gmmem_step_4classes(imagedata, header, mix, post, subjPars)%, csflabel, cortexlabel, wmlabel, nonbrainlabel)

suffix = '.nii.gz';

% save results
results  = zeros(size(imagedata), 'uint32');
prior_wm = zeros(size(imagedata), 'single');
prior_gm = zeros(size(imagedata), 'single');

[ndata, ndim] = size(mix.indexes);
for i = 1:ndata
    label = find(post(i,:) == max(post(i,:)));
    results(mix.indexes(i, 1), mix.indexes(i, 2), mix.indexes(i, 3))  = label(1);
    prior_wm(mix.indexes(i, 1), mix.indexes(i, 2), mix.indexes(i, 3)) = mix.priors(i, 3);
    prior_gm(mix.indexes(i, 1), mix.indexes(i, 2), mix.indexes(i, 3)) = mix.priors(i, 2);
end

%%% THESE LABELS SEEMED TO CHANGE COMPARED TO WHAT WERE USED IN THE CALLING
%%% FUNCTION (GLOBAL_KMEANS 4 CLASSES).  COMMENTED OUT BELOW AND PASSED IN
%%% THE LABELS USED BY CALLING FUNCTION AS ARGUMENTS.  DIDN'T CHANGE MUCH
%%% ...
csflabel      = 1;
cortexlabel   = 2;
wmlabel       = 3;
nonbrainlabel = 4;

csflabel      = 4;
cortexlabel   = 2;
wmlabel       = 3;
nonbrainlabel = 1;

results = Rectify_NonBrainNoise(results, csflabel, cortexlabel, wmlabel, nonbrainlabel, header);

% filename = fullfile(Global_SegResult, [prefix '_segResult_4classes' suffix]);
% saveAnalyze(results, header, filename, 'Grey' );

filename = fullfile(subjPars.resultDir , ['segResult_4classes' suffix]);
saveAnalyze(results, header, filename, 'Grey' );

filename = fullfile(subjPars.resultDir, ['prior_wm' suffix]);
saveAnalyze(prior_wm, header, filename, 'Real' );

filename = fullfile(subjPars.resultDir, ['prior_gm' suffix]);
saveAnalyze(prior_gm, header, filename, 'Real' );

clear prior_wm prior_gm

% save posterior as data file
[post_csf, post_wm, post_gm, post_outlier] = GetPostImage_4classes(mix, header, post);

LabelPVs_Image = GetLabelPVs_Image(mix);

% if ( ~exist(posteriorDir) )
%     posteriorDir = 'posterior_4classes';
% end
%
% mkdir(posteriorDir);

filename = fullfile(subjPars.postDir, ['LabelPVs_Image' suffix]);
saveAnalyze(uint32(LabelPVs_Image), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_csf' suffix]);
saveAnalyze(uint32(post_csf), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_wm' suffix]);
saveAnalyze(uint32(post_wm), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_gm' suffix]);
saveAnalyze(uint32(post_gm), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_outlier' suffix]);
saveAnalyze(uint32(post_outlier), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_csf' suffix]);
saveAnalyze(uint32(LabelPVs_Image), header, filename, 'Grey' );

[post_csf, post_wm, post_gm, post_outlier] = GetPostImage_Real_4classes(mix, header, post);

filename = fullfile(subjPars.postDir, ['post_csf_Real' suffix]);
saveAnalyze(post_csf, header, filename, 'Real' );

filename = fullfile(subjPars.postDir, ['post_wm_Real' suffix]);
saveAnalyze(post_wm, header, filename, 'Real' );

filename = fullfile(subjPars.postDir, ['post_gm_Real' suffix]);
saveAnalyze(post_gm, header, filename, 'Real' );

filename = fullfile(subjPars.postDir, ['post_outlier_Real' suffix]);
saveAnalyze(post_outlier, header, filename, 'Real' );

