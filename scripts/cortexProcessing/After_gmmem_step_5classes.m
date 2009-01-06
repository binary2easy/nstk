
% save results
results = zeros(size(imagedata), 'uint32');
[ndata, ndim] = size(mix.indexes);
for i = 1:ndata
    label = find(post(i,:) == max(post(i,:)));
    results(mix.indexes(i, 1), mix.indexes(i, 2), mix.indexes(i, 3)) = label(1);
end

csflabel = 1;
cortexlabel = 2;
wmlabel = [3 4];
nonbrainlabel = 5;

results = Rectify_NonBrainNoise(results, csflabel, cortexlabel, wmlabel, nonbrainlabel, header);

% filename = [Global_SegResult prefix '_segResult_4classes.hdr'];
SaveAnalyze(results, header, filename, 'Grey' );

filename = 'segResult_5classes.hdr';
SaveAnalyze(results, header, filename, 'Grey' );

% save posterior as data file
[post_csf, post_wm1, post_wm2, post_gm, post_outlier] = GetPostImage_5classes(mix, header, post);
LabelPVs_Image = GetLabelPVs_Image(mix);

if ( ~exist(posteriorDir) )
    posteriorDir = 'posterior_5classes';
end

mkdir(posteriorDir);

% SaveAnalyze(uint32(post_csf), header, 'posterior/post_csf.hdr', 'Grey' );
% SaveAnalyze(uint32(post_wm1), header, 'posterior/post_wm1.hdr', 'Grey' );
% SaveAnalyze(uint32(post_wm2), header, 'posterior/post_wm2.hdr', 'Grey' );
% SaveAnalyze(uint32(post_gm), header, 'posterior/post_gm.hdr', 'Grey' );
% SaveAnalyze(uint32(post_outlier), header, 'posterior/post_outlier.hdr', 'Grey' );
filename = fullfile(posteriorDir, 'LabelPVs_Image.hdr');
SaveAnalyze(uint32(LabelPVs_Image), header, filename, 'Grey' );
% [post_csf, post_wm1, post_wm2, post_gm, post_outlier] = GetPostImage_Real_5classes(mix, header, post);
% SaveAnalyze(post_csf, header, 'posterior/post_csf.hdr', 'Real' );
% SaveAnalyze(post_wm1, header, 'posterior/post_wm1.hdr', 'Real' );
% SaveAnalyze(post_wm2, header, 'posterior/post_wm2.hdr', 'Real' );
% SaveAnalyze(post_gm, header, 'posterior/post_gm.hdr', 'Real' );
% SaveAnalyze(post_outlier, header, 'posterior/post_outlier.hdr', 'Real' );

filename = fullfile(posteriorDir, 'post_csf.hdr');
SaveAnalyze(uint32(post_csf), header, filename, 'Grey' );

filename = fullfile(posteriorDir, 'post_gm.hdr');
SaveAnalyze(uint32(post_gm), header, filename, 'Grey' );

filename = fullfile(posteriorDir, 'post_wm1.hdr');
SaveAnalyze(uint32(post_wm1), header, filename, 'Grey' );

filename = fullfile(posteriorDir, 'post_wm2.hdr');
SaveAnalyze(uint32(post_wm2), header, filename, 'Grey' );

filename = fullfile(posteriorDir, 'post_outlier.hdr');
SaveAnalyze(uint32(post_outlier), header, filename, 'Grey' );

filename = fullfile(posteriorDir, 'post_csf.hdr');
SaveAnalyze(uint32(LabelPVs_Image), header, filename, 'Grey' );

[post_csf, post_wm1, post_wm2, post_gm, post_outlier] = GetPostImage_Real_5classes(mix, header, post);

filename = fullfile(posteriorDir, 'post_csf_Real.hdr');
SaveAnalyze(post_csf, header, filename, 'Real' );

filename = fullfile(posteriorDir, 'post_gm_Real.hdr');
SaveAnalyze(post_gm, header, filename, 'Real' );

filename = fullfile(posteriorDir, 'post_wm1_Real.hdr');
SaveAnalyze(post_wm1, header, filename, 'Real' );

filename = fullfile(posteriorDir, 'post_wm2_Real.hdr');
SaveAnalyze(post_wm2, header, filename, 'Real' );

filename = fullfile(posteriorDir, 'post_outlier_Real.hdr');
SaveAnalyze(post_outlier, header, filename, 'Real' );