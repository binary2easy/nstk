
function [mix, x, indexes] = gmminit_2classes_image_uint8(mix, imagedata, header,...
                            atlas_cortex, atlas_wm, brainmask, ...
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
atlas_cortex(find(brainmask == 0 )) = 0;
atlas_wm(find(brainmask == 0 )) = 0;

% i, j, k: row, column, depth
[i_wm, j_wm, k_wm] = ind2sub(size(atlas_wm), find(atlas_wm > initParameters.eps));
[i_cortex, j_cortex, k_cortex] = ind2sub(size(atlas_cortex), find(atlas_cortex > initParameters.eps));

points = union([i_wm, j_wm, k_wm], [i_cortex j_cortex k_cortex], 'rows');

i = points(:, 1);
j = points(:, 2);
k = points(:, 3);

ndata = length(i);
x = zeros(ndata, mix.nin); 
for ps = 1:ndata
    x(ps, :) = imagedata(i(ps), j(ps), k(ps));
end
clear imagedata brainmask i_wm j_wm k_wm i_cortex j_cortex k_cortex points

mix.indexes = [i j k];
mix.indexes = uint32(mix.indexes);
mix.priors = zeros(ndata, 2); % gm, wm

mix.atlas = zeros(ysize, xsize, zsize, 2, 'uint8'); % gm, wm
mix.classification = zeros(ysize, xsize, zsize, 2, 'uint8');

mix.playing = zeros(ysize, xsize, zsize, 'uint8');
mix.sampleInd = [];
mix.indexVolume = zeros(size(imagedata), 'uint32');

for m=1:ndata
    mix.priors(m,:) = [atlas_cortex(i(m), j(m), k(m)) atlas_wm(i(m), j(m), k(m))];
    mix.playing(i(m), j(m), k(m)) = 1;
%     mix.sampleInd(m) = sub2ind([ysize xsize zsize], i(m), j(m), k(m));
    mix.indexVolume(i(m), j(m), k(m)) = m;
end

mix.atlas(:,:,:,1) = uint8(round(255*atlas_wm));
mix.atlas(:,:,:,2) = uint8(255 - mix.atlas(:,:,:,1));

outsideROI = find(mix.playing==0);
[row, col, plane] = ind2sub(size(mix.playing), outsideROI);
ind = sub2ind(size(mix.atlas), row, col, plane, 2*ones(length(row), 1));
mix.atlas(ind(:)) = 0;
clear outsideROI row col plane ind

mix.lkp = [1 2];

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

            % cortex
            pp = mix.priors(:,1);
            %ll = find(pp>=probablity_thres);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_cortex = x(ll,:);

            mix.centres(1,:) = mean(x_cortex);
            mix.covars(:,:,1) = cov(x_cortex);

            % whitematters
            pp = mix.priors(:,2);
%             ll = find(pp>=probablity_thres);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_wm = x(ll,:);

            mix.centres(2,:) = mean(x_wm);
            mix.covars(:,:,2) = cov(x_wm); 
            
        case {'mcd'}
            disp('Fast Minimum Covariance Determinant Estimator ...')

            option.lts = 1;

            probablity_thres = initParameters.minimalP;

            % cortex
            pp = mix.priors(:,1);
%             ll_cortex = find(pp>=probablity_thres);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_cortex = x(ll,:);

            [res,raw]=fastmcd(x_cortex, option);

            mix.centres(1,:) = res.center;
            mix.covars(:,:,1) = res.cov;

            % whitematters
            pp = mix.priors(:,2);
%             ll_wm = find(pp>=probablity_thres);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_wm = x(ll,:);

            [res,raw]=fastmcd(x_wm, option);

            mix.centres(2,:) = res.center;
            mix.covars(:,:,2) = res.cov;
            
        case {'optimizedclustering'}
            disp('no implemeted')

        otherwise
            disp('Unknown initialization method')
    end
%     return;
end

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

