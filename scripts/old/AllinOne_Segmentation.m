AllinOne_ResetAll
disp('----------------------------------------------------');
disp('AllinOne_Segmentation');


% perform the kmeans
Perform_Kmeans_Script

% perform the segmentation
WholeDir_Segmentation

disp('----------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stuff that was previously in this file and commented out.


% % create directory structure
% CreateDir_Structure_NeonatalSeg
% 
% % copy kmean initialization files
% CopyKmeansInitializationFile
% 
% % ------------------------------------------------------------------------
% 
% % perform the brain extraction and N3 correction
% 
% % ------------------------------------------------------------------------
% 
% [subdirs, num] = FindAllDirectory(home)
% 
% brainMaskDir = 'brainMask';
% N3Dir = 'N3Brain';
% for i = 1:num
%     currentDir = [home '\' subdirs{i}];
%     
%     currentN3file = fullfile(currentDir, N3Dir, '*.hdr');
%     p = dir(currentN3file);
%     if ( isempty(p)==1 )
%         error([currentDir ': no N3 brain ...']);
%     end
%     
%     currentBrainMaskDir = fullfile(currentDir, brainMaskDir, '*.hdr');
%     p = dir(currentBrainMaskDir);
%     if ( isempty(p)==1 )
%         error([currentDir ': no brain mask file ...']);
%     end
%     
% end
% 
% % resample the image to be isotropic
% Neonatal_Brain_Resample

% fourClasses_flag = 1;
% fiveClasses_flag = 0;