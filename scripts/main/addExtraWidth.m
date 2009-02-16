
function [bigData, bigHeader] = addExtraWidth(data, header, extraWidth)

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

bigHeader = header;

bigHeader.xsize = new_xsize;
bigHeader.ysize = new_ysize;
bigHeader.zsize = new_zsize;

newdims = [new_xsize new_ysize new_zsize];

bigHeader.nii.hdr.dime.dim(2:4) = newdims;
bigHeader.nii.original.hdr.dime.dim(2:4) = newdims;

return;

