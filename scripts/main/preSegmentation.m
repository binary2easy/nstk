function preSegmentation(rootDir, appDir, fourClasses_flag, fiveClasses_flag)

disp('----------------------------------------------------');
disp('preSegmentation'); % Previously AllinOne_Before_Segmentation
disp('Make directory structure for images and resample the images to be isotropic');

val = 1;

% Create directory structure. Previously 'CreateDir_Structure_NeonatalSeg'.
createDirStructure(rootDir)

% copy kmean initialization files (name changed from upper case start)
copyKmeansInitializationFile(rootDir, fourClasses_flag, fiveClasses_flag)

% ------------------------------------------------------------------------
% perform the brain extraction and N3 correction
% ------------------------------------------------------------------------

[subdirs, num] = findAllDirectory(rootDir);

% Copy brain mask and NU corrected images into relevant subdirectories.
brainMaskDir = 'brainMask';
nuDir        = 'nuCorrected';

suffix       = '.nii.gz';

for i = 1:num
    currentDir = [rootDir '/' subdirs{i}];
    
    dirString = fullfile(currentDir, nuDir, ['*' suffix]);
    p = dir(dirString);
    if ( isempty(p)==1 )
        error([currentDir ': no N3 brain ...']);
    end
    
    dirString = fullfile(currentDir, brainMaskDir, ['*' suffix]);
    p = dir(dirString);
    if ( isempty(p)==1 )
        error([currentDir ': no brain mask file ...']);
    end
    
end

% Resample the image to be isotropic
runResample(rootDir, appDir);

disp('----------------------------------------------------');

% Following is legacy scripting, registrations need to be done before
% segmentations to bring the templates over to the native space. PA.

% % perform the kmeans
% Perform_Kmeans_Script
% 
% % perform the segmentation
% WholeDir_Segmentation