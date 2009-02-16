
% GM_Enhancement_Cruise
filename = 'enhanced_gm_membership.hdr';
p = dir(filename);
if ( isempty(p) == 1 )
    % ====================================================================== %
    % load binary volume of white matter

    filename = 'gm_membership_roi.hdr';
    [gm_membership, header] = LoadAnalyze(filename, 'Real');

    filename = 'csf_membership_roi.hdr';
    [csf_membership, header] = LoadAnalyze(filename, 'Real');

    filename = 'N3Brain_roi.hdr';
    [imagedata, header] = LoadAnalyze(filename, 'Grey');

    filename = 'Internal_levelset_Result.hdr';
    [SDF, header] = LoadAnalyze(filename, 'Real');

    % ====================================================================== %
    % signed pressure force is generated by favoring the csf tissue

    % ratio_csf = 0.9;

    SignedPressureForce_GMEnhanced = 1 - ratio_csf*csf_membership;

    SaveAnalyze(SignedPressureForce_GMEnhanced, header, 'SignedPressureForce_GMEnhanced.hdr', 'Real');
    SaveAnalyze(2048*SignedPressureForce_GMEnhanced, header, 'SignedPressureForce_GMEnhanced_rview.hdr', 'Real');

    % ====================================================================== %
    % perform the internal surface propagation using levelset

    xsize = header.xsize;
    ysize = header.ysize;
    zsize = header.zsize;

    xvoxelsize = header.xvoxelsize;
    yvoxelsize = header.yvoxelsize;
    zvoxelsize = header.zvoxelsize;

    % perform the level set propagation
    %---------------------------------------------------------------------------
    data0 = SDF;
    normalSpeed = SignedPressureForce_GMEnhanced;
    % bValue = -0.02;
    % 
    % accuracy = 'medium';
    % tMax_ReIntialize = 1.5;
    % errorMax = 0.001;
    % 
    % resultDir = 'levelset_medium_ReInitialization_GM_Enhancement2';
    % 
    % tMax = 8;                   % End time.
    % plotSteps = 20;              % How many intermediate plots to produce?
    % 
    % factorCFL = 0.1;
    % 
    % prefix = 'GM_Enhanced';
    %--------------------------------------------------------------------------

    LevelSet_GM_Enhancement_Script

    %--------------------------------------------------------------------------
    % detect shock points and modifiy the gm membership

    % shockThreshold = 0.8;
    [shockpoints, shockvalues, shocks] = GetShockPoints(g, TTR, SignedPressureForce_GMEnhanced, SDF, shockThreshold);
    shockVolume = zeros(size(csf_membership), 'uint32');
    shockVolume(shockpoints(:)) = 1;
    shockVolume(find(gm_membership<0.8)) = 0;
    SaveAnalyze(shockVolume, header, 'shockVolume.hdr', 'Grey');

    SaveAnalyze(shocks, header, 'shocks.hdr', 'Real');

    %--------------------------
    % filter the small noises from the shockVolume
    volumeThreshold = 20;
    label = 1;
    [label3D, largestComponent] = RegionVolumeFilter_GMEnhanced(shockVolume, header, volumeThreshold, label);
    SaveAnalyze(uint32(label3D), header, 'filtered_shockVolume.hdr', 'Grey');

    % perform the 3D thinning
    object_C = 18;
    background_C = 6;
    [skeletonpoints, skeletonvolume] = Thinning3D_filter(label3D, tp);

    SaveAnalyze(uint32(skeletonvolume), header, 'skeletonvolume.hdr', 'Grey');
    %--------------------------

    % skeletonpoints 
    skeletonvalues = shocks(skeletonpoints);

    enhanced_gm_membership = gm_membership;
    % enhanced_gm_membership(shockpoints) = 0.5 - abs(0.5-gm_membership(shockpoints) .* shockvalues);

    enhanced_gm_membership(skeletonpoints) = 0.5 - abs(0.5-gm_membership(skeletonpoints) .* skeletonvalues);

    % enhanced_gm_membership(shockpoints) = gm_membership(shockpoints) .* shockvalues;
    SaveAnalyze(enhanced_gm_membership, header, 'enhanced_gm_membership.hdr', 'Real');

    save GM_Enhanced

    %-------------------------------------------------------------------------
end