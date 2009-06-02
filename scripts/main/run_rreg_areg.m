function run_rreg_areg(targetID, sourceID, targetImage, sourceImage,...
    dofDir, parsFile_rreg, parsFile_areg, appDir)

% Perform the rigid, affine and non-rigid registration.
%
% The targetID should be the subject being segmented, the sourceID should
% refer to the type of template being used (e.g. complex_brain).
%
% (Previously called Rigid_Affine_Hreg_RegistrationRun)

rregPrefix  = ['rreg-' sourceID '-' targetID];
dofin_rreg  = [rregPrefix '-init.dof'];
dofout_rreg = [rregPrefix '.dof'];

dofin_rreg  = fullfile(dofDir, dofin_rreg);
dofout_rreg = fullfile(dofDir, dofout_rreg);

% See if we need to run rreg.
if (~exist(dofout_rreg))
    % rreg command:
    command = [appDir '/rreg'];
    command = [command ' "' targetImage '"'];
    command = [command ' "' sourceImage '"'];
    command = [command ' -parameter "' parsFile_rreg '"'];
    command = [command ' -dofout "' dofout_rreg '"'];
    if (exist(dofin_rreg))
        command = [command ' -dofin "' dofin_rreg '"'];
    end
    
    preCommand = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}';
    if strcmp(getenv('OS'), 'Linux')
      command = [preCommand ';' command];
    end
    [s, w] = system(command);
    
    if (s ~= 0)
      disp('run_rreg_areg error: rreg failed.');
      disp(w);
      error('');
      return;
    end    
end

aregPrefix  = ['areg-' sourceID '-' targetID];
dofin_areg  = dofout_rreg;
dofout_areg = [aregPrefix '.dof'];

dofin_areg  = dofout_rreg;
dofout_areg = fullfile(dofDir, dofout_areg);

% Run areg.
if (~exist(dofout_areg))
    if (~exist(dofin_areg))
        disp('Input transformation not available for areg');
        error(['File missing: '  dofin_areg]);
    end

    % areg command
    command = [appDir '/areg'];
    command = [command ' "' targetImage '"'];
    command = [command ' "' sourceImage '"'];
    command = [command ' -parameter "' parsFile_areg '"'];
    command = [command ' -dofout "' dofout_areg '"'];
    command = [command ' -dofin "' dofin_areg '"'];

    preCommand = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}';
    if strcmp(getenv('OS'), 'Linux')
      command = [preCommand ';' command];
    end
    [s, w] = system(command);
    
    if (s ~= 0)
      disp('run_rreg_areg error: areg failed.');
      disp(w);
      error('');
      return;
    end    
end

return
