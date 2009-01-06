
function [csfT, wmT, gmT, outlierT] = CreateTemplates_4classes_Gaussian(header, csfSeg, wmSeg, gmSeg, outlierSeg, ...
                    sigmaCSF, sigmaWM, sigmaGM, sigmaOutlier)

% Create probability templates by blurring hard label maps.

disp('Create templates by blurring k-means result (4 classes).');

csfT     = single(csfSeg);
gmT      = single(gmSeg);
wmT      = single(wmSeg);
outlierT = single(outlierSeg);

G_csfT     = gaussianFilter(csfT, header, sigmaCSF, sigmaCSF, sigmaCSF, 'Real');
G_gmT      = gaussianFilter(gmT, header, sigmaGM, sigmaGM, sigmaGM, 'Real');
G_wmT      = gaussianFilter(wmT, header, sigmaWM, sigmaWM, sigmaWM, 'Real');
G_outlierT = gaussianFilter(outlierT, header, sigmaOutlier, sigmaOutlier, sigmaOutlier, 'Real');

minP = 0.02;

csfPresent     = (G_csfT > minP);
gmPresent      = (G_gmT > minP);
wmPresent      = (G_wmT > minP);
outlierPresent = (G_outlierT > minP);

anyPresent = gmPresent + wmPresent + csfPresent + outlierPresent;

nonePresent = anyPresent < 1;
noneInds    = find(nonePresent);

G_sum = G_wmT + G_gmT + G_csfT + G_outlierT ;

csfT     = G_csfT ./ G_sum;
gmT      = G_gmT ./ G_sum;
wmT      = G_wmT ./ G_sum;
outlierT = G_outlierT ./ G_sum;

temp = zeros(size(noneInds));

gmT(noneInds)      = temp;
wmT(noneInds)      = temp;
csfT(noneInds)     = temp;
outlierT(noneInds) = temp;

return;
