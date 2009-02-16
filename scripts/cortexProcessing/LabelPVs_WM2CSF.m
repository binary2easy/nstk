
function mix = LabelPVs_WM2CSF(mix, segResult, LabelSeg, csflabel, cortexlabel, wmlabel, pvlabel, VolumeThres)
% detect wm PVs and adjust the prior...

% get the small connected components

[label3D, largestComponent, segResult] = RegionVolumeFilter_cortex(segResult, mix.header, 20, wmlabel);

suspectWMPVs = zeros(size(segResult), 'uint32');
suspectWMPVs(find(segResult == 10)) = 1;

clear label3D largestComponent

% get the suspected wmPVs
% Previously this line did the following redundant step.
%    suspectWMPVs(find(LabelSeg==pvlabel)) == 0;
suspectWMPVs(find(LabelSeg == pvlabel)) = 0;

% SaveAnalyze(uint32(suspectWMPVs), header, 'suspectWMPVs.hdr', 'Grey');

indexInPrior = GetPVs_WM2CSF(mix, suspectWMPVs, segResult, LabelSeg, csflabel, cortexlabel, pvlabel, VolumeThres);
% adjust the priors
% data = GetDatafromLabel(mix, indexInPrior);
% SaveAnalyze(uint32(data), mix.header, 'ddata.hdr', 'Grey');
mix = ChangePrior_WM2CSF(mix, indexInPrior, LabelSeg, pvlabel);

return;