
function [nonBrain, largestComponent, labelvolume] = RegionVolumeFilter_cortex(labelvolume, header, nonBrainLabel)

xsize=header.xsize;
ysize=header.ysize;
zsize=header.zsize;

nonBrain = zeros(size(labelvolume), 'uint8');

num = length(nonBrainLabel);

for i = 1:num
    nonBrain(labelvolume == nonBrainLabel(i)) = 1;
end

% Find separate connected components (image proc. toolbox).  Each one is
% assigned a different label. Using 6-neighbourhood.
[labels, num] = bwlabeln(nonBrain, 6);

volumes=zeros(num,1);

total = xsize*ysize*zsize;

for i = 1:num
  temp = labels == i;
  volumes(i) = sum(temp(:));
end

[largest, index] = max(volumes);

availableVD = largest * 0.08;

largestComponent = uint8(zeros(size(labels)));
largestComponent(labels == index) = 1;

for i = 1:total
    if ((labels(i) > 0) && (volumes(labels(i)) < availableVD))
        nonBrain(i) = 0;
    end
end


num = length(nonBrainLabel);
for i = 1:num
    index = find(labelvolume == nonBrainLabel(i));
    labelvolume(index(:)) = 10;
end

labelvolume(nonBrain == 1) = nonBrainLabel(1);

return;

