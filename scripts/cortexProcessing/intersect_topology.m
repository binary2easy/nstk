
function [InterResult, cubicVolume] = intersect_topology(NeighborStar, NeighborStar_Subs, ...
                                                            i, j, k, B, objectLabel)
% compute the intersection between B and NeighborStar
% NeighborStar: N*1 index vector
% B: 3D phi indicator array
% InterResult: M*1 index vector
% cubicVolume: 3*3*3 array with the voxels within the intersection are labeled 1;

B_values = B(NeighborStar);
index = find(B_values==objectLabel);
cubicVolume = zeros(3,3,3);
num = length(index);

if ( num >0 )
    InterResult = NeighborStar(index);
    InterResult_subs = NeighborStar_Subs(index, :);
    
    Center_subs = ones(num, 3);
    Center_subs(:,1) = i;
    Center_subs(:,2) = j;
    Center_subs(:,3) = k;
    
    currentSubs = InterResult_subs - Center_subs + 2;
    inds = sub2ind([3 3 3], currentSubs(:,1), currentSubs(:,2), currentSubs(:,3));
    cubicVolume = zeros(3,3,3);
    cubicVolume(inds) = 1;
else
    InterResult = [];
end
return;
