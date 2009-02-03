
function [mix, x, indexes] = gmminit_4classes_image(mix, imagedata, header,...
                            atlas_csf, atlas_gm, atlas_wm, atlas_out, brainmask, ...
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

% Hui modified this to fit the atlas based image segmentation.

% New inputs: imagedata, atlas_csf, atlas_gm, atlas_wm, atlas_out
% (outliers).
% the effective pixels are shown by -1;
% initType: 'likelihood', 'mcd', 'optimizedclustering'

disp('GMM 4 classes initializing ...');

% find all effective points and record the [row col depth] into the indexes

temp = find(brainmask == 0);
atlas_csf(temp) = 0;
atlas_gm(temp)  = 0;
atlas_wm(temp)  = 0;
atlas_out(temp) = 0;

% i, j, k: row, column, depth
dims = size(atlas_csf);
if (any(dims ~= size(atlas_wm)) || any(dims ~= size(atlas_gm)) || any(dims ~= size(atlas_out)))
    disp('gmminit_4classes_image.m');
    error('dimension mismatch among the atlases');
end

% Find subscripts for voxels where each tissue type is present.
[i_csf, j_csf, k_csf] = ind2sub(dims, find(atlas_csf > initParameters.eps));
[i_wm,  j_wm,  k_wm ] = ind2sub(dims, find(atlas_wm > initParameters.eps));
[i_gm,  j_gm,  k_gm ] = ind2sub(dims, find(atlas_gm > initParameters.eps));
[i_out, j_out, k_out] = ind2sub(dims, find(atlas_out > initParameters.eps));

% Find the set union of all subscripts.
points1 = union([i_csf j_csf k_csf], [i_wm j_wm k_wm], 'rows');
points2 = union(points1, [i_gm j_gm k_gm], 'rows');
points3 = union(points2, [i_out, j_out, k_out], 'rows');

% Get the index subscripts for all voxels with tissue present - without
% repetitions.
i = points3(:, 1);
j = points3(:, 2);
k = points3(:, 3);

ndata = length(i);
x = zeros(ndata, mix.nin); 
for ps = 1:ndata
    x(ps, :) = imagedata(i(ps), j(ps), k(ps));
end

indexes = [i j k];
mix.indexes = uint32(indexes);
mix.priors = zeros(ndata, 4); % four classes
mix.indexVolume = zeros(size(imagedata));
mix.indexVolume = uint32(mix.indexVolume);

% mix.priors will have rows equal to number of voxels with something
% present (i.e. > greater than initParameters.eps).  The number of columns
% is the number of tissue classes.
%
% mix.indexVolume is a 3D array where positive integers refer to the index
% of the voxel in the data column x and, equivalently, the priors columns
% for each class.
for m=1:ndata
    mix.priors(m,:) = [atlas_csf(i(m), j(m), k(m)) atlas_gm(i(m), j(m), k(m)) ...
        atlas_wm(i(m), j(m), k(m)) atlas_out(i(m), j(m), k(m))];
    mix.indexVolume(i(m), j(m), k(m)) = m;
end

% Check that inputs are consistent
% errstring = consist(mix, 'gmm', x);
% if ~isempty(errstring)
%   error(errstring);
% end

% initialize the centers and variances
if ( strcmp(mix.covar_type, 'full') == 1 )
    switch lower(initType)

        case {'Likelihood'}
            probablity_thres = initParameters.minimalP;

            % Get the csf prior data.
            pp = mix.priors(:,1);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_csf = x(ll,:);

            mix.centres(1,:)  = mean(x_csf);
            mix.covars(:,:,1) = cov(x_csf);

            % cortex
            pp = mix.priors(:,2);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_gm = x(ll,:);

            mix.centres(2,:) = mean(x_gm);
            mix.covars(:,:,2) = cov(x_gm);

            % white matter
            pp = mix.priors(:,3);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_wm = x(ll,:);

            mix.centres(3,:) = mean(x_wm);
            mix.covars(:,:,3) = cov(x_wm);
            
            % outlier
            pp = mix.priors(:,4);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_out = x(ll,:);

            mix.centres(4,:) = mean(x_out);
            mix.covars(:,:,4) = cov(x_out);
            
        case {'mcd'}
            disp('Fast Minimum Covariance Determinant Estimation.')

            option.lts = 1;

            probablity_thres = initParameters.minimalP;

            % csf
            pp = mix.priors(:,1);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_csf = x(ll,:);
            
            % Use the Stats and Patt. Recog library tool to estimate the
            % mean and variance robustly.
            
            [res, raw] = fastmcd(x_csf, option);
            mix.centres(1,:) = res.center;
            if (res.cov > 0)
              mix.covars(:,:,1) = res.cov;
            else
              temp = max(x_csf) - min(x_csf);
              if (temp > 0)
                mix.covars(:,:,1) = 0.001 * temp;
              else
                mix.covars(:,:,1) = 0.001;
              end
            end

            % cortex
            pp = mix.priors(:,2);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_gm = x(ll,:);

            [res, raw] = fastmcd(x_gm, option);
            mix.centres(2,:) = res.center;
            if (res.cov > 0)
              mix.covars(:,:,2) = res.cov;
            else
              temp = max(x_gm) - min(x_gm);
              if (temp > 0)
                mix.covars(:,:,2) = 0.001 * temp;
              else
                mix.covars(:,:,2) = 0.001;
              end
            end

            % white matter
            pp = mix.priors(:,3);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_wm = x(ll,:);

            [res, raw] = fastmcd(x_wm, option);
            mix.centres(3,:) = res.center;
            if (res.cov > 0)
              mix.covars(:,:,3) = res.cov;
            else
              temp = max(x_wm) - min(x_wm);
              if (temp > 0)
                mix.covars(:,:,3) = 0.001 * temp;
              else
                mix.covars(:,:,3) = 0.001;
              end
            end
            
            % outlier
            pp = mix.priors(:,4);
            ll = findHighProb(pp, probablity_thres, mix.minN);
            x_out = x(ll,:);

            [res, raw] = fastmcd(x_out, option);
            mix.centres(4,:) = res.center;
            if (res.cov > 0)
              mix.covars(:,:,4) = res.cov;
            else
              temp = max(x_out) - min(x_out);
              if (temp > 0)
                mix.covars(:,:,4) = 0.001 * temp;
              else
                mix.covars(:,:,4) = 0.001;
              end
            end
            
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
        disp('image application should be "full" ??? PA')
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

