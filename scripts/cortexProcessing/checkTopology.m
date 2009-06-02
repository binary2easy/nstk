
function [ yOut, schemeDataOut ] = checkTopology(t, yIn, schemeDataIn)

% schemeDataIn.LastData
% schemeDataIn.LastY
% schemeDataIn.B
% schemeData.connectivityObject
% schemeData.connectivityBackground

disp(['current time is ' num2str(t)]);
disp(['checking topology ... ']);

% yOut phi at next time point
% yIn phi_temp
yOut = yIn;
schemeDataOut = schemeDataIn;

% B will be improved at every iteration
B = schemeDataIn.B; 

LastData = schemeDataIn.LastData;
tempData = reshape(yIn, schemeDataIn.shape);
NextData = zeros(size(tempData));

% E.g. (6+,18), (6,26).  
% (18, 6+) chosen in levelSet_External_InternalSurface_TP_MinTH
connectivityObject     = schemeDataIn.connectivityObject;
connectivityBackground = schemeDataIn.connectivityBackground;

header = schemeDataIn.header;

resultDir = schemeDataIn.resultDir;
saveFlag  = schemeDataIn.saveFlag;

tempSign = sign(tempData);
tempSign(tempSign == 0) = 1;

LastSign = sign(LastData);
LastSign(LastSign==0) = 1;

% Find all voxels where the signs have not changed.
% B keeps unchanged.
index = find(tempSign==LastSign);
NextData(index) = tempData(index);

% For every voxel whose sign has changed:
index2 = find(tempSign~=LastSign);
num = length(index2);

if ( num == 0 )
  yOut = NextData(:);
  schemeDataOut.LastData = NextData;
  schemeDataOut.LastY = yOut;
  schemeDataOut.B = B;
  return;
end

offsets6 =  [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];

[n6star_inds, dummySubs] = getNeighborStar(2, 2, 2, [3 3 3], offsets6);
% Include index of center point in a 2,2,2 window.
n6_inds = [n6star_inds; 14];

offsets18 = [
  0    -1    -1
 -1     0    -1
  0     0    -1
  1     0    -1
  0     1    -1
 -1    -1     0
  0    -1     0
  1    -1     0
 -1     0     0
  1     0     0
 -1     1     0
  0     1     0
  1     1     0
  0    -1     1
 -1     0     1
  0     0     1
  1     0     1
  0     1     1];
   
[n18star_inds, dummySubs] = getNeighborStar(2, 2, 2, [3 3 3], offsets18);
% Include index of center point in a 2,2,2 window.
n18_inds = [n18star_inds; 14];

offsets26 =  [
 -1    -1    -1
  0    -1    -1
  1    -1    -1
 -1     0    -1
  0     0    -1
  1     0    -1
 -1     1    -1
  0     1    -1
  1     1    -1
 -1    -1     0
  0    -1     0
  1    -1     0
 -1     0     0
  1     0     0
 -1     1     0
  0     1     0
  1     1     0
 -1    -1     1
  0    -1     1
  1    -1     1
 -1     0     1
  0     0     1
  1     0     1
 -1     1     1
  0     1     1
  1     1     1];
   
[n26star_inds, dummySubs] = getNeighborStar(2, 2, 2, [3 3 3], offsets26);
% Include index of center point in a 2,2,2 window.
n26_inds = [n26star_inds; 14];

% [T_object, T_backgournd] = ComputeTopologicalNumber(index2, B, connectivityObject, connectivityBackground);

if ( saveFlag )
  global ntimes
  disp(['ntimes = ' num2str(ntimes)]);

  simplePoints = zeros(size(B), 'uint32');
  simplePoints(B == 1) = 80;
  filename = fullfile(resultDir, ['B_' num2str(ntimes) '.nii.gz']);
  SaveAnalyze(simplePoints, header, filename, 'Grey');
end

simplePoints = zeros(size(B), 'uint32');
simplePoints(B == 1) = 64;

value = 0;
sizeB = size(B);

for tt = 1:num
  [i, j, k] = ind2sub(schemeDataOut.shape, index2(tt));
    
  %======================================================================
  
  
  if ( (connectivityObject==26) && (connectivityBackground==6) )
        
    [n26star_inds, n26star_subs] = getNeighborStar(i, j, k, sizeB, offsets26);
    
    [InterResult, cubicVolume] = intersect_topology(n26star_inds, n26star_subs, i, j, k, B, 1); % object
    
    T_object = bwLabel_cardinality3D(cubicVolume, connectivityObject);

    [n18star_inds, n18star_subs] = getNeighborStar(i, j, k, sizeB, offsets18);
    
    [InterResult, cubicVolume] = intersect_topology(n18star_inds, n18star_subs, i, j, k, B, 0); % object
        
    T_backgournd = bwLabel_cardinality(cubicVolume, connectivityBackground, 1, n6_inds, n18_inds, n26_inds);
  end

  if ( (connectivityObject==18) && (connectivityBackground==6) )
    % object, 18-connectivity
    [GN_inds, GN_subs, cubicVolume] = geodesicNeighborhood3D(i, j, k, B, 1, connectivityObject, 2, offsets6, offsets18, offsets26);
    
    
    %     T_object = bwLabel_cardinality(cubicVolume, connectivityObject, 0, n6_inds, n18_inds, n26_inds);
    T_object = bwLabel_cardinality3D(cubicVolume, connectivityObject);

    % background, 6+ connectivity
    [GN_inds, GN_subs, cubicVolume] = geodesicNeighborhood3D(i, j, k, B, 0, connectivityBackground, 3, offsets6, offsets18, offsets26);
    %     T_backgournd = bwLabel_cardinality(cubicVolume, connectivityBackground, 0, n6_inds, n18_inds, n26_inds);
    T_backgournd = bwLabel_cardinality3D(cubicVolume, connectivityBackground);
  end
  
  
  %======================================================================
  %     [T_object, T_backgournd] = ComputeTopologicalNumber_singlePoint(i, j, k, B, ...
  %                         connectivityObject, connectivityBackground, ...
  %                         offsets6, n6_inds, offsets18, n18_inds, offsets26, n26_inds);
  
  if ( (T_object==1) & (T_backgournd==1) )
    % simple point, the phi can be updated
    NextData(i, j, k) = tempData(i, j, k);
    B(i, j, k) = mod(B(i, j, k)+1, 2);
    simplePoints(i, j, k) = 128;
  else
    value = value+1;
    % non-simple point, the sign of phi can NOT be inverted
    if ( LastData(i, j, k) <= 0 )
      NextData(i, j, k) = -10^12 * eps;
    else
      NextData(i, j, k) = 10^12 * eps;
    end
    simplePoints(i, j, k) = 255;
  end
  
end

disp(['non-simple points value = ' num2str(value)]);

yOut = NextData(:);
schemeDataOut.LastData = NextData;
schemeDataOut.LastY = yOut;
schemeDataOut.B = B;

schemeDataOut = processTopology(schemeDataOut);

if ( saveFlag )
    filename = fullfile(resultDir, ['simplePoints_' num2str(ntimes) '.nii.gz']);
    SaveAnalyze(simplePoints, header, filename, 'Grey');

    ntimes = ntimes+1;
end

return;
