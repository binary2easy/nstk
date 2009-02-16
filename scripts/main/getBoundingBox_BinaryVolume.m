function [leftup, rightdown] = getBoundingBox_BinaryVolume(data)

% get the bounding box of vasculature

[i, j, k] = ind2sub(size(data), find(data>0));

leftup = [min(j) min(i) min(k)];

rightdown = [max(j) max(i) max(k)];

leftup = leftup - 10;

rightdown = rightdown + 10;

[ysize, xsize, zsize] = size(data);

if ( leftup(1)<1 )
  leftup(1) = 1;
end

if ( leftup(2)<1 )
  leftup(2) = 1;
end

if ( leftup(3)<1 )
  leftup(3) = 1;
end

if ( rightdown(1)>xsize )
  rightdown(1) = xsize;
end

if ( rightdown(2)>ysize )
  rightdown(2) = ysize;
end

if ( rightdown(3)>zsize )
  rightdown(3) = zsize;
end

return;


