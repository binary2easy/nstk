function [roiData, newHeader] = getROI(data, header, minCorner, maxCorner)

% NB: THIS FUNCTION CAN ONLY HANDLE SYMMETRICALLY PLACED ROI'S WITHIN THE
% IMAGE VOLUME.  IF NON-SYMMETRICAL ONES ARE USED, THE ORIGIN MAY BE
% MISPLACED AFTERWARDS.

newHeader = header;

xsize = maxCorner(1) - minCorner(1) + 1;
ysize = maxCorner(2) - minCorner(2) + 1;
zsize = maxCorner(3) - minCorner(3) + 1;

newHeader.xsize = xsize;
newHeader.ysize = ysize;
newHeader.zsize = zsize;

roiData = data(minCorner(1):maxCorner(1), minCorner(2):maxCorner(2), minCorner(3):maxCorner(3));

qoff_x = newHeader.nii.hdr.hist.qoffset_x;
qoff_y = newHeader.nii.hdr.hist.qoffset_y;
qoff_z = newHeader.nii.hdr.hist.qoffset_z;

qoff_x = qoff_x + 0.5 * (header.xsize - newHeader.xsize) * header.xvoxelsize;
qoff_y = qoff_y + 0.5 * (header.ysize - newHeader.ysize) * header.yvoxelsize;
qoff_z = qoff_z + 0.5 * (header.zsize - newHeader.zsize) * header.zvoxelsize;

newHeader.nii.original.hdr.hist.qoffset_x = qoff_x;
newHeader.nii.original.hdr.hist.qoffset_y = qoff_y;
newHeader.nii.original.hdr.hist.qoffset_z = qoff_z;

newHeader.nii.hdr.hist.qoffset_x = qoff_x;
newHeader.nii.hdr.hist.qoffset_y = qoff_y;
newHeader.nii.hdr.hist.qoffset_z = qoff_z;

newdims = [newHeader.xsize newHeader.ysize newHeader.zsize];

newHeader.nii.hdr.dime.dim(2:4) = newdims;
newHeader.nii.original.hdr.dime.dim(2:4) = newdims;

return;


