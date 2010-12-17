function createDirStructure(rootDir)

saveDir = pwd;

cd(rootDir)

dirString = fullfile(rootDir, '*.nii.gz' );
filesFound = dir(dirString);
num = length(filesFound);

if ( num == 0 )
    cd (saveDir);
    disp('createDirStructure.m');
    disp('   Found no image files in directory, assuming all have been copied already');
    disp(rootDir);
end

disp('Creating directory for ')

for i = 1:num
    
    cd(rootDir)
    
    nameS = strrep(filesFound(i).name, '.nii.gz', '');
    
    if (findstr('-nu', nameS))
        continue
    end
    if (findstr('-brain', nameS))
        continue
    end
    if (findstr('-brain_mask', nameS))
        continue
    end
    
    filename = fullfile(rootDir, filesFound(i).name);
%     [pathstrS,nameS,extS,versnT] = fileparts(filename);
    
%     filename2 = fullfile(rootDir, indir2(i).name);
%     [pathstrS2,nameS2,extS2,versnT2] = fileparts(filename2);
%     filename2 = fullfile(rootDir, [nameS extS2]);
    
    disp(['file : '  filename]);
%    filename2
    
    mkdir(nameS);
    cd(nameS);
    
    % Names changed slightly, see below for old versions.
    mkdir('kmeans');
    mkdir('post4');
    mkdir('post5');
    mkdir('result');
    mkdir('segs');
    mkdir('brainMask');
    mkdir('nuCorrected');
    mkdir('cortexRecon');
    mkdir('priors');
    mkdir('dofs');
    
    movefile(filename, [rootDir '/' nameS]);
%    movefile(filename, fullfile(rootDir, nameS, [nameS extS]));
%    movefile(filename2, fullfile(rootDir, nameS, [nameS2 extS2]));

    filename2 = fullfile(rootDir, [nameS '-nu.nii.gz']);
    movefile(filename2, [rootDir '/' nameS '/nuCorrected']);
    
    filename2 = fullfile(rootDir, [nameS '-brain.nii.gz']);
    movefile(filename2, [rootDir '/' nameS '/brainMask']);

    filename2 = fullfile(rootDir, [nameS '-brain_mask.nii.gz']);
    movefile(filename2, [rootDir '/' nameS '/brainMask']);
    
end

cd (saveDir)

return


%     mkdir('Kmeans_InitialCentres');
%     mkdir('posterior_4classes');
%     mkdir('posterior_5classes');
%     mkdir('Result');
%     mkdir('segResults');
%     mkdir('brainMask');
%     mkdir('N3Brain');
%     mkdir('backup');
%     mkdir('cortex_reconstruction');
%     mkdir('inter_anatomy_results');
