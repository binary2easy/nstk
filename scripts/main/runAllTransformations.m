function runAllTransformations(rootDir, templateDir, templateType, appDir)

% Transform images from template space to subject space.  These are masks
% of cortical ROIs, brain mask and volumetric regions such as basal
% ganglia, deep grey, etc.
%
% rootDir      : Where we can find a subdirectory for each subject.
% templateDir  : Where the template images, segmentations are kept.
% templateType : How much folding complexity is there? complex_brain,
%                simple_brain, medium_brain 
%
% Previously called AllinOne_Transformation

disp('----------------------------------------------------');
disp('runAllTransformations');

[subdirs, num] = findAllDirectory(rootDir);

imageSuffix = '.nii.gz';

% Directory names for each target subject.
anatomyDirName = 'nuCorrected';
cortexDirName  = 'cortexRecon';
dofDirName     = 'dofs';
maskDirName    = 'brainMask';

% During all transformations, the source images will come from the template
% directory:
sourceDir = fullfile(templateDir, templateType);

srcCortexROIDir = fullfile(sourceDir, 'templates_ready');
srcSegDir = fullfile(sourceDir, 'seg');

volSegTypes = {'deepgray', 'corpus_callosum', 'basal_ganglia'};
corticalROITypes = {'frontal_template', 'parietal_template', 'occipital_template', 'temporal_template'};

% Brain mask, without stem:
brainmask = fullfile(srcSegDir, ['brainmask_nostem' imageSuffix]);

for i = 1:num
    
    % for every subject
    subjID  = subdirs{i};
    subjDir = fullfile(rootDir, subjID);
    
    % Subfolders for the transformed template images for the current
    % subject.
    dofDir    = fullfile(subjDir, dofDirName);
    cortexDir = fullfile(subjDir, cortexDirName);
    maskDir   = fullfile(subjDir, maskDirName);
    
    dofName = findBestDof(subjID, dofDir, templateType);

    % Find the template subject's anatomy image.
    p = dir(fullfile(templateDir, templateType, ['*' imageSuffix]));
    if (isempty(p) || size(p, 1) > 1)
        if (isempty(p))
            disp('No template anatomy available');
        else
            disp('Multiple template anatomies available');
        end
        disp(['Directory : ' fullfile(templateDir, templateType)]);
        error('');
    end

    templateAnat   = fullfile(sourceDir, p(1).name);
    trTemplateAnat = fullfile(cortexDir, p(1).name);
    
    % Target subject's anatomy.
    p = dir(fullfile(subjDir, anatomyDirName, ['*' imageSuffix]));
    if (isempty(p) || size(p, 1) > 1)
        if (isempty(p))
            disp('No target subject anatomy available');
        else
            disp('Multiple target subject anatomies available');
        end
        disp(['Directory : ' fullfile(subjDir, anatomyDirName)]);
        error('');
    end
    
    target = fullfile(subjDir, anatomyDirName, p(1).name);

    % 1. Transform template anatomy to target subject.
    runTransformation(templateAnat, trTemplateAnat, dofName, target, appDir);
    
    % 2. Transform the cortical ROI images : srcCortexROIDir -> cortexDir
    for i = 1:length(corticalROITypes)
        srcImg = fullfile(srcCortexROIDir, [char(corticalROITypes{i}) imageSuffix]);
        output = fullfile(cortexDir, [char(corticalROITypes{i}) imageSuffix]);
        runTransformationBinary(srcImg, output, dofName, target, appDir);
    end

    % 3. Transform the volumetric segmentations (deep grey, corpus, basal
    % ganglia) : srcSegDir -> cortexDir
    for i = 1:length(volSegTypes)
        srcImg = fullfile(srcSegDir, [char(volSegTypes{i}) imageSuffix]);
        output = fullfile(cortexDir, [char(volSegTypes{i}) imageSuffix]);
        runTransformationBinary(srcImg, output, dofName, target, appDir);
    end
    
    % 4. Transform the brain mask (without stem) : srcSegDir -> maskDir
    trBrainmask = fullfile(maskDir, ['brainmask_nostem' imageSuffix]);
    runTransformationBinary(brainmask, trBrainmask, dofName, target, appDir);

end

disp('----------------------------------------------------');

