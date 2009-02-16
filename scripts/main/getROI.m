
function [ROI, headerROI]=getROI(data, header, leftup,rightdown)

headerROI=header;
xsize=rightdown(1)-leftup(1)+1;
ysize=rightdown(2)-leftup(2)+1;
zsize=rightdown(3)-leftup(3)+1;
headerROI.xsize=xsize;
headerROI.ysize=ysize;
headerROI.zsize=zsize;

ROI=zeros(headerROI.ysize, headerROI.xsize, headerROI.zsize);

ROI=data(leftup(2):rightdown(2), leftup(1):rightdown(1), leftup(3):rightdown(3));

return;
