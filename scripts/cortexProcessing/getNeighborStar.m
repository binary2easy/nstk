function [nstar_inds, nstar_subs] = getNeighborStar(i, j, k, dims, offsets)

% Get the indices of voxels in a neighbor star centered at (i, j, k).
% The indices are calculated assuming the voxel is in an image of size dims.
% There can be 6, 18 or 26 neighbours.

num = size(offsets, 1);
nstar_subs = ones(num, 3);

nstar_subs(:, 1) = i;
nstar_subs(:, 2) = j;
nstar_subs(:, 3) = k;

nstar_subs = nstar_subs + offsets;
nstar_inds = sub2ind(dims, nstar_subs(:,1), nstar_subs(:,2), nstar_subs(:,3));

return;