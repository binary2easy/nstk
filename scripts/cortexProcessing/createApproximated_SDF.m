function SDF = createApproximated_SDF(data, header, appDir)

% Create an approximated signed distance function for a 3D binary volume
% the data should be a volume with isotropic resolution, so that the image
% coordinates are a uniform scaling of the world coordinates along each
% dimension.


randstr  = ['temp-dmap' strrep(num2str(rand), '0.', '') '.nii'];
saveAnalyze(data, header, randstr, 'Grey');

command = [appDir '/dmap'];
command = [command ' "' randstr '"'];
command = [command ' "' randstr '"'];

disp(command);
preCommand = getLDLibPathString;
command = [preCommand ';' command];

[status, result] = system(command);

if (status ~= 0)
  disp('createApproximated_SDF : dmap failed');
  disp(command);
  disp(result);
  error('');
  return;
end

[SDF, dummyHeader] = loadAnalyze(randstr, 'Real');

delete(randstr);

return

