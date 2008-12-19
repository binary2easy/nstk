
function inflag = pointInROI(point, leftup, rightdown)

if ( (point(1)>=leftup(1)) & (point(2)>=leftup(2)) & (point(3)>=leftup(3))...
        & (point(1)<=rightdown(1)) & (point(2)<=rightdown(2)) & (point(3)<=rightdown(3)) )
    inflag = true;
else
    inflag = false;
end
return