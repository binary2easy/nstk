function SDF = createApproximated_SDF(data, header, appDir)

% Create an approximated signed distance function for a 3D binary volume
% the data should be a volume with isotropic resolution, so that the image
% coordinates are a uniform scaling of the world coordinates along each
% dimension.


randstr  = ['temp-dmap' strrep(num2str(rand), '0.', '') '.nii'];
saveAnalyze(data, header, randstr, 'Grey');

command = [appDir '/dmap'];
command = [command ' "' randstr '"'];
command = [command ' "' randstr '"'];

preCommand = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}' 
if strcmp(getenv('OS'), 'Linux')
  command = [preCommand ';' command];
end
disp(command);

[status, result] = system(command)

[SDF, dummyHeader] = loadAnalyze(randstr, 'Real');

delete(randstr);

return

% OLD VERSION:
% USED A MEX CALL TO CODE THAT USED KD TREE LOCATOR.

% % The 6-connected neighborhood is used for both inter and outer
% % surfaces.
% % The distance of surface voxels is assigned to be +/- 0.5 (pixel
% % coordinate).
% % The Euler distances of other points are computed using the k-d tree
% % locator.
% 
% disp('Performing the distance transform ... ');
% 
% offsets = [-1 0 0; 1 0 0; 0 -1 0; 0 1 0; 0 0 -1; 0 0 1];
% 
% xsize = header.xsize;
% ysize = header.ysize;
% zsize = header.zsize;
% 
% SDF = zeros(size(data), 'double');
% 
% % Heuristically make enough room in the array for surface points based on
% % half the number of voxels in the image.
% % store the points on the inter/outer surface
% points = zeros(xsize * ysize * floor(zsize/2), 3); 
% 
% % This loop will get all surface points, so it is safe not to detect all
% % boundary points.
% 
% index = 0;
% for k = 2:zsize-1
%   for j = 2:ysize-1
%     for i = 2:xsize-1
%             
%       neighbors = getNeighbourhood2_6neighbors(data, header, offsets, i, j, k);
%             
%       hasOne  = find(neighbors == 1);
%       hasZero = find(neighbors == 0);
%             
%       if ( (length(hasOne) > 0) && (length(hasZero) > 0) )
% 
%         if ( data(i, j, k) == 1 )
%           SDF(i, j, k ) = -0.5;
%         else
%           SDF(i, j, k ) = 0.5;
%         end
% 
%         index = index + 1;
%         points(index, :) = [i, j, k];
%       end
%     end
%   end
% end
% 
% % Truncate points array, not all voxels are near the surface 
% points = points(1:index, :);
% 
% % Internal points
% internalInd = find(data==1);
% numOfInternal = length(internalInd);
% 
% [i, j, k] = ind2sub(size(data), internalInd);
% 
% points_Internal = [i, j, k];
% 
% clear internalInd i j k
% 
% [minDist, nearestPoints] = GetNearestPoints_VTK(points_Internal, points);
% 
% for tt = 1:numOfInternal
%     i = points_Internal(tt, 1);
%     j = points_Internal(tt, 2);
%     k = points_Internal(tt, 3);
%     SDF(i, j, k) = -(minDist(tt) + 0.5);
% end
% 
% % outer points
% outerInd = find(data==0);
% numOfOuter = length(outerInd);
% [i, j, k] = ind2sub(size(data), outerInd);
% points_Outer = [i, j, k];
% clear outerInd i j k
% 
% [minDist, nearestPoints] = GetNearestPoints_VTK(points_Outer, points);
% 
% for tt = 1:numOfOuter
%     i = points_Outer(tt, 1);
%     j = points_Outer(tt, 2);
%     k = points_Outer(tt, 3);
%     SDF(i, j, k) = minDist(tt) + 0.5;
% end
% 
% return