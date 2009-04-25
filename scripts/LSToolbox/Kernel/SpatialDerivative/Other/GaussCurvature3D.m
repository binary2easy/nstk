function [ curvature, gradMag ] = GaussCurvature3D(grid, data)
% GaussCurvature3D: second order centered difference approx of the gauss curvature.
% Only for 3D case
%   [ curvature, gradMag ] = GaussCurvature3D(grid, data)
%
% Computes a second order centered difference approximation to the gauss curvature.
%
%
% parameters:
%   grid	Grid structure (see processGrid.m for details).
%   data        Data array.
%
%   curvature   Curvature approximation (same size as data).
%   gradMag	Magnitude of gradient |\grad \phi|
%                 Incidentally calculated while finding curvature,
%                 also second order centered difference.

% Hui Xue, 22/Feb/2007

if ( grid.dim ~= 3 )
    disp('Only 3D array is supported.');
    curvature = [];
    gradMag = [];
end

%---------------------------------------------------------------------------
% Get the first and second derivative terms.
[ second, first ] = hessianSecond(grid, data);

%---------------------------------------------------------------------------
% Compute gradient magnitude.
gradMag2 = first{1}.^2;
for i = 2 : grid.dim
  gradMag2 = gradMag2 + first{i}.^2;
end
gradMag = sqrt(gradMag2);

%---------------------------------------------------------------------------
curvature = zeros(size(data));

T1 = first{2}.^2 .* ( second{1,1}.*second{3,3} - second{3,1}.*second{3,1} );
T2 = first{1}.^2 .* ( second{2,2}.*second{3,3} - second{3,2}.*second{3,2} );
T3 = first{3}.^2 .* ( second{1,1}.*second{2,2} - second{2,1}.*second{2,1} );

S1 = first{2} .* first{1} .* ( second{3,2}.*second{3,1} - second{2,1}.*second{3,3} );
S2 = first{1} .* first{3} .* ( second{2,1}.*second{3,2} - second{3,1}.*second{2,2} );
S3 = first{2} .* first{3} .* ( second{2,1}.*second{3,1} - second{3,2}.*second{1,1} );

curvature = T1 + T2 + T3 + 2*(S1 + S2 + S3);
clear T1 T2 T3 S1 S2 S3
% Be careful not to stir the wrath of "Divide by Zero".
%  Note that gradMag == 0 implies curvature == 0 already, since all the
%  terms in the curvature approximation involve at least one first dervative.
nonzero = find(gradMag2 > 0);
curvature(nonzero) = curvature(nonzero) ./ gradMag2(nonzero).^2;
