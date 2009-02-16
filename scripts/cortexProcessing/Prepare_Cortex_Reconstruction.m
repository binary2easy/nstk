
% Prepare_Cortex_Reconstruction

% ====================================================================== %
% load binary volume of white matter

% get the maximal region of interest
% filename = 'csf_seg.hdr';
% [data, header] = LoadAnalyze(filename, 'Grey');
% [leftup, rightdown] = getBoundingBox_BinaryVolume(data);
% 
% leftup
% rightdown
% 
% extraWidth = 4;
% 
% filename = 'wm_seg.hdr';
% [data, header] = LoadAnalyze(filename, 'Grey');
% [ROI, headerROI]=getROI(data, header, leftup,rightdown);
% [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
% SaveAnalyze(uint32(ROI), headerROI, 'wm_seg_roi.hdr', 'Grey');
% 
% filename = 'post_wm_Real.hdr';
% [wm_membership, header] = LoadAnalyze(filename, 'Real');
% [ROI, headerROI]=getROI(wm_membership, header, leftup,rightdown);
% [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
% SaveAnalyze(ROI, headerROI, 'wm_membership_roi.hdr', 'Real');
% SaveAnalyze(2048*ROI, headerROI, 'wm_membership_roi_rview.hdr', 'Real');
% 
% filename = 'post_gm_Real.hdr';
% [gm_membership, header] = LoadAnalyze(filename, 'Real');
% [ROI, headerROI]=getROI(gm_membership, header, leftup,rightdown);
% [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
% SaveAnalyze(ROI, headerROI, 'gm_membership_roi.hdr', 'Real');
% SaveAnalyze(2048*ROI, headerROI, 'gm_membership_roi_rview.hdr', 'Real');
% 
% filename = 'post_csf_Real.hdr';
% [csf_membership, header] = LoadAnalyze(filename, 'Real');
% [ROI, headerROI]=getROI(csf_membership, header, leftup,rightdown);
% [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
% SaveAnalyze(ROI, headerROI, 'csf_membership_roi.hdr', 'Real');
% SaveAnalyze(2048*ROI, headerROI, 'csf_membership_roi_rview.hdr', 'Real');
% 
% filename = 'withStemBrain_N3.hdr';
% [data, header] = LoadAnalyze(filename, 'Grey');
% [ROI, headerROI]=getROI(data, header, leftup,rightdown);
% [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
% SaveAnalyze(uint32(ROI), headerROI, 'N3Brain_roi.hdr', 'Grey');

% csf_seg_filename
% wm_seg_filename
% post_wm_Real_filename
% post_gm_Real_filename
% post_csf_Real_filename
% Brainfilename

filename='wm_seg_roi_noholes.hdr';
p=dir(filename);
if ( isempty(p) == 1 ) 

    if ( isempty(dir('offsets.mat')) )
        %csf_seg_filename = 'csf_seg.hdr';
        [data, header] = LoadAnalyze(csf_seg_filename, 'Grey');
        [leftup, rightdown] = getBoundingBox_BinaryVolume(data);

        leftup
        rightdown

        extraWidth = 4;

        % wm_seg_filename = 'wm_seg.hdr';
        [data, header] = LoadAnalyze(wm_seg_filename, 'Grey');
        [ROI, headerROI]=getROI(data, header, leftup,rightdown);
        [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
        SaveAnalyze(uint32(ROI), headerROI, 'wm_seg_roi.hdr', 'Grey');

        % post_wm_Real_filename = 'post_wm_Real.hdr';
        [wm_membership, header] = LoadAnalyze(post_wm_Real_filename, 'Real');
        [ROI, headerROI]=getROI(wm_membership, header, leftup,rightdown);
        [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
        SaveAnalyze(ROI, headerROI, 'wm_membership_roi.hdr', 'Real');
        SaveAnalyze(2048*ROI, headerROI, 'wm_membership_roi_rview.hdr', 'Real');

        % post_gm_Real_filename = 'post_gm_Real.hdr';
        [gm_membership, header] = LoadAnalyze(post_gm_Real_filename, 'Real');
        [ROI, headerROI]=getROI(gm_membership, header, leftup,rightdown);
        [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
        SaveAnalyze(ROI, headerROI, 'gm_membership_roi.hdr', 'Real');
        SaveAnalyze(2048*ROI, headerROI, 'gm_membership_roi_rview.hdr', 'Real');

        % post_csf_Real_filename = 'post_csf_Real.hdr';
        [csf_membership, header] = LoadAnalyze(post_csf_Real_filename, 'Real');
        [ROI, headerROI]=getROI(csf_membership, header, leftup,rightdown);
        [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
        SaveAnalyze(ROI, headerROI, 'csf_membership_roi.hdr', 'Real');
        SaveAnalyze(2048*ROI, headerROI, 'csf_membership_roi_rview.hdr', 'Real');

        % Brainfilename = 'withStemBrain_N3.hdr';
        [data, header] = LoadAnalyze(Brainfilename, 'Grey');
        [ROI, headerROI]=getROI(data, header, leftup,rightdown);
        [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
        SaveAnalyze(uint32(ROI), headerROI, 'N3Brain_roi.hdr', 'Grey');

        [data, header] = LoadAnalyze('brainmask_nostem.hdr', 'Grey');
        [ROI, headerROI]=getROI(data, header, leftup,rightdown);
        [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
        SaveAnalyze(uint32(ROI), headerROI, 'brainmask_nostem_roi.hdr', 'Grey');

        [data, header] = LoadAnalyze('segResult.hdr', 'Grey');
        [ROI, headerROI]=getROI(data, header, leftup,rightdown);
        [ROI, headerROI] = AddExtraWidth(ROI, headerROI, extraWidth);
        SaveAnalyze(uint32(ROI), headerROI, 'segResult_roi.hdr', 'Grey');

        save offsets leftup rightdown extraWidth
    end
    % ====================================================================== %

    filename = 'wm_seg_roi.hdr';
    [data, header] = LoadAnalyze(filename, 'Grey');

    filename = 'wm_seg_roi_noholes.hdr';
    p = dir(filename);
    if ( isempty(p) == 1 ) 
        numStep = 3;
        threshold = 2/3;
        data_noholes = Statistical_AutoFill(data, header, numStep, threshold);
        SaveAnalyze(data_noholes, header, 'wm_seg_roi_noholes.hdr', 'Grey');
    end

end