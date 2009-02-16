
function [ROI, headerROI] = AddExtraWidth(data, header, extraWidth)
% add some '0' at each dimension to prevent the errors

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

new_xsize = xsize + 2*extraWidth;
new_ysize = ysize + 2*extraWidth;
new_zsize = zsize + 2*extraWidth;

ROI = zeros([new_ysize new_xsize new_zsize]);

ROI(extraWidth+1:ysize+extraWidth, extraWidth+1:xsize+extraWidth, extraWidth+1:zsize+extraWidth) = data;

headerROI = header;
headerROI.xsize = new_xsize;
headerROI.ysize = new_ysize;
headerROI.zsize = new_zsize;

return;

