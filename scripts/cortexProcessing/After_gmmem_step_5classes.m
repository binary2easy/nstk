function results = After_gmmem_step_5classes(imagedata, header, mix, post, subjPars)

suffix = '.nii.gz';

results = zeros(size(imagedata), 'uint32');

[ndata, ndim] = size(mix.indexes);

for i = 1:ndata
    label = find(post(i,:) == max(post(i,:)));
    results(mix.indexes(i, 1), mix.indexes(i, 2), mix.indexes(i, 3)) = label(1);
end

%% DISCREPANCY WITH LABELS USED PRIOR TO THIS POINT?? SEE 4 CLASS VERSION.
csflabel      = 1;
cortexlabel   = 2;
wmlabel       = [3 4];
nonbrainlabel = 5;

results = Rectify_NonBrainNoise(results, csflabel, cortexlabel, wmlabel, nonbrainlabel, header);

% filename = fullfile(Global_SegResult, [prefix '_segResult_4classes' suffix]);
% saveAnalyze(results, header, filename, 'Grey' );

filename = fullfile(subjPars.resultDir, ['segResult_5classes' suffix]);
saveAnalyze(results, header, filename, 'Grey' );

% save posterior as data file
[post_csf, post_wm1, post_wm2, post_gm, post_outlier] = GetPostImage_5classes(mix, header, post);

LabelPVs_Image = GetLabelPVs_Image(mix);



filename = fullfile(subjPars.postDir, ['LabelPVs_Image' suffix]);
saveAnalyze(uint32(LabelPVs_Image), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_csf' suffix]);
saveAnalyze(uint32(post_csf), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_gm' suffix]);
saveAnalyze(uint32(post_gm), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_wm1' suffix]);
saveAnalyze(uint32(post_wm1), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_wm2' suffix]);
saveAnalyze(uint32(post_wm2), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_outlier' suffix]);
saveAnalyze(uint32(post_outlier), header, filename, 'Grey' );

filename = fullfile(subjPars.postDir, ['post_csf' suffix]);
saveAnalyze(uint32(LabelPVs_Image), header, filename, 'Grey' );


[post_csf, post_wm1, post_wm2, post_gm, post_outlier] = GetPostImage_Real_5classes(mix, header, post);

filename = fullfile(subjPars.postDir, ['post_csf_Real' suffix]);
saveAnalyze(post_csf, header, filename, 'Real' );

filename = fullfile(subjPars.postDir, ['post_gm_Real' suffix]);
saveAnalyze(post_gm, header, filename, 'Real' );

filename = fullfile(subjPars.postDir, ['post_wm1_Real' suffix]);
saveAnalyze(post_wm1, header, filename, 'Real' );

filename = fullfile(subjPars.postDir, ['post_wm2_Real' suffix]);
saveAnalyze(post_wm2, header, filename, 'Real' );

filename = fullfile(subjPars.postDir, ['post_outlier_Real' suffix]);
saveAnalyze(post_outlier, header, filename, 'Real' );

