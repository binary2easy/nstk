
function [NeighborStar, NeighborStar_Subs] = getNeighborStar(i, j, k, shape, offsets)

% get the index of voxels in the neighbor star centered at (i, j, k)
% neighborNum: 6, 18, 26

num = size(offsets, 1);
NeighborStar_Subs = ones(num, 3);

NeighborStar_Subs(:, 1) = i;
NeighborStar_Subs(:, 2) = j;
NeighborStar_Subs(:, 3) = k;

NeighborStar_Subs = NeighborStar_Subs + offsets;
NeighborStar = sub2ind(shape, NeighborStar_Subs(:,1), NeighborStar_Subs(:,2), NeighborStar_Subs(:,3));

return;