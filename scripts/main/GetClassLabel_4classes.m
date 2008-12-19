
function [csflabel, gmlabel, wmlabel, outlierlabel] = GetClassLabel_4classes(imagedata, SegResult)

% mean intensities

meanI = zeros(4,1);

for i = 1:4
    
    p = imagedata(find(SegResult==i));
    meanI(i) = mean(p);
    
end

ind = find(meanI==min(meanI));
outlierlabel = ind;
meanI(ind) = -1;

tempI = meanI(find(meanI~=-1));
ind = find(meanI==min(tempI));
gmlabel = ind;
meanI(ind) = -1;

tempI = meanI(find(meanI~=-1));
ind = find(meanI==min(tempI));
wmlabel = ind;
meanI(ind) = -1;

ind = find(meanI==max(meanI));
csflabel = ind;
meanI(ind) = -1;

return;


