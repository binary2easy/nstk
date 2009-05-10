
function [csfT, wmT, gmT, outlierT] = preProcPriors_4(csfIn, wmIn, gmIn, outlierIn)

temp = [csfIn(:) ; wmIn(:) ; gmIn(:) ; outlierIn(:)];

maxVal = max(temp);

csfIn     = csfIn / maxVal;
wmIn      = wmIn  / maxVal;
gmIn      = gmIn  / maxVal;
outlierIn = outlierIn / maxVal;

minP = 0.02;

csfPresent     = (csfIn > minP);
gmPresent      = (gmIn  > minP);
wmPresent      = (wmIn  > minP);
outlierPresent = (outlierIn > minP);

anyPresent = gmPresent + wmPresent + csfPresent + outlierPresent;

nonePresent = anyPresent < 1;
noneInds    = find(nonePresent);

sumIn = wmIn + gmIn + csfIn + outlierIn ;

csfT     = csfIn ./ sumIn;
gmT      = gmIn  ./ sumIn;
wmT      = wmIn  ./ sumIn;
outlierT = outlierIn ./ sumIn;

temp = zeros(size(noneInds));

gmT(noneInds)      = temp;
wmT(noneInds)      = temp;
csfT(noneInds)     = temp;
outlierT(noneInds) = temp;

return
