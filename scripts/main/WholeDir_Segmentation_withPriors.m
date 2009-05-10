function WholeDir_Segmentation_withPriors(rootDir, fourClasses_flag, fiveClasses_flag)

cd(rootDir);
[subdirs, num] = findAllDirectory(rootDir);

maskDirName    = 'brainMask';
anatomyDirName = 'nuCorrected';
kmeansDirName  = 'kmeans';
resultDirName  = 'result';
post4DirName   = 'post4';
post5DirName   = 'post5';
priorDirName   = 'priors';

suffix = '.nii.gz';

noStemBrain = ['noStemBrain_N3' suffix];
maskName    = ['brainmask_nostem' suffix];

for i = 1:num

    subjDir = fullfile(rootDir, subdirs{i});
%     cd(subjDir);
    disp(subjDir);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check if no work needs doing.
    files5 = dir(fullfile(subjDir, resultDirName, ['segResult_5classes' suffix]));
    files4 = dir(fullfile(subjDir, resultDirName, ['segResult_4classes' suffix]));

    if ((fourClasses_flag == 1) && (fiveClasses_flag == 0))
        if (numel(files4) > 0)
            continue;
        end
    end
    
    if ((fourClasses_flag == 0) && (fiveClasses_flag == 1))
        if (numel(files5) > 0)
            continue;
        end
    end
    
    if ((fourClasses_flag == 1) && (fiveClasses_flag == 1))
        if ((numel(files4) > 0) && (numel(files5) > 0))
            continue;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subjPars = struct('resultDir', '', 'kmeansDir', '', 'maskDir', '', ...
        'anatDir', '', 'brainMaskfile', '', 'imagefile', '', 'postDir', '');
    
    subjPars.resultDir = fullfile(subjDir, resultDirName);
    subjPars.kmeansDir = fullfile(subjDir, kmeansDirName);
    
    % My strings:
    subjPars.maskDir = fullfile(subjDir, maskDirName);
    subjPars.anatDir = fullfile(subjDir, anatomyDirName);
    subjPars.priorDir = fullfile(subjDir, priorDirName);


    files = dir(fullfile(subjPars.maskDir, maskName));
    if ((numel(files) == 0) || (numel(files) > 1))
        disp('WholeDir_Segmentation.m : ');
        disp(['Zero or multiple masks in ' subjPars.maskDir]);
        error('');
    end
    
    subjPars.brainMaskfile = fullfile(subjPars.maskDir, files(1).name);

    files = dir(fullfile(subjPars.anatDir, noStemBrain));
    if ((numel(files) == 0) || (numel(files) > 1))
        disp('WholeDir_Segmentation.m : ');
        disp(['Zero or multiple no-stem anatomy images in ' subjPars.anatDir]);
        error('');
    end
    
    subjPars.imagefile = fullfile(subjPars.anatDir, files(1).name);
    
    subjPars.priorWM = fullfile(subjPars.priorDir, ['wm' suffix]);
    subjPars.priorWM1 = fullfile(subjPars.priorDir, ['wm1' suffix]);
    subjPars.priorWM2 = fullfile(subjPars.priorDir, ['wm2' suffix]);

    subjPars.priorCortex = fullfile(subjPars.priorDir, ['gm' suffix]);
    subjPars.priorCSF = fullfile(subjPars.priorDir, ['csf' suffix]);
    subjPars.priorOutlier = fullfile(subjPars.priorDir, ['outlier' suffix]);
    
    if ( fourClasses_flag )
        subjPars.postDir = fullfile(subjDir, post4DirName);
        singleImageSegmentation_withPriors(4, subjPars);
    end
    
    if ( fiveClasses_flag )
        subjPars.postDir = fullfile(subjDir, post5DirName);
        singleImageSegmentation_withPriors(5, subjPars);
    end
end