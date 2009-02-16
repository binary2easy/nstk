function Prepare_membershipFunction(subjDir)

% Add together the two WM classes in a five class segmentation to give a
% single map.

suffix = '.nii.gz';

filename1   = fullfile(subjDir, 'post5', ['post_wm1_Real' suffix]);
filename2   = fullfile(subjDir, 'post5', ['post_wm2_Real' suffix]);

filenameOut = fullfile(subjDir, 'post5', ['post_wm_Real' suffix]);

if (~exist(filename1, 'file') || ~exist(filename2, 'file') )
  disp('Unable to find one or more of the five class WM maps : ');
  disp(filename1);
  disp(filename2);
  error('');
end

[post_wm1_Real, header] = loadAnalyze(filename1, 'Real');
[post_wm2_Real, header] = loadAnalyze(filename2, 'Real');

post_wm_Real = post_wm1_Real + post_wm2_Real;

saveAnalyze(post_wm_Real, header, filenameOut, 'Real');

