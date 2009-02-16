function [minCorner, maxCorner] = getBoundingBox_BinaryVolume(data)

% Get the bounding box of non-zero voxels. Note the arbitrary expansion.

[i, j, k] = ind2sub(size(data), find(data > 0));

minCorner = [min(i) min(j) min(k)];
maxCorner = [max(i) max(j) max(k)];

% Arbitrary expansion!
minCorner = minCorner - 10;
maxCorner = maxCorner + 10;

[xsize, ysize, zsize] = size(data);

lowerLimit = ones(size(minCorner));
upperLimit = [xsize ysize zsize];

minCorner = max([minCorner; lowerLimit]);
maxCorner = min([maxCorner; upperLimit]);

return;


