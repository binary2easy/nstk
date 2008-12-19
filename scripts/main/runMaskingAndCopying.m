function runMaskingAndCopying(rootDir, appDir)

% Copies a (short type) version of the subject anatomy in the NU corrected
% directory within the same directory.
%
% Also generates a copy of the anatomy that is masked by the transformed
% template brain mask (without stem) in the same directory.
%
% Previously called AllinOne_MaskBrain

disp('----------------------------------------------------');
disp('runMaskingAndCopying');

[subdirs, num] = findAllDirectory(rootDir);

% Directory names common for all subjects.
anatomyDirName = 'nuCorrected';
maskDirName    = 'brainMask';

suffix = '.nii.gz';

maskName          = ['brainmask_nostem' suffix];
unmaskedBrainName = ['withStemBrain_N3' suffix];
maskedBrainName   = ['noStemBrain_N3' suffix];

for i = 1:num
    
    % for every subject
    subjID   = subdirs{i};
    subjDir  = fullfile(rootDir, subdirs{i});
    
    anatomyDir   = fullfile(subjDir, anatomyDirName);
    maskDir = fullfile(subjDir, maskDirName);
%     cd(anatomyDir);
    
    files = dir(fullfile(anatomyDir, ['*' suffix]));
    
    if (numel(files) > 1)
        disp('runMaskAndCopying.m : ');
        disp('More than one image in the anatomy directory : ');
        disp(['   ' anatomyDir]);
        error('');
    end
    
    anatomyCurr       = fullfile(anatomyDir, files(1).name);
    unmaskedBrainCurr = fullfile(anatomyDir, unmaskedBrainName);
    
    if ( ~ exist(unmaskedBrainCurr, 'file') )
        % Save to a short type file called withStemBrain_N3
        command = [appDir 'convert ' anatomyCurr ' ' unmaskedBrainCurr ' -grey'];
        disp(command);
        system(command);
    end
        
%     [data, header] = loadAnalyze(anatomyCurr, 'Grey');
%     % Save to a short type file called withStemBrain_N3
%     saveAnalyze(data, header, unmaskedBrainCurr, 'Grey');
%     % Can be done by using convert in out -grey
    
    
    % Mask from template propagation.
    maskCurr          = fullfile(maskDir, maskName);
    maskNative        = fullfile(maskDir, [subjID '-brain_mask' suffix]);
    
    if (exist(maskNative, 'file'))
        % Incorporate info from native mask to modify propagated mask.
        command = [appDir 'padding ' maskCurr ' ' maskNative ' ' maskCurr ' 0 0'];
        disp(command);
        system(command);
    end
    
    maskedBrainCurr   = fullfile(anatomyDir, maskedBrainName);
    
    if ( ~exist(maskedBrainCurr, 'file') )
        % Use the transformed mask of the brain from the template to the
        % current subject to mask of the brain (no stem).
        command = [appDir 'padding ' anatomyCurr ' ' maskCurr ' ' maskedBrainCurr ' 0 0'];
        disp(command);
        system(command);
    end
    
%     % Where is the transformed mask of the brain (no stem) from the
%     % template to the current subject?    
%     [maskData, header] = loadAnalyze(maskCurr, 'Grey');
%     
%     % Following can be done by padding the original image with the transformed
%     % brainmask (no stem)    
%     noStem = data;
%     noStem(find(maskData==0)) = 0;
%     saveAnalyze(noStem, header, maskedBrainCurr, 'Grey');
    %=========================================================================%
end

disp('----------------------------------------------------');
