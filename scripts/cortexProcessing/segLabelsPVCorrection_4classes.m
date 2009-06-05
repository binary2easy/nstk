function [segOut, priorsOut] = segLabelsPVCorrection_4classes(priorsIn, ...
  imageIndices, segIn, connectivity, lambda, ...
  csfLabel, wmLabel, cortexLabel, pvLabel, nonbrainLabel)

% priorsIn     : Nx4
% imageIndices : Nx3
% segIn        : 3D image of labels, size is xsize x ysize x zsize
% connectivity : 6, for now, perhaps 18 or 26 later?
% lambda       : the fraction for downweighting priors, e.g. 0.5
% 
% segOut       : output seg with PV voxels marked.
% priorsOut    : adjusted priors.
% csflabel, wmlabel, cortexlabel, pvlabel, nonbrainlabel : the various
%               labels.

small = 0.00000001; %% 1e-8;

% NB, not all the voxels in the image, just the ones with priors defined:
% noOfVoxels = size(priorsIn, 1);

% Copy over priors and seg for now.
priorsOut = priorsIn;
segOut = segIn;



if (connectivity ~= 6)
  error('tempLabelPVCorrection : connectivity not equal to 6. Not implemented');
  return;
end

% What tissue is adjacent to each voxel within a 6 nbhd?
hasCSFnbr      = hasNeighboursWithLabel_6(segIn, csfLabel);
% hasWMnbr       = hasNeighboursWithLabel_6(segIn, wmLabel);
hasCortexNbr   = hasNeighboursWithLabel_6(segIn, cortexLabel);
hasNonbrainNbr = hasNeighboursWithLabel_6(segIn, nonbrainLabel);

% Which image indices have a prior value assigned?
I = imageIndices(:, 1);
J = imageIndices(:, 2);
K = imageIndices(:, 3);

% The priors order is csf cortex    wm   nonbrain 
% or                  csf cortex wm1 wm2 nonbrain

csfPriorImg      = zeros(size(segIn));
cortexPriorImg   = zeros(size(segIn));
wmPriorImg       = zeros(size(segIn));
nonbrainPriorImg = zeros(size(segIn));

indsForPriors = sub2ind(size(segIn), I, J, K);

csfPriorImg(indsForPriors)      = priorsIn(:, 1);
cortexPriorImg(indsForPriors)   = priorsIn(:, 2);
wmPriorImg(indsForPriors)       = priorsIn(:, 3);
nonbrainPriorImg(indsForPriors) = priorsIn(:, 4);


processed = false(size(segIn));

% Outline from the MEX C++ version:
% WM label
%   hasCSF && hasNonbrain && !processed
%   hasCSF && hasCortex && !processed
%   hasCortex && hasNonbrain && !processed
%   if (processed){
%      update output priors and output seg

% GM label && !processed
%   hasCSF && hasNonbrain && !processed
%   hasCSF && (label == 0) && !processed  
%   hasWM && (label == 0) && !processed
%   if (processed){
%      update output priors and output seg


% WM label.  (label == wmlabel) && !processed 
wmInds = (segIn == wmLabel); % & (~processed)

% hasCSF && hasNonbrain && !processed
inds2 = wmInds & hasCSFnbr & hasNonbrainNbr; % & (~processed);

cortexPriorImg(inds2) = lambda * cortexPriorImg(inds2);
wmPriorImg(inds2)     = lambda * wmPriorImg(inds2);
csfPriorImg(inds2)    = 1 - cortexPriorImg(inds2) - wmPriorImg(inds2) - nonbrainPriorImg(inds2);
processed(inds2)      = true;

% hasCSF && hasCortex && !processed
inds2 = wmInds & hasCSFnbr & hasCortexNbr & (~processed);
wmPriorImg(inds2)     = lambda * wmPriorImg(inds2);

residual = 1 - csfPriorImg(inds2)    - ...
               cortexPriorImg(inds2) - ...
               wmPriorImg(inds2)     - ...
               nonbrainPriorImg(inds2);

sumWgts  = csfPriorImg(inds2) + cortexPriorImg(inds2) + small;

csfNew    = csfPriorImg(inds2)    + ...
  (residual .* csfPriorImg(inds2))    ./ sumWgts;
cortexNew = cortexPriorImg(inds2) + ...
  (residual .* cortexPriorImg(inds2)) ./ sumWgts;

csfPriorImg(inds2)    = csfNew;
cortexPriorImg(inds2) = cortexNew;
processed(inds2)      = true;

% hasCortex && hasNonbrain && !processed
inds2 = wmInds & hasCortexNbr & hasNonbrainNbr & (~processed);

wmPriorImg(inds2) = lambda * wmPriorImg(inds2);

residual = 1 - csfPriorImg(inds2)    - ...
               cortexPriorImg(inds2) - ...
               wmPriorImg(inds2)     - ...
               nonbrainPriorImg(inds2);

sumWgts  = csfPriorImg(inds2) + cortexPriorImg(inds2) + small;

csfNew    = csfPriorImg(inds2)    + ...
  (residual .* csfPriorImg(inds2))    ./ sumWgts;
cortexNew = cortexPriorImg(inds2) + ...
  (residual .* cortexPriorImg(inds2)) ./ sumWgts;

csfPriorImg(inds2)    = csfNew;
cortexPriorImg(inds2) = cortexNew;
processed(inds2)      = true;



% GM label  (label == cortexlabel) && !processed
gmInds = (segIn == cortexLabel) & (~processed);

% hasCSF && hasNonbrain && !processed
inds2 = gmInds & hasCSFnbr & hasNonbrainNbr & (~processed);

cortexPriorImg(inds2) = lambda * cortexPriorImg(inds2);
wmPriorImg(inds2)     = lambda * wmPriorImg(inds2);
csfPriorImg(inds2)    = 1 - cortexPriorImg(inds2) - wmPriorImg(inds2) - nonbrainPriorImg(inds2);
processed(inds2)      = true;

% These next two conditions do not appear to be satisfiable.

% hasCSF && (label == 0) && !processed
% hasWM && (label == 0) && !processed

% if (processed){ update output priors and output seg
segOut(processed) = pvLabel;
priorsOut(:, 1) = csfPriorImg(indsForPriors);
priorsOut(:, 2) = cortexPriorImg(indsForPriors);
priorsOut(:, 3) = wmPriorImg(indsForPriors);
priorsOut(:, 4) = nonbrainPriorImg(indsForPriors);


return

function hasNeighboursWithLabel = hasNeighboursWithLabel_6(labelImage, labelValue)

hasNeighboursWithLabel = zeros(size(labelImage));

temp = labelImage(1:end-1, :, :);
hasNeighboursWithLabel(2:end, :, :) = hasNeighboursWithLabel(2:end, :, :) | (temp == labelValue);

temp = labelImage(2:end, :, :);
hasNeighboursWithLabel(1:end-1, :, :) = hasNeighboursWithLabel(1:end-1, :, :) | (temp == labelValue);

temp = labelImage(:, 1:end-1, :);
hasNeighboursWithLabel(:, 2:end, :) = hasNeighboursWithLabel(:, 2:end, :) | (temp == labelValue);

temp = labelImage(:, 2:end, :);
hasNeighboursWithLabel(:, 1:end-1, :) = hasNeighboursWithLabel(:, 1:end-1, :) | (temp == labelValue);

temp = labelImage(:, :, 1:end-1);
hasNeighboursWithLabel(:, :, 2:end) = hasNeighboursWithLabel(:, :, 2:end) | (temp == labelValue);

temp = labelImage(:, :, 2:end);
hasNeighboursWithLabel(:, :, 1:end-1) = hasNeighboursWithLabel(:, :, 1:end-1) | (temp == labelValue);

return






