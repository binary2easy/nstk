
function [csflabel, gmlabel, wmlabel1, wmlabel2, outlierlabel] = GetClassLabel_5classes(imagedata, SegResult)

% mean intensities

meanI = zeros(5,1);

for i = 1:5
    p = imagedata(find(SegResult == i));
    meanI(i) = mean(p);
end

ind = find(meanI == min(meanI));
outlierlabel = ind;
meanI(ind) = -1;

tempI = meanI(find(meanI ~= -1));
ind = find(meanI == min(tempI));
gmlabel = ind;
meanI(ind) = -1;

tempI = meanI(find(meanI ~= -1));
ind = find(meanI == min(tempI));
wmlabel1 = ind;
meanI(ind) = -1;

tempI = meanI(find(meanI ~= -1));
ind = find(meanI == min(tempI));
wmlabel2 = ind;
meanI(ind) = -1;

ind = find(meanI == max(meanI));
csflabel = ind;
meanI(ind) = -1;

return;


