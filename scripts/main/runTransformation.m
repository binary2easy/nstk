
function runTransformation(srcImg, output, dofName, target, appDir)

% Transform an image using a given dof and target, e.g. an anatomy.

if (exist(output))
    disp('runTransformation:');
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
system(command);

