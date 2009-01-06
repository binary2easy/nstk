function [kmeansLabels, kmeansHeader] = run_kmeans(outputLabelsName, noOfClasses, centresFile, pars)

% Previously called Perform_Kmeans

filename = fullfile(pars.resultDir, outputLabelsName);
if exist(filename, 'file');
%     disp(['Loading the kmeans results from file ' filename]);
%     [kmeansLabels, kmeansHeader] = loadAnalyze(filename, 'Grey');
%     return;
end

% Replaced a variable called TryNumber:
replicates = 8;

[brainmask, maskHeader]  = loadAnalyze(pars.brainMaskfile,'Grey');
[imagedata, imageHeader] = loadAnalyze(pars.imagefile,'Grey');

[data, indices] = kmean_init(imagedata, imageHeader, brainmask);

% Check if initial centroids are available in a file.
if ( exist(centresFile, 'file') )
    initialCentres = readKmeanCentres(centresFile, noOfClasses); 
else
  % No file, try a guess some good centres.
  centiles = [];
  if (noOfClasses == 4)
    centiles = [25 50 75 90];
  elseif (noOfClasses == 5)
    centiles = [25 50 70 80 90];
  end  

  initialCentres = prctile(data, centiles);
end

disp('run_kmeans.m:  Using the following initial Centres ... ');
disp(initialCentres);

%  A hack value to apply appropriate noise to the centres for kmeans
%  repetitions
scale = getScaleForCentrePerturbation(initialCentres);




if isempty(initialCentres)
    % Cannot specify a starting set of centres for each class, use default
    % type of repetition that kmeans provides.
%     [IDX, C, sumd, D] = kmeans(data, noOfClasses, 'distance', 'cityblock', 'display', 'iter', 'Replicates', replicates, 'EmptyAction', 'drop');
    IDX = kmeans(data, noOfClasses, 'distance', 'cityblock', 'display', 'iter', 'Replicates', replicates, 'EmptyAction', 'drop');
else
    % M contains the set of different centroids to try during
    % repetitions of kmeans.  The one that produces the smallest
    % overall error is chosen will determine the final centres.  The
    % array is 3D noOfClasses x 1 x replicates where replicates is the
    % number of classes.
    M = zeros(noOfClasses, 1);
    
    % The first centroid is obtained from the user provided file.
    M(:,1, 1) = initialCentres; 
    % The remaining centroids are obtained by adding noise to the first.
    % The magnitude of the noise is given by 'scale' which should be set
    % manually above.
    for m = 2:replicates
        values = rand(noOfClasses, 1) - 0.5;
        values = values .* scale;
        M(:,1, m) = M(:,1, 1) + values;
    end
    
%     [IDX, C, sumd, D] = kmeans(data, noOfClasses, 'start', M, 'distance', 'cityblock', 'display', 'iter', 'EmptyAction', 'drop');
    IDX = kmeans(data, noOfClasses, 'start', M, 'distance', 'cityblock', 'display', 'iter', 'EmptyAction', 'drop');
end

% Save results.
kmeansLabels = zeros(size(imagedata), 'uint32');
[ndata, ndim] = size(indices);

for i = 1:ndata
    kmeansLabels(indices(i, 1), indices(i, 2), indices(i, 3)) = IDX(i);
end

filename = fullfile(pars.resultDir, outputLabelsName);
kmeansHeader = imageHeader;

saveAnalyze(kmeansLabels, kmeansHeader, filename, 'Grey' );

return

function scale = getScaleForCentrePerturbation(centres)

diffs = zeros(numel(centres) - 1, 1);
sortedCentres = sort(centres);
lastIndex = numel(centres) - 1;
for i = 1:lastIndex
    diffs(i) = sortedCentres(i + 1) - sortedCentres(i);
end

diffs = abs(diffs);

scale = sum(diffs) / numel(centres);

return



