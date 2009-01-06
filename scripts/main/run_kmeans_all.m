function run_kmeans_all(rootDir, fourClasses_flag, fiveClasses_flag)

[subdirs, num] = FindAllDirectory(rootDir);

maskDirName    = 'brainMask';
anatomyDirName = 'nuCorrected';
kmeansDirName  = 'kmeans';
resultDirName  = 'result';

suffix = '.nii.gz';

noStemBrain = ['noStemBrain_N3' suffix];
maskName    = ['brainmask_nostem' suffix];

% ============================================================== %
% Looks like a global, needed for run_kmeans.  Moved into that script 
% and changed its name to 'replicates'.
% TryNumber = 8;

for i = 1:num
    
    subjDir = fullfile(rootDir, subdirs{i});
    % common setting
%     cd(subjDir);
    disp(subjDir);

    % These look like globals.
%     Global_SegResult = './result/';
%     Local_SegResult  = './result/';
%     KmeansDir        = './kmeans/';
    
    pars = struct('resultDir', '', 'kmeansDir', '', 'maskDir', '', ...
        'anatDir', '', 'brainMaskfile', '', 'imagefile', '');
    
    
    pars.resultDir = fullfile(subjDir, resultDirName);
    pars.kmeansDir = fullfile(subjDir, kmeansDirName);
    
    % My strings:
    pars.maskDir = fullfile(subjDir, maskDirName);
    pars.anatDir = fullfile(subjDir, anatomyDirName);

    % Check if there is already something in the kmeans dir.
    dirString = fullfile(pars.kmeansDir, ['*' suffix]);
    files = dir(dirString);
    if ( numel(files) > 0 )
        disp('run_kmeans_all.m : Files appear to already be in kmeans directory');
        disp(['  ' pars.kmeansDir]);
        disp('');
        continue;
    end
    
    % Is mask available?
    dirString = fullfile(pars.maskDir, maskName);
    files = dir(dirString);
    if ((numel(files) == 0) || (numel(files) > 1))
        disp('run_kmeans_all.m : ');
        disp(['Zero or multiple masks in ' pars.maskDir]);
        error('');
    end
    
    pars.brainMaskfile = fullfile(pars.maskDir, files(1).name);

    dirString = fullfile(pars.anatDir, noStemBrain);
    files = dir(dirString);
    if ((numel(files) == 0) || (numel(files) > 1))
        disp('run_kmeans_all.m : ');
        disp(['Zero or multiple no-stem anatomy images in ' anatDir]);
        error('');
    end
    
    pars.imagefile = fullfile(pars.anatDir, files(1).name);
    
    labels4classes = [];
    header4classes = struct([]);
    labels5classes = [];
    header5classes = struct([]);

    if ( fourClasses_flag )
        centresFile = fullfile(rootDir, 'Kmeans_InitialCentres_4classes.txt');
        run_kmeans('kmeans-4classes.nii.gz', 4, centresFile, pars);
%         kmeans4_singleImage;
    end
    
    if ( fiveClasses_flag )
        centresFile = fullfile(rootDir, 'Kmeans_InitialCentres_5classes.txt');
        run_kmeans('kmeans-5classes.nii.gz', 5, centresFile, pars);
%         kmeans5_singleImage;
    end
end