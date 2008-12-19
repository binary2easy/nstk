
function [csfT, wmT1, wmT2, cortexT, outlierT] = CreateTemplates_5classes_Gaussian(header, csfSeg, wmSeg1, wmSeg2, cortexSeg, outlierSeg, ...
                    sigmaCSF, sigmaWM1, sigmaWM2, sigmaCortex, sigmaOutlier,...
                    halfwidthCsf, halfwidthWm1, halfwidthWm2, halfwidthCortex, halfwidthOutlier)
                
disp('create templates ...');
% create probability templates

csfT = single(csfSeg);
G_csfT = gaussianFilter(csfT, header, sigmaCSF, sigmaCSF, sigmaCSF, halfwidthCsf, 'Real');
clear csfSeg

cortexT = single(cortexSeg);
G_cortexT = gaussianFilter(cortexT, header, sigmaCortex, sigmaCortex, sigmaCortex, halfwidthCortex, 'Real');
clear cortexSeg

wmT1 = single(wmSeg1);
G_wmT1 = gaussianFilter(wmT1, header, sigmaWM1, sigmaWM1, sigmaWM1, halfwidthWm1, 'Real');
clear wmSeg1

wmT2 = single(wmSeg2);
G_wmT2 = gaussianFilter(wmT2, header, sigmaWM2, sigmaWM2, sigmaWM2, halfwidthWm2, 'Real');
clear wmSeg2

outlierT = single(outlierSeg);
G_outlierT = gaussianFilter(outlierT, header, sigmaOutlier, sigmaOutlier, sigmaOutlier, halfwidthOutlier, 'Real');
clear outlierSeg

% clear csfSeg wmSeg1 wmSeg2 cortexSeg outlierSeg


csfflag = 0;
wm1flag = 0;
wm2flag = 0;
cortexflag = 0;
outlierflag = 0;

minP = 0.02;

for k = 1:header.zsize
    for j = 1:header.ysize
        for i = 1:header.xsize
            
            p_csf = G_csfT(j, i, k);
            p_wm1 = G_wmT1(j, i, k);
            p_wm2 = G_wmT2(j, i, k);
            p_cortex = G_cortexT(j, i, k);
            p_outlier = G_outlierT(j, i, k);

            if ( G_csfT(j, i, k)>minP )
                csfflag = 1;
            end
            
            if ( G_wmT1(j, i, k)>minP )
                wm1flag = 1;
            end
            
            if ( G_wmT2(j, i, k)>minP )
                wm2flag = 1;
            end   
            
            if ( G_cortexT(j, i, k)>minP )
                cortexflag = 1;
            end
            
            if ( G_outlierT(j, i, k)>minP )
                outlierflag = 1;
            end
            
            if ( csfflag + wm1flag + wm2flag + cortexflag + outlierflag == 0 )
                continue;
            end
            
            csfT(j, i, k) = p_csf/(p_csf+p_wm1+p_wm2+p_cortex+p_outlier);
            wmT1(j, i, k) = p_wm1/(p_csf+p_wm1+p_wm2+p_cortex+p_outlier);
            wmT2(j, i, k) = p_wm2/(p_csf+p_wm1+p_wm2+p_cortex+p_outlier);
            cortexT(j, i, k) = p_cortex/(p_csf+p_wm1+p_wm2+p_cortex+p_outlier);
            outlierT(j, i, k) = p_outlier/(p_csf+p_wm1+p_wm2+p_cortex+p_outlier);
            
%             csfT(j, i, k) = 0.33;
%             wmT(j, i, k) = 0.33;
%             cortexT(j, i, k) = 0.33;
            
            csfflag = 0;
            wm1flag = 0;
            wm2flag = 0;
            cortexflag = 0;
            outlierflag = 0;
        end
    end
end
return;
