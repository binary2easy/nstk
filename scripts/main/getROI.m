function [roiData, roiHeader] = getROI(data, header, minCorner, maxCorner)

roiHeader = header;

xsize = maxCorner(1) - minCorner(1) + 1;
ysize = maxCorner(2) - minCorner(2) + 1;
zsize = maxCorner(3) - minCorner(3) + 1;

roiHeader.xsize = xsize;
roiHeader.ysize = ysize;
roiHeader.zsize = zsize;

roiData = data(minCorner(1):maxCorner(1), minCorner(2):maxCorner(2), minCorner(3):maxCorner(3));

% PROBLEM: IF NON-EQUAL NOS OF ROWS/COLS/SLICES ARE DISCARDED FROM EITHER
% END, THE ORIGIN INFORMATION IS OUT OF DATE AND NEEDS TO BE RECALCULATED.

return;
