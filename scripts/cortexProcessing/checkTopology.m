
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

B = schemeDataIn.B; % B will be improved at every iteration

LastData = schemeDataIn.LastData;
tempData = reshape(yIn, schemeDataIn.shape);
NextData = zeros(size(tempData));

connectivityObject = schemeDataIn.connectivityObject;
connectivityBackground = schemeDataIn.connectivityBackground;

header = schemeDataIn.header;

resultDir = schemeDataIn.resultDir;
saveFlag = schemeDataIn.saveFlag;

tempSign = sign(tempData);
index = find(tempSign==0);

if ( isempty(index) == 0 )
  tempSign(index) = 1;
end

LastSign = sign(LastData);
index = find(LastSign==0);

if ( isempty(index) == 0 )
  LastSign(index) = 1;
end

% find all voxels that the signs have not been changed
% B keeps unchanged
index = find(tempSign==LastSign);
NextData(index) = tempData(index);

% for every voxel whose sign has changed,
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

[NeighborStar_6, NeighborStar_6_Subs] = getNeighborStar(2, 2, 2, [3 3 3], offsets6);

Cubic_6 = [NeighborStar_6; 14]; % center point

offsets18 =  [0    -1    -1
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
   
[NeighborStar_18, NeighborStar_18_Subs] = getNeighborStar(2, 2, 2, [3 3 3], offsets18);

Cubic_18 = [NeighborStar_18; 14]; % center point

offsets26 =  [-1    -1    -1
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
   
[NeighborStar_26, NeighborStar_26_Subs] = getNeighborStar(2, 2, 2, [3 3 3], offsets26);

Cubic_26 = [NeighborStar_26; 14]; % center point

% [T_object, T_backgournd] = ComputeTopologicalNumber(index2, B, connectivityObject, connectivityBackground);

if ( saveFlag )
  global ntimes
  disp(['ntimes = ' num2str(ntimes)]);

  simplePoints = zeros(size(B), 'uint32');
  simplePoints(find(B==1)) = 80;
  filename = fullfile(resultDir, ['B_' num2str(ntimes) '.nii.gz']);
  SaveAnalyze(simplePoints, header, filename, 'Grey');
end

simplePoints = zeros(size(B), 'uint32');
simplePoints(find(B==1)) = 64;


value = 0;
shape = size(B);
for tt = 1:num
  [i, j, k] = ind2sub(schemeDataOut.shape, index2(tt));
    
  %======================================================================
  
  
  if ( (connectivityObject==26) && (connectivityBackground==6) )
        
    [NeighborStar_26, NeighborStar_26_Subs] = getNeighborStar(i, j, k, shape, offsets26);
    
    [InterResult, cubicVolume] = intersect_topology(NeighborStar_26, NeighborStar_26_Subs, i, j, k, B, 1); % object
    
    T_object = bwLabel_cardinality3D(cubicVolume, connectivityObject);

    [NeighborStar_18, NeighborStar_18_Subs] = getNeighborStar(i, j, k, shape, offsets18);
    
    [InterResult, cubicVolume] = intersect_topology(NeighborStar_18, NeighborStar_18_Subs, i, j, k, B, 0); % object
        
    T_backgournd = bwLabel_cardinality(cubicVolume, connectivityBackground, 1, Cubic_6, Cubic_18, Cubic_26);
  end

  if ( (connectivityObject==18) && (connectivityBackground==6) )
    % object, 18-connectivity
    [GN_inds, GN_subs, cubicVolume] = geodesicNeighborhood3D(i, j, k, B, 1, connectivityObject, 2, offsets6, offsets18, offsets26);
    
    
    %     T_object = bwLabel_cardinality(cubicVolume, connectivityObject, 0, Cubic_6, Cubic_18, Cubic_26);
    T_object = bwLabel_cardinality3D(cubicVolume, connectivityObject);

    % background, 6+ connectivity
    [GN_inds, GN_subs, cubicVolume] = geodesicNeighborhood3D(i, j, k, B, 0, connectivityBackground, 3, offsets6, offsets18, offsets26);
    %     T_backgournd = bwLabel_cardinality(cubicVolume, connectivityBackground, 0, Cubic_6, Cubic_18, Cubic_26);
    T_backgournd = bwLabel_cardinality3D(cubicVolume, connectivityBackground);
  end
  
  
  %======================================================================
  %     [T_object, T_backgournd] = ComputeTopologicalNumber_singlePoint(i, j, k, B, ...
  %                         connectivityObject, connectivityBackground, ...
  %                         offsets6, Cubic_6, offsets18, Cubic_18, offsets26, Cubic_26);
  
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
