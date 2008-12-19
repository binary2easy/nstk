
function [mix, x, indexes] = gmminit_5classes_image_MRF(mix, imagedata, header,...
                            atlas_csf, atlas_cortex, atlas_wm1, atlas_wm2, atlas_outlier, brainmask, ...
                            options, initType, initParameters)
%GMMINIT Initialises Gaussian mixture model from data
%
%	Description
%	MIX = GMMINIT(MIX, X, OPTIONS) uses a dataset X to initialise the
%	parameters of a Gaussian mixture model defined by the data structure
%	MIX.  The k-means algorithm is used to determine the centres. The
%	priors are computed from the proportion of examples belonging to each
%	cluster. The covariance matrices are calculated as the sample
%	covariance of the points associated with (i.e. closest to) the
%	corresponding centres. For a mixture of PPCA model, the PPCA
%	decomposition is calculated for the points closest to a given centre.
%	This initialisation can be used as the starting point for training
%	the model using the EM algorithm.
%
%	See also
%	GMM
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Hui modified this to fit the atlas based image segmentation

% new inputs: imagedata, atlas_csf, atlas_cortex, atlas_wm1, atlas_wm2, atlas_outlier
% the effective pixels are shown by -1;
% initType: 'likelihood', 'mcd', 'optimizedclustering'
disp('gmm initializing ...');

% find all effective points and record the [row col depth] into the indexes

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;
indexes = [];
atlas_csf(find(brainmask == 0 )) = 0;
atlas_cortex(find(brainmask == 0 )) = 0;
atlas_wm1(find(brainmask == 0 )) = 0;
atlas_wm2(find(brainmask == 0 )) = 0;
atlas_outlier(find(brainmask == 0 )) = 0;

% i, j, k: row, column, depth
[i_csf, j_csf, k_csf] = ind2sub(size(atlas_csf), find(atlas_csf > initParameters.eps));

[i_wm1, j_wm1, k_wm1] = ind2sub(size(atlas_wm1), find(atlas_wm1 > initParameters.eps));
[i_wm2, j_wm2, k_wm2] = ind2sub(size(atlas_wm2), find(atlas_wm2 > initParameters.eps));

[i_cortex, j_cortex, k_cortex] = ind2sub(size(atlas_cortex), find(atlas_cortex > initParameters.eps));
[i_outlier, j_outlier, k_outlier] = ind2sub(size(atlas_outlier), find(atlas_outlier > initParameters.eps));

points = union([i_csf j_csf k_csf], [i_wm1 j_wm1 k_wm1], 'rows');
points2 = union(points, [i_cortex j_cortex k_cortex], 'rows');
points3 = union(points2, [i_outlier, j_outlier, k_outlier], 'rows');
points4 = union(points3, [i_wm2, j_wm2, k_wm2], 'rows');

i = points4(:, 1);
j = points4(:, 2);
k = points4(:, 3);

ndata = length(i);
x = zeros(ndata, mix.nin); 
for ps = 1:ndata
    x(ps, :) = imagedata(i(ps), j(ps), k(ps));
end
clear imagedata brainmask
mix.indexes = [i j k];
mix.indexes = uint32(mix.indexes);
mix.priors = zeros(ndata, 5); % four classes
mix.atlas = zeros(ysize, xsize, zsize, 4, 'single');
mix.classification = zeros(ysize, xsize, zsize, 5, 'single');
mix.playing = zeros(ysize, xsize, zsize, 'uint8');
mix.sampleInd = zeros(ndata, 1, 'uint32');
mix.indexVolume = zeros(size(imagedata), 'uint32');

for m=1:ndata
    mix.priors(m,:) = [atlas_csf(i(m), j(m), k(m)) atlas_cortex(i(m), j(m), k(m)) ...
        atlas_wm1(i(m), j(m), k(m)) atlas_wm2(i(m), j(m), k(m)) atlas_outlier(i(m), j(m), k(m))];
    mix.playing(i(m), j(m), k(m)) = 1;
    mix.sampleInd(m) = sub2ind([ysize xsize zsize], i(m), j(m), k(m));
    mix.indexVolume(i(m), j(m), k(m)) = m;

end

mix.atlas(:,:,:,1) = atlas_wm1+atlas_wm2;
mix.atlas(:,:,:,2) = atlas_cortex;
mix.atlas(:,:,:,3) = atlas_csf;
mix.atlas(:,:,:,4) = atlas_outlier;

mix.lkp = [1 1 2 3 4];

% Check that inputs are consistent
% errstring = consist(mix, 'gmm', x);
% if ~isempty(errstring)
%   error(errstring);
% end

% initialize the centers and vairance
if ( strcmp(mix.covar_type, 'full') == 1 )
    switch lower(initType)

        case {'likelihood'}
            probablity_thres = initParameters.minimalP;

            % csf
            pp = mix.priors(:,1);
            ll = find(pp>=probablity_thres);
            x_csf = x(ll,:);

            mix.centres(1,:) = mean(x_csf);
            mix.covars(:,:,1) = cov(x_csf);

            % cortex
            pp = mix.priors(:,2);
            ll = find(pp>=probablity_thres);
            x_cortex = x(ll,:);

            mix.centres(2,:) = mean(x_cortex);
            mix.covars(:,:,2) = cov(x_cortex);

            % whitematters1
            pp = mix.priors(:,3);
            ll = find(pp>=probablity_thres);
            x_wm = x(ll,:);

            mix.centres(3,:) = mean(x_wm);
            mix.covars(:,:,3) = cov(x_wm);
            
            % whitematters2
            pp = mix.priors(:,4);
            ll = find(pp>=probablity_thres);
            x_wm = x(ll,:);

            mix.centres(4,:) = mean(x_wm);
            mix.covars(:,:,4) = cov(x_wm);            
            
            % outlier
            pp = mix.priors(:,5);
            ll = find(pp>=probablity_thres);
            x_outlier = x(ll,:);

            mix.centres(5,:) = mean(x_outlier);
            mix.covars(:,:,5) = cov(x_outlier);
        case {'mcd'}
            disp('Fast Minimum Covariance Determinant Estimator ...')

            option.lts = 1;

            probablity_thres = initParameters.minimalP;

            % csf
            pp = mix.priors(:,1);
            ll_csf = find(pp>=probablity_thres);
            x_csf = x(ll_csf,:);

            [res,raw]=fastmcd(x_csf, option);

            mix.centres(1,:) = res.center;
            mix.covars(:,:,1) = res.cov;

            % cortex
            pp = mix.priors(:,2);
            ll_cortex = find(pp>=probablity_thres);
            x_cortex = x(ll_cortex,:);

            [res,raw]=fastmcd(x_cortex, option);

            mix.centres(2,:) = res.center;
            mix.covars(:,:,2) = res.cov;

            % whitematters1
            pp = mix.priors(:,3);
            ll_wm = find(pp>=probablity_thres);
            x_wm = x(ll_wm,:);

            [res,raw]=fastmcd(x_wm, option);

            mix.centres(3,:) = res.center;
            mix.covars(:,:,3) = res.cov;
                       
            % whitematters2
            pp = mix.priors(:,4);
            ll_wm = find(pp>=probablity_thres);
            x_wm = x(ll_wm,:);

            [res,raw]=fastmcd(x_wm, option);

            mix.centres(4,:) = res.center;
            mix.covars(:,:,4) = res.cov;
            
            % outlier
            pp = mix.priors(:,5);
            ll_outlier = find(pp>=probablity_thres);
            x_outlier = x(ll_outlier,:);

            [res,raw]=fastmcd(x_outlier, option);

            mix.centres(5,:) = res.center;
            mix.covars(:,:,5) = res.cov;

        case {'optimizedclustering'}
            disp('no implemeted')

        otherwise
            disp('Unknown initialization method')
    end
%     return;
end

% % save points
% points_data = zeros(size(atlas_csf), 'uint32');
% pp = indexes(ll_csf(:), :);
% 
% num = length(pp);
% for i = 1:num
%     points_data(pp(i,1), pp(i,2), pp(i,3)) = 1;
% end
% SaveAnalyze(points_data, header, 'csfP2.hdr', 'Grey');
% 
% points_data = zeros(size(atlas_whitematter), 'uint32');
% pp = indexes(ll_wm(:), :);
% 
% num = length(pp);
% for i = 1:num
%     points_data(pp(i,1), pp(i,2), pp(i,3)) = 1;
% end
% SaveAnalyze(points_data, header, 'wmP2.hdr', 'Grey');
% 
% points_data = zeros(size(atlas_cortex), 'uint32');
% pp = indexes(ll_cortex(:), :);
% 
% num = length(pp);
% for i = 1:num
%     points_data(pp(i,1), pp(i,2), pp(i,3)) = 1;
% end
% SaveAnalyze(points_data, header, 'cortexP2.hdr', 'Grey');
% % save points -- end

% Arbitrary width used if variance collapses to zero: make it 'large' so
% that centre is responsible for a reasonable number of points.
GMM_WIDTH = 1.0;

switch mix.covar_type
case 'spherical'
   if mix.ncentres > 1
      % Determine widths as distance to nearest centre 
      % (or a constant if this is zero)
      cdist = dist2(mix.centres, mix.centres);
      cdist = cdist + diag(ones(mix.ncentres, 1)*realmax);
      mix.covars = min(cdist);
      mix.covars = mix.covars + GMM_WIDTH*(mix.covars < eps);
   else
      % Just use variance of all data points averaged over all
      % dimensions
      mix.covars = mean(diag(cov(x)));
   end
  case 'diag'
    for j = 1:mix.ncentres
      % Pick out data points belonging to this centre
      c = x(find(post(:, j)),:);
      diffs = c - (ones(size(c, 1), 1) * mix.centres(j, :));
      mix.covars(j, :) = sum((diffs.*diffs), 1)/size(c, 1);
      % Replace small entries by GMM_WIDTH value
      mix.covars(j, :) = mix.covars(j, :) + GMM_WIDTH.*(mix.covars(j, :)<eps);
    end
  case 'full'
        disp('image application should be "full" ')
  case 'ppca'
    for j = 1:mix.ncentres
      % Pick out data points belonging to this centre
      c = x(find(post(:,j)),:);
      diffs = c - (ones(size(c, 1), 1) * mix.centres(j, :));
      [tempcovars, tempU, templambda] = ...
	ppca((diffs'*diffs)/size(c, 1), mix.ppca_dim);
      if length(templambda) ~= mix.ppca_dim
	error('Unable to extract enough components');
      else 
        mix.covars(j) = tempcovars;
        mix.U(:, :, j) = tempU;
        mix.lambda(j, :) = templambda;
      end
    end
  otherwise
    error(['Unknown covariance type ', mix.covar_type]);
end

