
function [x, indexes] = kmean_init(imagedata, header, brainmask)

% kmean_init Initialises data vector and record the indexes
%
% Hui generated this as a part of neonatal cortex segmentation work

% new inputs: imagedata, header, brainmask, 
% the effective pixels are shown by 1 in the brainmask;
% find all effective points and record the [row col depth] into the indexes

% What are the single valued indices of non-zero voxels in the mask?
inds = find(brainmask > 0);

% Convert the indices into 3D array subscripts/
[i, j, k] = ind2sub(size(brainmask), inds);

% points = [i, j, k];
% 
% i = points(:, 1);
% j = points(:, 2);
% k = points(:, 3);

% How many voxels in the ROI?
ndata = length(i);
% Single channel image
noOfChannels = 1;

x = zeros(ndata, noOfChannels); 

for u = 1:ndata
    x(u, :) = imagedata(i(u), j(u), k(u));
end

indexes = [i j k];

return
