function [mix, options, errlog] = gmmem_image_PVs_Local(mix, x, options, partsmask, globalSeg)
%GMMEM	EM algorithm for Gaussian mixture model.
%
%	Description
%	[MIX, OPTIONS, ERRLOG] = GMMEM(MIX, X, OPTIONS) uses the Expectation
%	Maximization algorithm of Dempster et al. to estimate the parameters
%	of a Gaussian mixture model defined by a data structure MIX. The
%	matrix X represents the data whose expectation is maximized, with
%	each row corresponding to a vector.    The optional parameters have
%	the following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values; also logs error
%	values in the return argument ERRLOG. If OPTIONS(1) is set to 0, then
%	only warning messages are displayed.  If OPTIONS(1) is -1, then
%	nothing is displayed.
%
%	OPTIONS(3) is a measure of the absolute precision required of the
%	error function at the solution. If the change in log likelihood
%	between two steps of the EM algorithm is less than this value, then
%	the function terminates.
%
%	OPTIONS(5) is set to 1 if a covariance matrix is reset to its
%	original value when any of its singular values are too small (less
%	than MIN_COVAR which has the value eps).   With the default value of
%	0 no action is taken.
%
%	OPTIONS(14) is the maximum number of iterations; default 100.
%
%	The optional return value OPTIONS contains the final error value
%	(i.e. data log likelihood) in OPTIONS(8).
%
%	See also
%	GMM, GMMINIT
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Hui modified this to fit the atlas based image segmentation

% Check that inputs are consistent
errstring = consist(mix, 'gmm', x);
if ~isempty(errstring)
  error(errstring);
end

[ndata, xdim] = size(x);

% Sort out the options
if (options(14))
  niters = options(14);
else
  niters = 100;
end

display = options(1);
store = 0;
if (nargout > 2)
  store = 1;	% Store the error values to return them
  errlog = zeros(1, niters);
end
test = 0;
if options(3) > 0.0
  test = 1;	% Test log likelihood for termination
end

check_covars = 0;
if options(5) >= 1
  if display >= 0
    disp('check_covars is on');
  end
  check_covars = 1;	% Ensure that covariances don't collapse
  MIN_COVAR = eps;	% Minimum singular value of covariance matrix
  init_covars = mix.covars;
end

results = zeros([mix.header.ysize mix.header.xsize mix.header.zsize], 'uint32');

% Main loop of algorithm
for n = 1:niters
  
    % Calculate posteriors based on old parameters
    [post, act] = gmmpost_image(mix, x);

    % Calculate error value if needed
    if (display | store | test)
    prob = act.*mix.priors;
    prob = sum(prob, 2);
    % Error value is negative log likelihood of data
    e = - sum(log(prob));
    if store
      errlog(n) = e;
    end
    if display > 0
      fprintf(1, 'Cycle %4d  Error %11.6f\n', n, e);
    end
    if test
      if (n > 1 & abs(e - eold) < options(3))
        options(8) = e;
        return;
      else
        eold = e;
      end
    end
    end

    % Adjust the new estimates for the parameters
    new_pr = sum(post, 1);
    new_c = post' * x;

    % Now move new estimates to old parameter vectors

    % Do not need to update the prior.
    % mix.priors = new_pr ./ ndata;

    mix.centres = new_c ./ (new_pr' * ones(1, mix.nin));

    switch mix.covar_type
    case 'spherical'
    n2 = dist2(x, mix.centres);
    for j = 1:mix.ncentres
      v(j) = (post(:,j)'*n2(:,j));
    end
    mix.covars = ((v./new_pr))./mix.nin;
    if check_covars
      % Ensure that no covariance is too small
      for j = 1:mix.ncentres
        if mix.covars(j) < MIN_COVAR
          mix.covars(j) = init_covars(j);
        end
      end
    end
    case 'diag'
    for j = 1:mix.ncentres
      diffs = x - (ones(ndata, 1) * mix.centres(j,:));
      mix.covars(j,:) = sum((diffs.*diffs).*(post(:,j)*ones(1, ...
        mix.nin)), 1)./new_pr(j);
    end
    if check_covars
      % Ensure that no covariance is too small
      for j = 1:mix.ncentres
        if min(mix.covars(j,:)) < MIN_COVAR
          mix.covars(j,:) = init_covars(j,:);
        end
      end
    end
    case 'full'
    for j = 1:mix.ncentres
      diffs = x - (ones(ndata, 1) * mix.centres(j,:));
      diffs = diffs.*(sqrt(post(:,j))*ones(1, mix.nin));
      mix.covars(:,:,j) = (diffs'*diffs)/new_pr(j);
    end
    if check_covars
      % Ensure that no covariance is too small
      for j = 1:mix.ncentres
        if min(svd(mix.covars(:,:,j))) < MIN_COVAR
          mix.covars(:,:,j) = init_covars(:,:,j);
        end
      end
    end
    case 'ppca'
    for j = 1:mix.ncentres
      diffs = x - (ones(ndata, 1) * mix.centres(j,:));
      diffs = diffs.*(sqrt(post(:,j))*ones(1, mix.nin));
      [tempcovars, tempU, templambda] = ...
    ppca((diffs'*diffs)/new_pr(j), mix.ppca_dim);
      if length(templambda) ~= mix.ppca_dim
    error('Unable to extract enough components');
      else 
        mix.covars(j) = tempcovars;
        mix.U(:, :, j) = tempU;
        mix.lambda(j, :) = templambda;
      end
    end
    if check_covars
      if mix.covars(j) < MIN_COVAR
        mix.covars(j) = init_covars(j);
      end
    end
    otherwise
      error(['Unknown covariance type ', mix.covar_type]);               
    end

    % removal PVs

    % estimate partial volume voxels
    if ( mod(n, mix.PVStep) == 0 )
        
        csflabel = 1;
        if ( mix.ncentres == 5 )
            wmlabel = [3 4];
            nonbrainlabel = 5;
        else
            wmlabel = 3;
            nonbrainlabel = 4;
        end
        cortexlabel =  2;
        pvlabel = 8;
        
        disp(' classifying the voxels ... ');
        results(:) = 0;
        [ndata, ndim] = size(mix.indexes);
        for pp = 1:ndata
            label = find(post(pp,:) == max(post(pp,:)));
            results(mix.indexes(pp, 1), mix.indexes(pp, 2), mix.indexes(pp, 3)) = label(1);
        end
        
        filename = ['segResults/segResult_gmmPVs_results' num2str(n) '.hdr' ];
        SaveAnalyze(uint32(results), mix.header, filename, 'Grey');

        [label3D, largestComponent, results] = RegionVolumeFilter_cortex(results, mix.header, nonbrainlabel);
        clear label3D largestComponent
        % change prioris

        if ( mix.ncentres == 4 )
            [LabeledSeg, mix] = LabelPVs_Seg_gmm_4classes_Local_MEX(mix, results, ...
                                                csflabel, wmlabel, cortexlabel, pvlabel,...
                                                nonbrainlabel, partsmask, globalSeg);
        else          
            [LabeledSeg, mix] = LabelPVs_Seg_gmm_5classes_Local_MEX(mix, results, ...
                                        csflabel, wmlabel, cortexlabel, pvlabel,...
                                        nonbrainlabel, partsmask, globalSeg);
        end

        filename = ['segResults/segResult_gmmPVs_LabeledSeg_' num2str(n) '.hdr' ];
        SaveAnalyze(uint32(LabeledSeg), mix.header, filename, 'Grey');

    end
end

%options(8) = -sum(log(gmmprob(mix, x)));
if (display >= 0)
  disp(maxitmess);
end