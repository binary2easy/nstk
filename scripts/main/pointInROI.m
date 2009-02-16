function inside = pointInROI(pt, minCorner, maxCorner)

if ( (pt(1) >= minCorner(1)) && (pt(2) >= minCorner(2)) && (pt(3) >= minCorner(3)) && ...
     (pt(1) <= maxCorner(1)) && (pt(2) <= maxCorner(2)) && (pt(3) <=maxCorner(3)))
    inside = true;
else
    inside = false;
end

return