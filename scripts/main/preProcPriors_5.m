
function [csfT, wmT1, wmT2, gmT, outlierT] = preProcPriors_5(csfIn, wmIn1, wmIn2, gmIn, outlierIn)

temp = [csfIn(:) ; wmIn1(:) ; wmIn2(:) ; gmIn(:) ; outlierIn(:)];

maxVal = max(temp);

csfIn     = csfIn / maxVal;
wmIn1     = wmIn1 / maxVal;
wmIn2     = wmIn2 / maxVal;
gmIn      = gmIn  / maxVal;
outlierIn = outlierIn / maxVal;


minP = 0.02;

csfPresent     = (csfIn > minP);
gmPresent      = (gmIn > minP);
wm1Present     = (wmIn1 > minP);
wm2Present     = (wmIn2 > minP);
outlierPresent = (outlierIn > minP);

anyPresent = gmPresent + wm1Present + wm2Present + csfPresent + outlierPresent;

nonePresent = anyPresent < 1;
noneInds    = find(nonePresent);

sumIn = wmIn1 + wmIn2 + gmIn + csfIn + outlierIn ;

csfT     = csfIn ./ sumIn;
gmT      = gmIn ./ sumIn;
wmT1     = wmIn1 ./ sumIn;
wmT2     = wmIn2 ./ sumIn;
outlierT = outlierIn ./ sumIn;

temp = zeros(size(noneInds));

gmT(noneInds)      = temp;
wmT1(noneInds)     = temp;
wmT2(noneInds)     = temp;
csfT(noneInds)     = temp;
outlierT(noneInds) = temp;

return
