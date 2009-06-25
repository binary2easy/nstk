function copyKmeansInitializationFile(rootDir)

saveDir = pwd;
cd(rootDir);

kmeansSubDir = 'kmeans';

name_4class = 'Kmeans_InitialCentres_4classes.txt';
name_5class = 'Kmeans_InitialCentres_5classes.txt';

file_4class = fullfile(rootDir, name_4class);
file_5class = fullfile(rootDir, name_5class);

if (~exist(file_4class, 'file') && ~exist(file_5class, 'file'))
  return
end

[subdirs, num] = findAllDirectory(rootDir);

for i = 1:num
    
    if ( strcmp('parameters', subdirs{i})==1 )
        continue;
    end
    
    currentDir = [rootDir '/' subdirs{i}];
    disp(currentDir);
    
    KmeansDir = fullfile(currentDir, kmeansSubDir);
    
    dstfile = fullfile(KmeansDir, name_4class);
    if ( isempty(dir(dstfile)) && ~isempty(dir(file_4class)))
        copyfile(file_4class, dstfile); 
    end

    dstfile = fullfile(KmeansDir, name_5class);
    if ( isempty(dir(dstfile)) && ~isempty(dir(file_5class)))
        copyfile(file_5class, dstfile);
    end
end

cd (saveDir);
