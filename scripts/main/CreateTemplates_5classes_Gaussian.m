
function [csfT, wmT1, wmT2, gmT, outlierT] = CreateTemplates_5classes_Gaussian(header, ...
  csfSeg, wmSeg1, wmSeg2, gmSeg, outlierSeg, ...
  sigmaCSF, sigmaWM1, sigmaWM2, sigmaCortex, sigmaOutlier)
                
% Create probability templates by blurring hard label maps.

disp('Create templates by blurring k-means result (5 classes).');

csfT     = single(csfSeg);
gmT      = single(gmSeg);
wmT1     = single(wmSeg1);
wmT2     = single(wmSeg2);
outlierT = single(outlierSeg);

G_csfT     = gaussianFilter(csfT, header, sigmaCSF, sigmaCSF, sigmaCSF, 'Real', appDir);
G_gmT      = gaussianFilter(gmT, header, sigmaCortex, sigmaCortex, sigmaCortex, 'Real', appDir);
G_wmT1     = gaussianFilter(wmT1, header, sigmaWM1, sigmaWM1, sigmaWM1, 'Real', appDir);
G_wmT2     = gaussianFilter(wmT2, header, sigmaWM2, sigmaWM2, sigmaWM2, 'Real', appDir);
G_outlierT = gaussianFilter(outlierT, header, sigmaOutlier, sigmaOutlier, sigmaOutlier, 'Real', appDir);


minP = 0.02;

csfPresent     = (G_csfT > minP);
gmPresent      = (G_gmT > minP);
wm1Present     = (G_wmT1 > minP);
wm2Present     = (G_wmT2 > minP);
outlierPresent = (G_outlierT > minP);

anyPresent = gmPresent + wm1Present + wm2Present + csfPresent + outlierPresent;

nonePresent = anyPresent < 1;
noneInds    = find(nonePresent);

G_sum = G_wmT1 + G_wmT2 + G_gmT + G_csfT + G_outlierT ;

csfT     = G_csfT ./ G_sum;
gmT      = G_gmT ./ G_sum;
wmT1     = G_wmT1 ./ G_sum;
wmT2     = G_wmT2 ./ G_sum;
outlierT = G_outlierT ./ G_sum;

temp = zeros(size(noneInds));

gmT(noneInds)      = temp;
wmT1(noneInds)      = temp;
wmT2(noneInds)      = temp;
csfT(noneInds)     = temp;
outlierT(noneInds) = temp;

return
