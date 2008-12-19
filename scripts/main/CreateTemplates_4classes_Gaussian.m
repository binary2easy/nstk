
function [csfT, wmT, gmT, outlierT] = CreateTemplates_4classes_Gaussian(header, csfSeg, wmSeg, gmSeg, outlierSeg, ...
                    sigmaCSF, sigmaWM, sigmaGM, sigmaOutlier)

% Previous signature:                
% function [csfT, wmT, cortexT, outlierT] = CreateTemplates_4classes_Gaussian(header, csfSeg, wmSeg, gmSeg, outlierSeg, ...
%                     sigmaCSF, sigmaWM, sigmaGM, sigmaOutlier, halfwidthCsf, halfwidthWm, halfwidthCortex, halfwidthOutlier)

disp('create templates ...');

% Create probability templates by blurring hard label maps.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Older slower code:
% csfflag = 0;
% wmflag = 0;
% cortexflag = 0;
% outlierflag = 0;
% 
% tic;
% 
% for k = 1:header.zsize
%     for j = 1:header.ysize
%         for i = 1:header.xsize
%             
%             csfflag     = 0;
%             wmflag      = 0;
%             cortexflag  = 0;
%             outlierflag = 0;
%             
%             p_csf     = G_csfT(i, j, k);
%             p_wm      = G_wmT(i, j, k);
%             p_cortex  = G_cortexT(i, j, k);
%             p_outlier = G_outlierT(i, j, k);
% 
%             if (G_csfT(i, j, k) > minP)
%                 csfflag = 1;
%             end
%             
%             if (G_wmT(i, j, k) > minP)
%                 wmflag = 1;
%             end
%             
%             if (G_cortexT(i, j, k) > minP)
%                 cortexflag = 1;
%             end
%             
%             if (G_outlierT(i, j, k) > minP)
%                 outlierflag = 1;
%             end
%             
%             if (csfflag + wmflag + cortexflag + outlierflag == 0)
%                 continue;
%             end
%             
%             sum = p_csf + p_wm + p_cortex + p_outlier;
%             
%             csfT(i, j, k)     = p_csf / sum;
%             wmT(i, j, k)      = p_wm / sum;
%             cortexT(i, j, k)  = p_cortex / sum;
%             outlierT(i, j, k) = p_outlier / sum;
%             
% %             csfT(i, j, k) = 0.33;
% %             wmT(i, j, k) = 0.33;
% %             cortexT(i, j, k) = 0.33;
% 
%         end
%     end
% end
% 
% t1 = toc;
% 
