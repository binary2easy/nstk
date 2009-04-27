function [skeletonpoints, skeletonvolume] = thinning3D_filter(shockVolume, tp)
% get the central surfaces for 3D structures

% Skeleton in 3d - 
% Ref. N.Gagvani & D.Silver Tech.Rep.CAIP-TR-216
% Parameter Controlled skeletonization of 3D Objects
%

% http://www.caip.rutgers.edu/~gagvani/skel/

% D = ones(size(shockVolume));
% D(find(shockVolume==1)) = 0; % backgournd 1, object 0

D = double(shockVolume);

D = ~D;
D = double(D);

Dst = bwdist(D,'euclidean'); % Distance Transform (Euclidean) ref. p.6
% Dst = DistanceTransform(D)
% SaveAnalyze(Dst, header, 'Dst.hdr', 'Real');
% SaveAnalyze(D, header, 'D.hdr', 'Real');

DstPos = (Dst > 0);

H = repmat(1/26,[3 3 3]);
H(2,2,2) = 0; % mask 

DFlt = imfilter(Dst,H); % filtered distance, ref. p.8 Note: 3d mean flt not available in matlab

% tp=0.4; % Thinness parameter control tp ref. p.8 
% An high (a low) tp value results in a thinner (thick) skeletron
DSk = (DFlt < (Dst-tp)); % Skeleton , ref. p.9 

skeletonvolume = DSk;
skeletonpoints = find(DSk>0);

% visualize results . see also ref. pp.12-
% Alternative : 
% Flux Driven Medial Surface
% Average Outward Flux via  divergence & gradient (author K. Siddiqi)
% Ref. Sylvain Bouix  , Kaleem Siddiqi , Allen Tanneubaum
% http://sylvain.homelinux.org/~sylvain/research/projects/endoscopy/
% and related papers (e.g. Proc. of 2003 IEEE Com. Soc. Conf. on CVPR)
% [GrDx, GrDy, GrDz] = gradient(Dst); % ref CVPR eq 3
% Flux = divergence(GrDx, GrDy, GrDz);
% Eps=-0.2 % threshold
% Med_Surf = logical((Flux<Eps)) & DstPos ;
% % end alternative 
% 
% % intersect Skeletons calculated according to the 2 methods
% Sk_AND_MS= (Med_Surf & DSk);
% 
% figure
%         subplot(3,2,1), isosurface(D,0), axis equal, view(3)
%         camlight, lighting gouraud, title('3D Object')
%         
%         subplot(3,2,2), isosurface(DSk,0), axis equal, view(3)
%         tit_SK=['3D Skeleton (Tp= ' num2str(tp) ' )']
%         camlight, lighting gouraud, title(tit_SK)
%         
%         subplot(3,2,3), isosurface(Med_Surf,0), axis equal, view(3)
%         tit_MS=['Medial Surface Outward Flux (Eps= ' num2str(Eps) ' )']
%         camlight, lighting gouraud, title(tit_MS)
% 
%         subplot(3,2,4), isosurface(Sk_AND_MS,0), axis equal, view(3)
%         camlight, lighting gouraud, title(' Medial Surf & Skeleton ')
return
       
% use camera toolbar to explore che data (object) and results (skeleton)
% Gianni Schena Univ. Trieste 34127 trieste Italy - schenaATunits.it 


