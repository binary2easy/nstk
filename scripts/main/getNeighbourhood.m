
function neighbourhood = GetNeighbourhood(data, header, x, y, z, N)
% get the N-neighbourhood of (x, y, z) from a 3D image
% the padding value is -inf

if ( N==1 )
   
    neighbourhood = data(y, x, z);
    return;
end

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;
halfN = floor(N/2);
neighbourhood = zeros(N, N, N);
for k = -halfN:halfN
    for j = -halfN:halfN
        for i = -halfN:halfN
            px = x + i; py = y + j; pz = z + k;
            if ( pointInROI([px py pz], [1, 1, 1], [xsize ysize zsize]) == true )
                neighbourhood(i+halfN+1, j+halfN+1, k+halfN+1) = data(py, px, pz);
            else
                neighbourhood(i+halfN+1, j+halfN+1, k+halfN+1) = -inf;
            end
        end
    end
end
return