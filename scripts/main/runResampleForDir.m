function runResampleForDir(appDir, rootDir, subdirectory, outputDir, resolution)
% resample the image

suffixPattern = '*.nii.gz';
dirString = fullfile(rootDir, subdirectory, suffixPattern);
indir = dir(dirString) ;

num = length(indir);
if ( num == 0 )
    disp('empty directory');
    return;
end

if ( resolution(1) < 0.25 )
    resolution(1) = 0.25;
end

% ?? PA.
resolution(2) = resolution(1);
resolution(3) = resolution(2);

%%% flag to mark files that have been resampled.  Previously based on
%%% explicitly putting the min voxel dimension into the filename.  Now just
%%% user '-r';
marker = '-r';
% marker = ['_' num2str(resolution(1))];
% pPositions = find(marker == '.');
% marker(pPositions) = repmat('p', size(pPositions));

suffix = '.nii.gz';

for i = 1:num
    fullname = fullfile(rootDir, subdirectory, indir(i).name);

    % Assume that we have a .nii.gz file, PA.
    temp = strrep(fullname, '.gz', '');
    [pathstr, name, ext, versn] = fileparts(temp);
   
    if findstr(marker, name)
        continue
    end
    
    newname = [name marker suffix];
%     pPositions = find(newname == '.');
%     newname(pPositions(1)) = 'p';
    newfullname = fullfile(rootDir, outputDir, newname);
    
    header = loadAnalyzeHeader(fullname);
    if ( (header.xvoxelsize == header.yvoxelsize) && (header.yvoxelsize == header.zvoxelsize))
        copyfile(fullname, newfullname);
        continue
    end
    
    
    command = [appDir '/resample'];
    command = [command ' "' fullname '"'];
    command = [command ' "' newfullname '"'];
    command = [command ' -size ' num2str(resolution(1), '%10.8f')];
    command = [command ' ' num2str(resolution(2), '%10.8f')];
    command = [command ' ' num2str(resolution(3), '%10.8f')];
    command = [command ' -bspline'];
    
    preCommand = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}';
    if strcmp(getenv('OS'), 'Linux')
      command = [preCommand ';' command];
    end
    [s, w] = system(command);

    if (s ~= 0)
      disp('Resample failed');
      disp(command);
      disp(w);
      error('');
      return;
    end

end

disp(['Resampling done for directory: ' subdirectory]);

return;