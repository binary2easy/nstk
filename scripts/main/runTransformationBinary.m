
function runTransformationBinary(srcImg, output, dofName, target, appDir)

% Transform a soft map and apply thresholding and morphological closing to
% the result.
%
% Previously TransformationRun_Binary(target, source, output, dof)

if (exist(output))
    disp('runTransformationBinary:');
    disp(['Output exists : ' output]);
    return;
end

command = [appDir '/transformation '];
command = [command ' "' srcImg '"'];
command = [command ' "' output '"'];
command = [command ' -dofin "' dofName '"'];
command = [command ' -target "'  target '"'];
command = [command ' -bspline'];

disp(command);
[s, w] = system(command);

if (s ~= 0)
    disp('runTransformationBinary : transformation failed');
    disp(command);
    error('');
end

[data, header] = loadAnalyze(output, 'Grey');
se = strel('ball', 3, 3, 0);
pp = imclose(data, se);
pp(find(pp>0)) = 1;
saveAnalyze(uint32(pp), header, output, 'Grey');


