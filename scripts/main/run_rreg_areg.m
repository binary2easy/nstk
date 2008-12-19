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
    
    [s, w] = system(command);
    
    if (s ~= 0)
      disp('run_rreg_areg error: rreg failed.');
      error('');
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

    [s, w] = system(command);
    
    if (s ~= 0)
      disp('run_rreg_areg error: areg failed.');
      error('');
    end    
end

return
%
%
% 
% 
% path_abo = fullfile(target_Dir, target_anatomyDir, '*.hdr' );
% indir = dir(path_abo) ;
% num = length(indir);
% if ( num == 0 )
%     disp('empty directory');
%     return;
% end
% 
% target = fullfile(target_Dir, target_anatomyDir, indir(1).name);
% [pathstrT,nameT,extT,versnT] = fileparts(target);
% 
% % sourcefile
% 
% path_abo = fullfile(source_Dir, source_anatomyDir, '*.hdr' );
% indir = dir(path_abo);
% num = length(indir);
% if ( num == 0 )
%     disp('empty directory');
%     return;
% end
% 
% source = fullfile(source_Dir, source_anatomyDir, indir(1).name);
% [pathstrS,nameS,extS,versnT] = fileparts(source);
% 
% % result filenames
% 
% %%%%%%%%%%%
% %%% PA : these dof files seem to be in reverse order compared with
% %%% how we normally name them.
% 
% rregname = [nameT '-' nameS '-rreg.dof'];
% rregfullname = fullfile(result_Dir, Registration_resultsDir, rregname);
% 
% aregname = [nameT '-' nameS '-areg.dof'];
% aregfullname = fullfile(result_Dir, Registration_resultsDir, aregname);
% 
% hregnames = cell(numofparameters);
% for i = 1:numofparameters
%     hregnames{i} = [nameT '-' nameS '-hreg' '-' num2str(i) '.dof'];
%     hregnames{i} = fullfile(result_Dir, Registration_resultsDir, hregnames{i});
% end
% 
% % perform the registration
% 
%     % rreg
%       RigidRegistrationRun2(target, source, rregfullname, rreg_parameterfile);
%     
%     % areg
%       AffineRegistrationRun2(target, source, aregfullname, areg_parameterfile, rregfullname);
%     
%     % hreg
%      NonRigidRegistrationRun2(target, source, hregnames, hreg_parameterfiles, numofparameters, aregfullname);
% return;
