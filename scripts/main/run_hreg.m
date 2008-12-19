function run_hreg(targetID, sourceID, targetImage, sourceImage, ...
    dofDir, parsFile_hreg, noOfSubdivisions, cpSpacing, padValue)

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



command = ['hreg' ' ' targetImage ' ' sourceImage ' ' num2str(noOfSubdivisions) ' -parameter '];
for i = 1:noOfSubdivisions
  command = [command  char(parsFile_hreg{i}) ' '];
end
command = [command  ' -dofin ' dofin ' -dofout '];
for i = 1:noOfSubdivisions
  command = [command  char(dofout{i}) ' '];
end
command = [command  ' -Tp ' num2str(padValue) ' -ds ' num2str(cpSpacing)];

system(command)

return
%
%
%
%
% 
% % targetfile
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
% %     RigidRegistrationRun2(target, source, rregfullname, rreg_parameterfile);
% %     
% %     % areg
% %     AffineRegistrationRun2(target, source, aregfullname, areg_parameterfile, rregname);
%     
% % hreg
% NonRigidRegistrationRun2(target, source, hregnames, hreg_parameterfiles,...
%     numofparameters, aregfullname, TpValue, controlPoints);
%     
% return;
