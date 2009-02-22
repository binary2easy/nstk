
function [bigData, newHeader] = addExtraWidth(data, header, extraWidth)

% Add some zeros at each boundary to prevent the errors

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

new_xsize = xsize + 2 * extraWidth;
new_ysize = ysize + 2 * extraWidth;
new_zsize = zsize + 2 * extraWidth;

bigData = zeros([new_xsize new_ysize new_zsize]);

startRange = extraWidth + 1;

xrange = startRange:xsize+extraWidth;
yrange = startRange:ysize+extraWidth;
zrange = startRange:zsize+extraWidth;

bigData(xrange, yrange, zrange) = data;

newHeader = header;

newHeader.xsize = new_xsize;
newHeader.ysize = new_ysize;
newHeader.zsize = new_zsize;

newdims = [new_xsize new_ysize new_zsize];

newHeader.nii.hdr.dime.dim(2:4) = newdims;
newHeader.nii.original.hdr.dime.dim(2:4) = newdims;


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


return;

