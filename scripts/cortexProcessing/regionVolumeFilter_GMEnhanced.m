
function [label3D, largestComponent, labelvolume] = regionVolumeFilter_GMEnhanced(labelvolume, header, volumeThreshold, label)

xsize=header.xsize;
ysize=header.ysize;
zsize=header.zsize;

label3D = zeros(size(labelvolume), 'uint8');

num = length(label);

for i = 1:num
  label3D = (labelvolume == label(i));
end

largestComponent = zeros(size(label3D),'uint8');

[l,num] = bwlabeln(label3D,6);

volumes = zeros(num,1);
total = xsize*ysize*zsize;

for i=1:total
  if (l(i) > 0)
    volumes(l(i)) = volumes(l(i)) + 1;
  end
end

vd = sort(volumes, 'descend');

% only 6 biggest will be used;
[largest,index] = max(volumes);

availableVD = largest * 0.01;

for i=1:total
  if ( (l(i) > 0) && (volumes(l(i)) >= largest) )
    largestComponent(i) = 1;
  end
end

for i=1:total
  if ( (l(i)>0) && (volumes(l(i)) < availableVD) )
    label3D(i) = 0;
  end
end

num = length(label);
for i = 1:num
  index = find(labelvolume == label(i));
  labelvolume(index(:)) = 10;
end

labelvolume(find(label3D == 1)) = label(1);

return;