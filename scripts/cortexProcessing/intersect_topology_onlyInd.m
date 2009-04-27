
function InterResult = InterSect_Topology_onlyInd(NeighborStar, B, objectLabel)
% compute the intersection between B and NeighborStar
% NeighborStar: N*1 index vector
% B: 3D phi indicator array
% InterResult: M*1 index vector

B_values = B(NeighborStar);
index = find(B_values==objectLabel);
num = length(index);

if ( num >0 )
    InterResult = NeighborStar(index);
else
    InterResult = [];
end
return;
