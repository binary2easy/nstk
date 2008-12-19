
function [neighbourhood, neighbors] = GetNeighbourhood2(data, header, x, y, z, N)
% get the N-neighbourhood of (x, y, z) from a 3D image
% the padding value is -inf

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

halfN = floor(N/2);

neighbourhood = zeros(N, N, N);
neighbors = zeros(N*N*N, 1)-1;

index = 0;
for k = -halfN:halfN
    for j = -halfN:halfN
        for i = -halfN:halfN

            px = x + i; 
            py = y + j; 
            pz = z + k;
            index = index + 1;
            
            if ( pointInROI([px py pz], [1, 1, 1], [xsize ysize zsize]) == true )
                % PA CHANGING XY SUBSCRIPTS.
%                 neighbourhood(i + halfN + 1, j + halfN + 1, k + halfN + 1) = data(py, px, pz);
%                 neighbors(index) = data(py, px, pz);
                neighbourhood(i + halfN + 1, j + halfN + 1, k + halfN + 1) = data(px, py, pz);
                neighbors(index) = data(px, py, pz);
            else
                neighbourhood(i + halfN + 1, j + halfN + 1, k + halfN + 1) = -inf;
            end
        end
    end
end
return