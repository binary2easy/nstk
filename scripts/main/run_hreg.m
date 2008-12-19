function run_hreg(targetID, sourceID, targetImage, sourceImage, ...
    dofDir, parsFile_hreg, noOfSubdivisions, cpSpacing, padValue, appDir)

% Perform non-rigid registration.
%
% The targetID should be the subject being segmented, the sourceID should
% refer to the type of template being used (e.g. complex_brain).
%
% (Previously called Rigid_Affine_Hreg_RegistrationRun_onlyhreg)

if (noOfSubdivisions < 1 || noOfSubdivisions > 5)
    error(['No. of subdivisions (' noOfSubdivisions ') out of range']);
end


aregPrefix = ['areg-' sourceID '-' targetID];
hregPrefix = ['hreg-' sourceID '-' targetID '-'];

dofin = fullfile(dofDir, [aregPrefix '.dof']);

dofout = cell(noOfSubdivisions);

for i = 1:noOfSubdivisions
    spacingString = [num2str(cpSpacing / (2^(i-1))) 'mm'];
    dofout{i} = fullfile(dofDir, [hregPrefix spacingString '.dof.gz']); 
end

if(exist(char(dofout{noOfSubdivisions})))
    return
end

command = [appDir '/hreg'];
command = [command ' "' targetImage '"'];
command = [command ' "' sourceImage '"'];
command = [command ' ' num2str(noOfSubdivisions)];
command = [command  ' -parameter '];

for i = 1:noOfSubdivisions
  command = [command  '"' char(parsFile_hreg{i}) '" '];
end

command = [command ' -dofin "' dofin '"'];

command = [command ' -dofout '];
for i = 1:noOfSubdivisions
  command = [command  '"' char(dofout{i}) '" '];
end

command = [command  ' -Tp ' num2str(padValue) ' -ds ' num2str(cpSpacing)];

[s, w] = system(command);

if (s ~= 0)
  disp(w);
  disp('');
  disp('run_hreg: error ');
  error('');
end

return
