function output = gaussianFilter(data, header, sigmaX, sigmaY, sigmaZ, dataType)

% Perform a gaussian filter using IRTK executables blur or blur_real.

% The old halfwidth variable was ignored so has been removed.

randstr = ['temp-' strrep(num2str(rand), '0.', '') '.nii'];
saveAnalyze(data, header, randstr, dataType);

if (strcmp(dataType, 'Grey'))
    command = 'blur ';
elseif (strcmp(dataType, 'Real'))
    command = 'blur_real ';
else
    disp('gaussianFilter.m');
    error(['Incorrect data type specified : ' dataType]);
end

sigma = (sigmaX + sigmaY + sigmaZ) / 3.0;

command = [command ' ' randstr ' ' randstr ' ' num2str(sigma)];

system(command);

[output, temp] = loadAnalyze(randstr, dataType);

delete(randstr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Previously made a dll call to a mex compiled version of
%% itkGaussianBlurring.

% Previous signature and output:

% function filterout = Gaussianfilter(data, header, SigmaX, SigmaY, SigmaZ, halfwidth, label)

% Input arguments: data, header, sigmaX, sigmaY, sigmaZ, halfwidth, label
% of Grey image('Grey') or Real image('Real')
% output : filterout

% filterout = Gaussianfilter(data, header, SigmaX, SigmaY, SigmaZ, halfwidth, label);
