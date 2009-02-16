function Reconstruction_External_GM_Enhanced_TH()

filename=[prefix  '_levelset_Result_TH.hdr'];
p=dir(filename);
if ( isempty(p)==1 )
    % ====================================================================== %
    % signed pressure force is generated by blurring approximating the 0.5
    % isosurface of gray matter surfaces
    filename = 'wm_membership_roi.hdr';
    [wm_membership, header] = LoadAnalyze(filename, 'Real');

    %filename = 'gm_membership_roi.hdr';
    filename = 'enhanced_gm_membership.hdr';
    p = dir(filename);
    if( isempty(p)==1 )
        filename = 'gm_membership_roi.hdr';
    end
    [gm_membership, header] = LoadAnalyze(filename, 'Real');

    SignedPressureForce_externalsurfaces = 2*(wm_membership+gm_membership)-1;

    SaveAnalyze(SignedPressureForce_externalsurfaces, header, 'SPF_externalsurfaces_membership.hdr', 'Real');
    SaveAnalyze(2048*SignedPressureForce_externalsurfaces, header, 'SPF_externalsurfaces_membership_rview.hdr', 'Real');

    % ====================================================================== %
    % perform the external surface propagation using levelset

    filename = 'wm_seg_roi_noholes.hdr';
    [imagedata, header] = LoadAnalyze(filename, 'Grey');

    filename = 'Internal_levelset_Result.hdr';
    [SDF, header] = LoadAnalyze(filename, 'Real');

    filename = 'SPF_externalsurfaces_membership.hdr';
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
    % bValue = 0.02;
    % 
    % accuracy = 'medium';
    % tMax_ReIntialize = 2.5;
    % errorMax = 0.05;
    % 
    % resultDir = 'levelset_medium_External_GMEnhanced_topologyCorrection_26_6';
    % 
    % tMax = 6;                   % End time.
    % tPlot = 0.1;
    % factorCFL = 0.2;
    % reInitialStep = 0.25;
    % 
    % prefix = 'External';
    % flag_outside = 1; % target surface must be outside the data0 surface
    % flag_inside = 0; % target surface must be inside the data0 surface
    % 
    % saveFlag = 1;
    thicknessSpeed = zeros(size(normalSpeed))+eps;
    %--------------------------------------------------------------------------
    LevelSet_External_InternalSurface_TP_MinTH_Script
end