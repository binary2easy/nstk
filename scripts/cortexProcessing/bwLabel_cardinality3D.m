
function T = bwLabel_cardinality3D(cubicVolume, connectivity)
% compute the topology number by counting the number of connected components (CC)
% adjacentFlag: 1 the effective CC must be adjacent to the center point; 
% 0 the effective CC can not be adjacent to the center point

ind = find(cubicVolume>0);
num = length(ind);
T = 0;

if ( num==0 )
  return;
end

[label, num] = bwlabeln(cubicVolume, connectivity);
T = num;

return;