
function neighbors = GetNeighbourhood2_6neighbors(data, header, offsets, x, y, z)
% get the 6-neighbourhood of (x, y, z) from a 3D image
% the padding value is -inf

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;
neighbors = zeros(1, 6);
index = 0;
for pp = 1:6
    px = x + offsets(pp, 1); py = y + offsets(pp, 2); pz = z + offsets(pp, 3);
    index = index + 1;
    if ( pointInROI([px py pz], [1, 1, 1], [xsize ysize zsize]) == true )
        neighbors(pp) = data(py, px, pz);
    else
        neighbors(pp) = -inf;
    end
end
return