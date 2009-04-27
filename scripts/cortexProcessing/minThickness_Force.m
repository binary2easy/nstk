
function [ yOut, schemeDataOut ] = minThickness_Force(t, yIn, schemeDataIn)
% schemeDataIn.data0
% schemeDataIn.minThickness
% schemeDataIn.maxThickness
% schemeDataIn.voxelsize

disp(['current time is ' num2str(t)]);
disp(['minThickness Force ...']);

yOut = yIn;
schemeDataOut = schemeDataIn;

minThickness = schemeDataIn.minThickness;
maxThickness = schemeDataIn.maxThickness;
voxelsize = schemeDataIn.voxelsize;

External_SDF = reshape(yIn, schemeDataIn.shape);
thicknessSpeed = computeThicknessSpeed(schemeDataIn.data0, External_SDF, minThickness, maxThickness, voxelsize);

schemeDataOut.innerData{3}.speed = thicknessSpeed;
return;
