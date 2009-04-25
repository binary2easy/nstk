function neighbours = getNeighbourhood2_6neighbors(data, header, offsets, x, y, z)

% Get the 6-neighbourhood of (x, y, z) from a 3D image
% the padding value is -inf

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

neighbours = zeros(1, 6);

for pp = 1:6
    
  px = x + offsets(pp, 1);
  py = y + offsets(pp, 2);
  pz = z + offsets(pp, 3);

  if pointInROI([px py pz], [1, 1, 1], [xsize ysize zsize])
    neighbours(pp) = data(px, py, pz);
  else
    neighbours(pp) = -inf;
  end
  
end

return