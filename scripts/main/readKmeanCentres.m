
function initialCentres = readKmeanCentres(kmeansFile, noOfClasses)

% Read kmeans file
% Previously ReadKmeans_InitialCentres

initialCentres = [];

if exist(kmeansFile, 'file')
    
    fid = fopen(kmeansFile, 'r');
    if (fid == -1)
        disp('readKmeanCentres :');
        disp(['Cannot read file ' readKmeanCentres]);
        error('');
    end
    
    [initialCentres, count] = fscanf(fid,'%f', noOfClasses);    
    fclose(fid);
    
    if (count ~= noOfClasses)
        disp('readKmeanCentres :');
        disp(['Number of classes : ' num2str(noOfClasses)]);
        disp(['Does not match no. read from file ' kmeansFile]);
        error('');
    end

end