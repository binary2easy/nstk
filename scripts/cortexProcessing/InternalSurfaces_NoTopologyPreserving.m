function InternalSurfaces_NoTopologyPreserving(subjDir, noOfClasses)

prefix = 'prefix';

filename = [prefix  '_levelset_Result.nii.gz'];
filename = fullfile(subjDir, 'cortexRecon', filename);

if (exist(filename, 'file')
  disp('InternalSurfaces_NoTopologyPreserving : ');
  disp(['File : ' filename ' exists, returning']);
  return
end

% ====================================================================== %
% signed pressure force is generated by blurring approximating the 0.5
% isosurface

filename = 'wm_membership_roi.nii.gz';

[data, header] = LoadAnalyze(filename, 'Real');

SignedPressureForce_internalsurfaces = 2*data-1;

SaveAnalyze(SignedPressureForce_internalsurfaces, header, 'SPF_internalsurfaces_membership.hdr', 'Real');
SaveAnalyze(2048*SignedPressureForce_internalsurfaces, header, 'SPF_internalsurfaces_membership_rview.hdr', 'Real');

% ====================================================================== %
% signed pressure force is generated by blurring approximating the 0.5
% isosurface of gray matter surfaces

filename = 'wm_membership_roi.hdr';
[wm_membership, header] = LoadAnalyze(filename, 'Real');

filename = 'gm_membership_roi.hdr';
[gm_membership, header] = LoadAnalyze(filename, 'Real');

SignedPressureForce_externalsurfaces = 2*(wm_membership+gm_membership)-1;

SaveAnalyze(SignedPressureForce_externalsurfaces, header, 'SPF_externalsurfaces_membership.hdr', 'Real');
SaveAnalyze(2048*SignedPressureForce_externalsurfaces, header, 'SPF_externalsurfaces_membership_rview.hdr', 'Real');

% ====================================================================== %
% initialze the signed distance function (SDF) from the isosurface of binary
% segmentation volume
filename = 'wm_seg_roi_noholes.hdr';
[data, header] = LoadAnalyze(filename, 'Grey');

SDF = CreateApproximated_SDF(data, header);

SaveAnalyze(SDF, header, 'SignedDistanceFunction.hdr', 'Real');

% ====================================================================== %
% perform the internal surface propagation using levelset

filename = 'wm_seg_roi_noholes.hdr';
[imagedata, header] = LoadAnalyze(filename, 'Grey');

filename = 'SignedDistanceFunction.hdr';
[SDF, header] = LoadAnalyze(filename, 'Real');

filename = 'SPF_internalsurfaces_membership.hdr';
[SignedPressureForce_internalsurfaces, header] = LoadAnalyze(filename, 'Real');

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

xvoxelsize = header.xvoxelsize;
yvoxelsize = header.yvoxelsize;
zvoxelsize = header.zvoxelsize;

% perform the level set propagation
%---------------------------------------------------------------------------
data0 = SDF;
normalSpeed = SignedPressureForce_internalsurfaces;
% bValue = -0.02;
%
% accuracy = 'medium';
% tMax_ReIntialize = 2.5;
% errorMax = 0.05;
%
% resultDir = 'levelset_medium_ReInitialization_FullHead_Internal';
%
% tMax = 25;                   % End time.
% plotSteps = 100;              % How many intermediate plots to produce?
%
% prefix = 'Internal';
% flag_outside = 0; % target surface must be outside the data0 surface
% flag_inside = 0; % target surface must be inside the data0 surface
%--------------------------------------------------------------------------

LevelSet_External_InternalSurface_Script

    % ====================================================================== %
