
function SDF = CreateApproximated_SDF(data, header)
% create an approximated signed distance function for a 3D bianry volume
% the data should be a volume with isotropic resolution, so that the image
% coordinates equal to the world coordinate
% the 6-connected neighborhood is used for both inter and outer
% surfaces
% the distance of surface voxels is assigned to be +/- 0.5 (pixel
% coordinate)
% the Euler distances of other points are computed using the k-d tree
% locator

disp('preforming the distance transform ... ');

offsets = [-1 0 0; 1 0 0; 0 -1 0; 0 1 0; 0 0 -1; 0 0 1];

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

SDF = zeros(size(data), 'double');

points = zeros(xsize*ysize*floor(zsize/2), 3); % store the points on the inter/outer surface

% this loop will get all surface points, so it is safe not to detect all
% boundary points
index = 0;
for k = 2:zsize-1
    for j = 2:ysize-1
        for i = 2:xsize-1
            
            neighbors = GetNeighbourhood2_6neighbors(data, header, offsets, i, j, k);
            
            hasOne = find(neighbors==1);
            hasZero = find(neighbors==0);
            
            if ( (length(hasOne)>0) & (length(hasZero)>0) )
               if ( data(j, i, k) == 1 )
                   SDF(j, i, k ) = -0.5;
               else
                   SDF(j, i, k ) = 0.5;
               end
               index = index + 1;
               points(index, :) = [i, j, k];
            end
        end
    end
end
points = points(1:index, :);

% internal points
internalInd = find(data==1);
numOfInternal = length(internalInd);
[j, i, k] = ind2sub(size(data), internalInd);
points_Internal = [i, j, k];
clear internalInd i j k

[minDist, nearestPoints] = GetNearestPoints_VTK(points_Internal, points);
for tt = 1:numOfInternal
    i = points_Internal(tt, 1);
    j = points_Internal(tt, 2);
    k = points_Internal(tt, 3);
    SDF(j, i, k) = -(minDist(tt) + 0.5);
end

% outer points
outerInd = find(data==0);
numOfOuter = length(outerInd);
[j, i, k] = ind2sub(size(data), outerInd);
points_Outer = [i, j, k];
clear outerInd i j k

[minDist, nearestPoints] = GetNearestPoints_VTK(points_Outer, points);
for tt = 1:numOfOuter
    i = points_Outer(tt, 1);
    j = points_Outer(tt, 2);
    k = points_Outer(tt, 3);
    SDF(j, i, k) = minDist(tt) + 0.5;
end

return