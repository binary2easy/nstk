function createDirStructureSingle(subfolder)

saveDir = pwd;

disp(['Creating directory for ' subfolder])

cd(subfolder)

folders = {'kmeans', 'post4', 'post5', 'result', 'segs', 'brainMask', 'nuCorrected', 'cortexRecon', 'priors'};

foldersExist = 1;
for i = 1:numel(folders)
  foldersExist = foldersExist & (exist(folders{i}, 'dir') == 7);
end

if foldersExist
  disp('createDirStructureSingle : all folders already exist, returning');
  return;
end

for i = 1:numel(folders)
  mkdir(char(folders(i)));
end

% Are there any text files for initializing k-means?
dirString = fullfile(subfolder, 'Kmeans_InitialCentres_*classes.txt');
filesFound = dir(dirString);
filesFound = {filesFound.name}';
for i = 1:numel(filesFound)
  filename = char(filesFound(i));
  movefile(filename, 'kmeans');
end

% Now deal with the images.

dirString = fullfile(subfolder, '*.nii.gz' );
filesFound = dir(dirString);
filesFound = {filesFound.name}';

% Mask will be any image with 'mask' in the name.
maskInd = find( ~cellfun('isempty', strfind( lower(filesFound), 'mask') ));
if (numel(maskInd) ~= 1)
  error('Expecting exactly one mask in folder.');
end

if ~strcmp(char(filesFound(maskInd)), 'brainmask_nostem.nii.gz')
  warning('Changing name of mask to ''brainmask_nostem.nii.gz'' ');
  warning('Assuming that the mask has brain stem removed. ');
  movefile(char(filesFound(maskInd)), 'brainmask_nostem.nii.gz');
  filesFound{maskInd} = 'brainmask_nostem.nii.gz';
end

if ( numel(filesFound) == 2 )
  % Expect an image and a mask only.

  filename = char(filesFound(maskInd));
  movefile(filename, 'brainMask');
  % Anatomy filename
  filename = char(filesFound(1:2 ~= maskInd));
  movefile(filename, 'nuCorrected');
  
  
elseif (numel(filesFound) == 6)
  % Expect an image, a mask and 4 prior maps.
  % Priors must be named:  
  % csf.nii.gz  gm.nii.gz  outlier.nii.gz  wm.nii.gz
  % Mask is any file with 'mask' in the name
  % Anatomy is the final image.
  indsRemaining = ones(6,1);
  indsRemaining(maskInd) = 0;
  
  % Move the brain mask.
  filename = char(filesFound(maskInd));
  movefile(filename, 'brainMask');
  
  % Deal with tissue priors.
  tissues = {'csf', 'gm', 'wm', 'outlier'};
  for i = 1:numel(tissues)
    ind = find(ismember(filesFound, [char(tissues(i)) '.nii.gz']));
    if numel(ind) ~= 1
      error(['Expecting exactly one file for tissue class : ''' char(tissues(i)) '''']);
    end
    indsRemaining(ind) = 0;
    filename = char(filesFound(ind));
    movefile(filename, 'priors');
  end
  
  % Anatomy filename
  filename = char(filesFound(indsRemaining > 0));
  movefile(filename, 'nuCorrected');

else
    cd (saveDir);
    disp('createDirStructureSingle.m');
    disp('   Expecting 2 or 6 image files in directory');
    disp(subfolder);
end
