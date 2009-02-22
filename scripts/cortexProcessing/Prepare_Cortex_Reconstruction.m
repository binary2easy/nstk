%%

function Prepare_Cortex_Reconstruction(subjDir, noOfClasses)

disp('Prepare_Cortex_Reconstruction')
disp(subjDir);

suffix = '.nii.gz';

strNoClasses = num2str(noOfClasses);
postDir = ['post' strNoClasses];

filename = fullfile(subjDir, postDir, ['wm_seg_roi_noholes' suffix]);

if (exist(filename, 'file'))
  return;
end


% p=dir(filename);
% 
% if ( isempty(p) == 1 ) 
% 
%     if ( isempty(dir('offsets.mat')) )
        %csf_seg_filename = 'csf_seg.hdr';

% Determine ROI using CSF segmentation.
csf_seg_filename = ['csf_seg_' strNoClasses 'classes.nii.gz'];
csf_seg_filename = fullfile(subjDir, 'result', csf_seg_filename);
        
[data, header] = loadAnalyze(csf_seg_filename, 'Grey');
[minCorner, maxCorner] = getBoundingBox_BinaryVolume(data);

%  Make bounds symmetrical. Currently, getROI.m can only handle symmetrical
%  ROIs within the image volume.
dims = header.nii.hdr.dime.dim(2:4);
a = dims - maxCorner + 1;
b = minCorner;
minCorner = min([a ; b]);
maxCorner = dims - minCorner + 1;

disp(['Bounds used : ' num2str(minCorner) ' to ' num2str(maxCorner)]);

% Apply to the other images.

% WMls 
inputName  = ['wm_seg_' strNoClasses 'classes.nii.gz'];
inputName  = fullfile(subjDir, 'result', inputName);
outputName = ['wm_seg_' strNoClasses 'classes_roi.nii.gz'];
outputName = fullfile(subjDir, 'result', outputName);
type = 'Grey';

applyROI(inputName, outputName, minCorner, maxCorner, type);


% WM REAL
inputName  = ['post_wm_Real.nii.gz'];
inputName  = fullfile(subjDir, postDir, inputName);
outputName = ['wm_membership_roi.nii.gz'];
outputName = fullfile(subjDir, postDir, outputName);
type = 'Real';

applyROI(inputName, outputName, minCorner, maxCorner, type);

% GM REAL
inputName  = ['post_gm_Real.nii.gz'];
inputName  = fullfile(subjDir, postDir, inputName);
outputName = ['gm_membership_roi.nii.gz'];
outputName = fullfile(subjDir, postDir, outputName);
type = 'Real';

applyROI(inputName, outputName, minCorner, maxCorner, type);


% CSF REAL

inputName  = ['post_csf_Real.nii.gz'];
inputName  = fullfile(subjDir, postDir, inputName);
outputName = ['csf_membership_roi.nii.gz'];
outputName = fullfile(subjDir, postDir, outputName);
type = 'Real';

applyROI(inputName, outputName, minCorner, maxCorner, type);


% Brain with stem.
inputName  = ['withStemBrain_N3.nii.gz'];
inputName  = fullfile(subjDir, 'nuCorrected', inputName);
outputName = ['N3Brain_roi.nii.gz'];
outputName = fullfile(subjDir, 'nuCorrected', outputName);
type = 'Grey';

applyROI(inputName, outputName, minCorner, maxCorner, type);

% Brain mask.
inputName  = ['brainmask_nostem.nii.gz'];
inputName  = fullfile(subjDir, 'brainMask', inputName);
outputName = ['brainmask_nostem_roi.nii.gz'];
outputName = fullfile(subjDir, 'brainMask', outputName);
type = 'Grey';

applyROI(inputName, outputName, minCorner, maxCorner, type);

% Segmentation result.
inputName  = ['segResult_' strNoClasses 'classes.nii.gz'];
inputName  = fullfile(subjDir, 'result', inputName);
outputName = ['segResult_' strNoClasses 'classes_roi.nii.gz'];
outputName = fullfile(subjDir, 'result', outputName);
type = 'Grey';

applyROI(inputName, outputName, minCorner, maxCorner, type);

% ??? PA.
% save offsets minCorner maxCorner extraWidth

% ====================================================================== %

inputName  = ['wm_seg_' strNoClasses 'classes_roi.nii.gz'];
inputName  = fullfile(subjDir, 'result', inputName);
outputName = ['wm_seg_' strNoClasses 'classes_roi_noholes.hdr'];
outputName = fullfile(subjDir, 'result', outputName);

if (exist(outputName, 'file'))
  return;
end

[data, header] = loadAnalyze(inputName, 'Grey');

numSteps  = 3;
threshold = 2/3;

data_noholes = statistical_AutoFill(data, header, numSteps, threshold);
saveAnalyze(data_noholes, header, outputName, 'Grey');

return

%%

function     applyROI(inputName, outputName, minCorner, maxCorner, type)

extraWidth = 4;

[data, header] = loadAnalyze(inputName, type);
[roiData, roiHeader] = getROI(data, header, minCorner,maxCorner);
[roiData, roiHeader] = AddExtraWidth(roiData, roiHeader, extraWidth);

if (strcmp(type, 'Grey'))
  saveAnalyze(uint32(roiData), roiHeader, outputName, type);
else
  saveAnalyze(roiData, roiHeader, outputName, type);
end

return