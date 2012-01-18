function [kmeansLabels, imageHeader] = run_kmeans(outputLabelsName, noOfClasses, centresFile, pars)

outputFilename = fullfile(pars.resultDir, outputLabelsName);

if isfield(pars, 'clobber') && pars.clobber == 1
  clobber = 1;
else
  clobber = 0;
end

if exist(outputFilename, 'file') && clobber == 0
  disp('run_kmeans:');
  disp(['  File present: ' outputFilename]);
  disp('  Returning');
  return;
end

if isfield(pars, 'replicates')
  replicates = pars.replicates;
else
  % default
  replicates = 8;
end

% Read in data
[brainmask, ~]  = loadAnalyze(pars.brainMaskfile, 'Grey');
[imagedata, imageHeader] = loadAnalyze(pars.imagefile,     'Grey');

data = single(imagedata(brainmask > 0));

% Check if initial centroids are available in a file.
if ( exist(centresFile, 'file') )
    initialCentres = readKmeanCentres(centresFile, noOfClasses); 
else
  % No file, try a guess some good centres.
  if (noOfClasses == 4)
    centiles = [25 50 75 90];
  elseif (noOfClasses == 5)
    centiles = [25 50 70 80 90];
  else
    centiles = linspace(100/noOfClasses, 100 - (100/noOfClasses), noOfClasses);
  end  

  initialCentres = prctile(data, centiles);
end

disp('run_kmeans.m:  Using the following initial Centres ... ');
disp(initialCentres);

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

kmeansLabels = brainmask;
kmeansLabels(brainmask > 0) = IDX;

saveAnalyze(kmeansLabels, imageHeader, outputFilename, 'Grey' );

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scale = getScaleForCentrePerturbation(centres)
%  A hack value to apply appropriate scale for noise applied to the centres
%  for different kmeans repetitions

sortedCentres = sort(centres);

diffs = sortedCentres(2:end) - sortedCentres(1:end-1);

scale = 0.5 * mean(diffs);

return



