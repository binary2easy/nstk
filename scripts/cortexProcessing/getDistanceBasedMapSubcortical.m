function getDistanceBasedMapSubcortical(maskFileName, outputName, outputNameComplement, sigma)

% Input is assumed to be a binary brain mask with the subcortical region
% excluded.  This script estimates the subcortical region and generates a
% distance map from it.  The positive (outside) of this map is used to
% generate an exponentially decaying weight map which is saved to file
% outputName.
%
% Not currently used.
% 
% Makes use of 'inhull' routine.

[maskData, header] = loadAnalyze(maskFileName, 'Grey');


% First find the convex hull of the mask:

dims = size(maskData);

[X, Y, Z] = ndgrid(1:dims(1), 1:dims(2), 1:dims(3));

X = X(maskData > 0);
Y = Y(maskData > 0);
Z = Z(maskData > 0);

labelledPoints = [X Y Z];

[X, Y, Z] = ndgrid(1:dims(1), 1:dims(2), 1:dims(3));

testPoints = [X(:) Y(:) Z(:)];

indsInside = inhull(testPoints, labelledPoints);

hullData = maskData;
hullData = reshape(hullData, [], 1);
hullData(indsInside) = 1;
hullData = reshape(hullData, size(maskData));

% Erode the hull a few times to get a central blob.

for i = 1:5
  hullData = imerode(hullData, ones(3,3,3));
end

inds = find(hullData > 0);

centralBlob = hullData;
centralBlob(inds) = centralBlob(inds) - maskData(inds);

reflectBlob = flipdim(centralBlob, 1);
centralBlob = centralBlob + reflectBlob;
centralBlob(centralBlob > 1) = 1;

dmap = bwdist(centralBlob);
% saveAnalyze(dmap, header, 'dmap.nii.gz', 'Real');

lambda = exp(-1.0 * dmap .* dmap / (sigma^2));

saveAnalyze(lambda, header, outputName, 'Real');

saveAnalyze(1.0 - lambda, header, outputNameComplement, 'Real');


