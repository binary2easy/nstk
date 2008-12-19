
function [nonBrain, largestComponent, labelvolume] = RegionVolumeFilter_cortex(labelvolume, header, volumeThreshold, nonBrainLabel)

xsize=header.xsize;
ysize=header.ysize;
zsize=header.zsize;

nonBrain = zeros(size(labelvolume), 'uint8');

num = length(nonBrainLabel);

for i = 1:num
    nonBrain(find(labelvolume==nonBrainLabel(i))) = 1;
end

largestComponent = zeros(size(nonBrain),'uint8');

% Find separate connected components (image proc. toolbox).  Each one is
% assigned a different label. Using 6-neighbourhood.
[l, num] = bwlabeln(nonBrain, 6);

volumes=zeros(num,1);
total = xsize*ysize*zsize;
for i=1:total
    if (l(i)>0)
        volumes(l(i)) = volumes(l(i)) + 1;
    end
end

vd = sort(volumes, 'descend');
% only 6 biggest will be used;
[largest, index] = max(volumes);

availableVD = largest * 0.08;

for i=1:total
    if ((l(i) > 0) && (volumes(l(i)) >= largest))
        largestComponent(i) = 1;
    end
end

for i = 1:total
    if ((l(i) > 0) && (volumes(l(i)) < availableVD))
        nonBrain(i) = 0;
    end
end

num = length(nonBrainLabel);
for i = 1:num
    index = find(labelvolume == nonBrainLabel(i));
    labelvolume(index(:)) = 10;
end
labelvolume(find(nonBrain == 1)) = nonBrainLabel(1);
return;