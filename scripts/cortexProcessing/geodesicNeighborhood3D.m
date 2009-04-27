function [GN_inds, GN_subs, cubicVolume] = geodesicNeighborhood3D(i, j, k, B, objectLabel, connectivity, orderNum, ...
                                                                  offsets6, offsets18, offsets26)
% compute the geodesic neighborhood of (i, j, k) with respect to B of order k
% connectivity: 6, 18, 26

shape = size(B);
center_ind = sub2ind(shape, i, j, k);

[NeighborStar_26, NeighborStar_26_Subs] = getNeighborStar(i, j, k, shape, offsets26);
NeighborStar_26_InterSect_X = intersect_topology_onlyInd(NeighborStar_26, B, objectLabel);
 
if ( connectivity == 6 )
  % k = 1;
  [NeighborStar_6, NeighborStar_6_Subs] = getNeighborStar(i, j, k, shape, offsets6);
  GN_inds_k = intersect_topology_onlyInd(NeighborStar_6, B, objectLabel);
    
  GN_inds_temp = [];
  for tt=2:orderNum
    num = length(GN_inds_k);
    for ss = 1:num
      % for every y
      ind_y = GN_inds_k(ss);
      [y_i, y_j, y_k] = ind2sub(shape, ind_y);
      [y_NeighborStar_6, y_NeighborStar_6_Subs] = getNeighborStar(y_i, y_j, y_k, shape, offsets6);
      y_Neighbor_6 = [y_NeighborStar_6; ind_y];
      y_InterSect = intersect(y_Neighbor_6, NeighborStar_26_InterSect_X);
      GN_inds_temp = union(GN_inds_temp, y_InterSect);
    end
    
    GN_inds_k = GN_inds_temp;
    GN_inds_temp = [];
  end
end

if ( connectivity == 18 )
  % k = 1;
  [NeighborStar_18, NeighborStar_18_Subs] = getNeighborStar(i, j, k, shape, offsets18);
  GN_inds_k = intersect_topology_onlyInd(NeighborStar_18, B, objectLabel);
    
  GN_inds_temp = [];
  for tt=2:orderNum

    num = length(GN_inds_k);
    for ss = 1:num
      % for every y
      ind_y = GN_inds_k(ss);
      [y_i, y_j, y_k] = ind2sub(shape, ind_y);
      [y_NeighborStar_18, y_NeighborStar_18_Subs] = getNeighborStar(y_i, y_j, y_k, shape, offsets18);
      y_Neighbor_18 = [y_NeighborStar_18; ind_y];
      y_InterSect = intersect(y_Neighbor_18, NeighborStar_26_InterSect_X);
      GN_inds_temp = union(GN_inds_temp, y_InterSect);
    end
    
    GN_inds_k = GN_inds_temp;
    GN_inds_temp = [];
  end
end

if ( connectivity == 26 )
  % k = 1;
  [NeighborStar_26, NeighborStar_26_Subs] = getNeighborStar(i, j, k, shape, offsets26);
  GN_inds_k = intersect_topology_onlyInd(NeighborStar_26, B, objectLabel);
    
  GN_inds_temp = [];
  for tt=2:orderNum
    num = length(GN_inds_k);
    for ss = 1:num
      % for every y
      ind_y = GN_inds_k(ss);
      [y_i, y_j, y_k] = ind2sub(shape, ind_y);
      [y_NeighborStar_26, y_NeighborStar_26_Subs] = getNeighborStar(y_i, y_j, y_k, shape, offsets26);
      y_Neighbor_26 = [y_NeighborStar_26; ind_y];
      y_InterSect = intersect(y_Neighbor_26, NeighborStar_26_InterSect_X);
      GN_inds_temp = union(GN_inds_temp, y_InterSect);
    end
    GN_inds_k = GN_inds_temp;
    GN_inds_temp = [];
  end
end

GN_inds = GN_inds_k;
num = length(GN_inds);
cubicVolume = zeros(3,3,3);
GN_subs = [];

if ( num>0 )
  [ri, rj, rk] = ind2sub(shape, GN_inds);
  GN_subs = zeros(num, 3);
  GN_subs(:,1) = ri;
  GN_subs(:,2) = rj;
  GN_subs(:,3) = rk;
    
  Center_subs = ones(num, 3);
  Center_subs(:,1) = i;
  Center_subs(:,2) = j;
  Center_subs(:,3) = k;

  %     size(GN_subs)
  %     size(Center_subs)
  currentSubs = GN_subs - Center_subs + 2;
    
  inds = sub2ind([3 3 3], currentSubs(:,1), currentSubs(:,2), currentSubs(:,3));
  cubicVolume(inds) = 1;
end


return;


