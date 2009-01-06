function runResample(rootDir, appDir)

cd(rootDir);
[subdirs, num] = findAllDirectory(rootDir);

brainMaskDir = 'brainMask';
nuDir        = 'nuCorrected';
backupDir    = 'backup';

suffix       = '.nii.gz';

% ============================================================== %
% resolution = [0.86 0.86 0.86];
for i = 1:num
    currentDir = [rootDir '/' subdirs{i}];
    % common setting
    cd(currentDir);
    
    dirString = fullfile(currentDir, brainMaskDir, ['*' suffix] );
    inMaskDir = dir(dirString);
    num = length(inMaskDir);
    if ( num == 0 )
        disp(['Found empty directory during resampling : ' currentDir '/' brainMaskDir]);
        continue;
    end

    % brainMaskfile = fullfile(currentDir, brainMaskDir, inMaskDir(1).name);
    % brainMaskfile2 = fullfile(currentDir, backupDir, inMaskDir(1).name);

    dirString = fullfile(currentDir, nuDir, ['*' suffix] );
    inNUDir = dir(dirString);
    num = length(inNUDir);
    if ( num == 0 )
        disp(['Found empty directory during resampling : ' currentDir '/' nuDir]);
        continue;
    end
    
    imagefile = fullfile(currentDir, nuDir, inNUDir(1).name);
    % imagefile2 = fullfile(currentDir, backupDir, inNUDir(1).name);

    % cd ([currentDir '/' nuDir]);
    % [data, header] = loadAnalyze(inNUDir(1).name, 'Grey');
    % [data, header] = loadAnalyze(imagefile, 'Grey');
    % cd(currentDir);
    header = loadAnalyzeHeader(imagefile);
    
    res = min([header.xvoxelsize header.yvoxelsize header.zvoxelsize]);
    resolution = [res res res];
    
    disp(['Resampling in directory: ' subdirs{i}]);
    
    runResampleForDir(appDir, currentDir, nuDir, nuDir, resolution);
    runResampleForDir(appDir, currentDir, brainMaskDir, brainMaskDir, resolution);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Marker to indicate an image has been resampled.
    marker = '-r';
    
    for i = 1:length(inMaskDir)
        if findstr(marker, inMaskDir(i).name)
            % Leave resampled images in the directory.
            continue
        end
        brainMaskfile = fullfile(currentDir, brainMaskDir, inMaskDir(i).name);
        movefile(brainMaskfile, fullfile(currentDir, backupDir));
    end
%     movefile(brainMaskfile, fullfile(currentDir, backupDir));
%     if findstr (brainMaskfile, 'hdr')
%         temp = strrep(brainMaskfile, 'hdr', 'img');
%         movefile(temp, backupDir);
%     end
    
    for i = 1:length(inNUDir)
        if findstr(marker, inNUDir(i).name)
            % Leave resampled images in the directory.
            continue
        end
        imagefile = fullfile(currentDir, nuDir, inNUDir(i).name);
        movefile(imagefile, fullfile(currentDir, backupDir));
    end
%     movefile(imagefile, fullfile(currentDir, backupDir));
%     if findstr (imagefile, 'hdr')
%         temp = strrep(imagefile, 'hdr', 'img');
%         movefile(temp, backupDir);
%     end

    

end

cd (rootDir)
