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

preCommand = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}'; 
if strcmp(getenv('OS'), 'Linux')
  command = [preCommand ';' command];
end
disp(command);
[status, result] = system(command);

if (status ~= 0)
  disp('gaussianFilter : region call failed');
  disp(command);
  disp(result);
  error('');
  return;
end

[output, header] = loadAnalyze(randstr, dataType);

delete(randstr);

return
