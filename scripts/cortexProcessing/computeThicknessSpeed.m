
function thicknessSpeed = computeThicknessSpeed(Internal_SDF, External_SDF, minThickness, maxThickness, voxelsize)

% compute the thickness speed
% F = exp(minThickness-TH)-1; if 0<TH<=minThickness
% F = 0; otherwise

Thickness = Internal_SDF - External_SDF;
Thickness = Thickness .* voxelsize;

thicknessSpeed = zeros(size(Internal_SDF));

index = find((Thickness<=minThickness) & (Thickness>=0));

thicknessSpeed(index(:)) = exp(minThickness-Thickness(index(:))) - 1;

thicknessSpeed(find(thicknessSpeed>0.5)) = 0.5;

return;