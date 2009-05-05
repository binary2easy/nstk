function Prepare_Cortex_Reconstruction(subjDir, noOfClasses, appDir)

disp('Prepare_Cortex_Reconstruction')
disp(subjDir);

suffix = '.nii.gz';

strNoClasses = num2str(noOfClasses);
postDir = ['post' strNoClasses];

filename = ['wm_seg_' strNoClasses 'classes_roi_noholes.nii.gz'];
filename = fullfile(subjDir, 'result', filename);

if (exist(filename, 'file'))
  disp('Prepare_Cortex_Reconstruction');
  disp(['One file already exists, assuming no need to run script (' strNoClasses ' classes).']);
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

applyROI(inputName, outputName, minCorner, maxCorner, type, appDir);

% WM REAL
inputName  = ['post_wm_Real.nii.gz'];
inputName  = fullfile(subjDir, postDir, inputName);
outputName = ['wm_membership_roi.nii.gz'];
outputName = fullfile(subjDir, postDir, outputName);
type = 'Real';

applyROI(inputName, outputName, minCorner, maxCorner, type, appDir);

% GM REAL
inputName  = ['post_gm_Real.nii.gz'];
inputName  = fullfile(subjDir, postDir, inputName);
outputName = ['gm_membership_roi.nii.gz'];
outputName = fullfile(subjDir, postDir, outputName);
type = 'Real';

applyROI(inputName, outputName, minCorner, maxCorner, type, appDir);

% CSF REAL

inputName  = ['post_csf_Real.nii.gz'];
inputName  = fullfile(subjDir, postDir, inputName);
outputName = ['csf_membership_roi.nii.gz'];
outputName = fullfile(subjDir, postDir, outputName);
type = 'Real';

applyROI(inputName, outputName, minCorner, maxCorner, type, appDir);

% Brain with stem.
inputName  = ['withStemBrain_N3.nii.gz'];
inputName  = fullfile(subjDir, 'nuCorrected', inputName);
outputName = ['N3Brain_roi.nii.gz'];
outputName = fullfile(subjDir, 'nuCorrected', outputName);
type = 'Grey';

applyROI(inputName, outputName, minCorner, maxCorner, type, appDir);

% Brain mask.
inputName  = ['brainmask_nostem.nii.gz'];
inputName  = fullfile(subjDir, 'brainMask', inputName);
outputName = ['brainmask_nostem_roi.nii.gz'];
outputName = fullfile(subjDir, 'brainMask', outputName);
type = 'Grey';

applyROI(inputName, outputName, minCorner, maxCorner, type, appDir);

% Segmentation result.
inputName  = ['segResult_' strNoClasses 'classes.nii.gz'];
inputName  = fullfile(subjDir, 'result', inputName);
outputName = ['segResult_' strNoClasses 'classes_roi.nii.gz'];
outputName = fullfile(subjDir, 'result', outputName);
type = 'Grey';

applyROI(inputName, outputName, minCorner, maxCorner, type, appDir);

% ??? PA.
% save offsets minCorner maxCorner extraWidth

% ====================================================================== %

inputName  = ['wm_seg_' strNoClasses 'classes_roi.nii.gz'];
inputName  = fullfile(subjDir, 'result', inputName);
outputName = ['wm_seg_' strNoClasses 'classes_roi_noholes.nii.gz'];
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function     applyROI(inputName, outputName, minCorner, maxCorner, type, appDir)

rx1 = minCorner(1) - 1;
ry1 = minCorner(2) - 1;
rz1 = minCorner(3) - 1;

rx2 = maxCorner(1);
ry2 = maxCorner(2);
rz2 = maxCorner(3);

switch(type)
  case 'Grey'
    command = [appDir '/region'];
  case 'Real'
    command = [appDir '/region_real'];
  otherwise
    error('Unknown type %s', type);
end

command = [command ' "' inputName '"'];
command = [command ' "' outputName '"'];
command = [command ' -Rx1 ' num2str(rx1) ' -Ry1 ' num2str(ry1) ' -Rz1 ' num2str(rz1)];
command = [command ' -Rx2 ' num2str(rx2) ' -Ry2 ' num2str(ry2) ' -Rz2 ' num2str(rz2)];

preCommand = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}' 
if strcmp(getenv('OS'), 'Linux')
  command = [preCommand ';' command];
end
disp(command);

[status, result] = system(command)

% region wm_seg_4classes.nii.gz temp.nii.gz -Rx1 21  -Ry1 37 -Rz1 28 -Rx2 110 -Ry2 156 -Rz2 127

% More arbitrariness!
extraWidth = 4;
strExtraWidth = num2str(extraWidth);

command = [appDir '/addslices'];
command = [command ' "' outputName '"'];
command = [command ' "' outputName '"'];
command = [command ' -x ' strExtraWidth ' -y ' strExtraWidth ' -z ' strExtraWidth];
if (strcmp(type, 'Real'))
  command = [command ' -real '];
end

if strcmp(getenv('OS'), 'Linux')
  command = [preCommand ';' command];
end
disp(command);

[status, result] = system(command)

% 
% [data, header] = loadAnalyze(inputName, type);
% [roiData, roiHeader] = getROI(data, header, minCorner,maxCorner);
% [roiData, roiHeader] = addExtraWidth(roiData, roiHeader, extraWidth);
% 
% if (strcmp(type, 'Grey'))
%   saveAnalyze(uint32(roiData), roiHeader, outputName, type);
% else
%   saveAnalyze(roiData, roiHeader, outputName, type);
% end

return