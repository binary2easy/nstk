function WholeDir_Segmentation(rootDir, fourClasses_flag, fiveClasses_flag, ...
  appDir, subfolder)

if (nargin == 4)
  cd(rootDir);
  [subdirs, num] = findAllDirectory(rootDir);
elseif (nargin == 5)
  % Single subfolder to process.
  subdirs = {subfolder};
  num = 1;  
else
  error('WholeDir_Segmentation: called with wrong number of arguments.');  
end

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
    disp(['WholeDir_Segmentation ' subjDir ]);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check if no work needs doing.
    files5 = dir(fullfile(subjDir, resultDirName, ['segResult_5classes' suffix]));
    files4 = dir(fullfile(subjDir, resultDirName, ['segResult_4classes' suffix]));

    if ((fourClasses_flag == 1) && (fiveClasses_flag == 0))
        if (numel(files4) > 0)
          disp('WholeDir_Segmentation : 4 class result already exists.');
            continue;
        end
    end
    
    if ((fourClasses_flag == 0) && (fiveClasses_flag == 1))
        if (numel(files5) > 0)
          disp('WholeDir_Segmentation : 5 class result already exists.');
            continue;
        end
    end
    
    if ((fourClasses_flag == 1) && (fiveClasses_flag == 1))
        if ((numel(files4) > 0) && (numel(files5) > 0))
          disp('WholeDir_Segmentation : All results already exist.');
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
        subjPars.postDir = fullfile(subjDir, post4DirName);
        singleImageSegmentation(4, subjPars, appDir);
    end
    
    if ( fiveClasses_flag )
        subjPars.postDir = fullfile(subjDir, post5DirName);
        singleImageSegmentation(5, subjPars, appDir);
    end
end