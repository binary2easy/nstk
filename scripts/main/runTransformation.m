
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

preCommand = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}';
if strcmp(getenv('OS'), 'Linux')
  command = [preCommand ';' command];
end

[s, w] = system(command);

if (s ~= 0)
    disp('runTransformation : transformation failed');
    disp(command);
    disp(w);
    error('');
    return;
end

