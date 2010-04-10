function runMaskingAndCopying(rootDir, appDir, subfolder)

% Copies a (short type) version of the subject anatomy in the NU corrected
% directory within the same directory.
%
% Also generates a copy of the anatomy that is masked by the transformed
% template brain mask (without stem) in the same directory.
%
% Previously called AllinOne_MaskBrain

disp('----------------------------------------------------');
disp('runMaskingAndCopying');

if (nargin == 2)
  % copy kmean initialization files (name changed from upper case start)
  copyKmeansInitializationFile(rootDir)

  [subdirs, num] = findAllDirectory(rootDir);
elseif (nargin == 3)
  % Single subfolder to process.
  subdirs = {subfolder};
  num = 1;
else
  error('runMaskingAndCopying: called with wrong number of arguments.');
end

% Directory names common for all subjects.
anatomyDirName = 'nuCorrected';
maskDirName    = 'brainMask';

suffix = '.nii.gz';

maskName          = ['brainmask_nostem' suffix];
unmaskedBrainName = ['withStemBrain_N3' suffix];
maskedBrainName   = ['noStemBrain_N3' suffix];

preCommand = getLDLibPathString;

for i = 1:num
    
    % for every subject
    subjID   = subdirs{i};
    subjDir  = fullfile(rootDir, subdirs{i});
    
    anatomyDir   = fullfile(subjDir, anatomyDirName);
    maskDir = fullfile(subjDir, maskDirName);
    
    files = dir(fullfile(anatomyDir, ['*' suffix]));
    
    if (numel(files) > 1)
        disp('runMaskAndCopying.m : ');
        disp('More than one image in the anatomy directory : ');
        disp(['   ' anatomyDir]);
        disp('Returning');
        return
    end
    
    anatomyCurr       = fullfile(anatomyDir, files(1).name);
    unmaskedBrainCurr = fullfile(anatomyDir, unmaskedBrainName);
    
    if ( ~ exist(unmaskedBrainCurr, 'file') )
        % Save to a short type file called withStemBrain_N3
        command = [appDir '/convert "' anatomyCurr '" "' unmaskedBrainCurr '" -short'];
        
        disp(command);
        command = [preCommand ';' command];
        [s, w] = system(command);

        if (s ~= 0)
            disp('runMaskingAndCopying : convert failed');
            disp(command);
            disp(w);
            error('Bailing out');
        end
    end
    
    % Mask from template propagation.
    maskCurr          = fullfile(maskDir, maskName);
    
    % THIS HAS BEEN RESAMPLED SO -r flag needed if we want to use it.
    maskNative        = fullfile(maskDir, [subjID '-brain_mask' suffix]);
    
    if (exist(maskNative, 'file'))
        % WILL NEVER HAPPEN , SEE ABOVE.
        
        % Incorporate info from native mask to modify propagated mask.
        command = [appDir '/padding "' maskCurr '" "' maskNative '" "' maskCurr '" 0 0'];
        disp(command);
        command = [preCommand ';' command];
        [s, w] = system(command);

        if (s ~= 0)
            disp('runMaskingAndCopying : padding failed');
            disp(command);
            disp(w);
            error('Bailing out');
        end
    end
    
    maskedBrainCurr   = fullfile(anatomyDir, maskedBrainName);
    
    if ( ~exist(maskedBrainCurr, 'file') )
        % Use the transformed mask of the brain from the template to the
        % current subject to mask of the brain (no stem).
        command = [appDir '/padding "' anatomyCurr '" "' maskCurr '" "' maskedBrainCurr '" 0 0'];
        disp(command);
        command = [preCommand ';' command];
        [s, w] = system(command);

        if (s ~= 0)
            disp('runMaskingAndCopying : padding failed');
            disp(command);
            disp(w);
            error('Bailing out');
        end
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
