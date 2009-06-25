
function segResult = Rectify_NonBrainNoise(segResult, csflabel, cortexlabel, wmlabel, nonbrainlabel, header)

% get the small connected components

[label3D, largestComponent, segResult] = RegionVolumeFilter_cortex(segResult, header, nonbrainlabel);

suspectWMPVs = zeros(size(segResult), 'uint32');
suspectWMPVs(segResult==10) = 1;

clear label3D largestComponent

segResult = GetPVs_RectifyNonBrain(suspectWMPVs, segResult, csflabel, cortexlabel, wmlabel, header);

return;