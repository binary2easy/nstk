function WholeDir_Segmentation(rootDir, fourClasses_flag, fiveClasses_flag)

cd(rootDir);
[subdirs, num] = findAllDirectory(rootDir);

maskDirName    = 'brainMask';
anatomyDirName = 'nuCorrected';
kmeansDirName  = 'kmeans';
resultDirName  = 'result';
post4DirName   = 'post4';
post5DirName   = 'post5';

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
    
    % These look like globals. Get rid.
%     Global_SegResult = './result/';
%     Local_SegResult  = './result/';
%     KmeansDir        = './kmeans/';

    subjPars = struct('resultDir', '', 'kmeansDir', '', 'maskDir', '', ...
        'anatDir', '', 'brainMaskfile', '', 'imagefile', '', 'postDir', '');
    
    subjPars.resultDir = fullfile(subjDir, resultDirName);
    subjPars.kmeansDir = fullfile(subjDir, kmeansDirName);
    
    % My strings:
    subjPars.maskDir = fullfile(subjDir, maskDirName);
    subjPars.anatDir = fullfile(subjDir, anatomyDirName);


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
        disp(['Zero or multiple no-stem anatomy images in ' anatDir]);
        error('');
    end
    
    subjPars.imagefile = fullfile(subjPars.anatDir, files(1).name);
    
    subjPars.kmeansLabels4 = fullfile(subjPars.resultDir, ['kmeans-4classes' suffix]);
    
    files = dir(subjPars.kmeansLabels4);
    if (fourClasses_flag && (numel(files) == 0))
        disp('WholeDir_Segmentation.m : ');
        disp('Four classes required but kmeans file unavailable.');
        disp(['    ' subjPars.kmeansLabels4]);
        error('');
    end
    
    subjPars.kmeansLabels5 = fullfile(subjPars.resultDir, ['kmeans-5classes' suffix]);
    
    files = dir(subjPars.kmeansLabels5);
    if (fiveClasses_flag && (numel(files) == 0))
        disp('WholeDir_Segmentation.m : ');
        disp('Five classes required but kmeans file unavailable.');
        disp(['    ' subjPars.kmeansLabels5]);
        error('');
    end    

    if ( fourClasses_flag )
%         cd(subjDir);
%         SingleImage_Segmentation_4classes_forWholeDir;
        subjPars.postDir = fullfile(subjDir, post4DirName);
        singleImageSegmentation(4, subjPars);
    end
    
    if ( fiveClasses_flag )
%         cd(subjDir);
%         SingleImage_Segmentation_5classes_forWholeDir;
        subjPars.postDir = fullfile(subjDir, post5DirName);
        singleImageSegmentation(5, subjPars);
    end
end