function runAllRegistrations(rootDir, appDir, noOfSubdivisions, templateDir, templateType, cpSpacing)
% Old name allInOne_Registration

disp('----------------------------------------------------');
disp('Running all regstrations.');

[subdirs, noOfSubjects] = findAllDirectory(rootDir);

imageSuffix = '.nii.gz';

% Which subdirectory for each subject contains the target anatomy for each
% subject?
anatomyDirName = 'nuCorrected';

% Which subdirectory contains / will contain the transformations?
dofDirName = 'dofs';

% The source image is the template we want to propagate.
sourceDir = fullfile(templateDir, templateType);
sourceImage = fullfile(sourceDir, [templateType imageSuffix]);

padValue = 0;
% cpSpacing = 20; % Previously separate for dx, dy and dz, ie. [20 20 20]

% Parameter files are expected to be at the top level.
parsFile_rreg = fullfile(rootDir, 'parameters.rreg');
parsFile_areg = fullfile(rootDir, 'parameters.areg');

parsFile_hreg = cell(noOfSubdivisions);
parsFile_hreg{1} = fullfile(rootDir, 'parameters-20mm.mreg');
parsFile_hreg{2} = fullfile(rootDir, 'parameters-10mm.mreg');
parsFile_hreg{3} = fullfile(rootDir, 'parameters-5mm.mreg');
parsFile_hreg{4} = fullfile(rootDir, 'parameters-2.5mm.mreg');
parsFile_hreg{5} = fullfile(rootDir, 'parameters-2.5mm.mreg');

% ============================================================== %
% Main Loop.
% ============================================================== %

for i = 1:noOfSubjects

    subjID  = subdirs{i};
    subjDir = fullfile(rootDir, subjID);
    targetDir = fullfile(subjDir, anatomyDirName);
    dofDir    = fullfile(subjDir, dofDirName);
    
    dirString = fullfile(targetDir, ['*' imageSuffix]);
    files = dir(dirString);
    num   = length(files);
    if ( num ~= 1 )
        disp ('Empty directory or multiple target files : ');
        disp (['    ' subjID]);
        error(['    ' targetDir]);    
    end

    targetImage = fullfile(targetDir, files(1).name);
    
    % Register the template (as source image) to the subject (as target).
    
    % Rigid and affine.
    run_rreg_areg(subjID, templateType, targetImage, sourceImage, ...
                  dofDir, parsFile_rreg, parsFile_areg, appDir);
    % Non-rigid.
    run_hreg(subjID, templateType, targetImage, sourceImage, ...
             dofDir, parsFile_hreg, noOfSubdivisions, cpSpacing, padValue, appDir);

    %=========================================================================%

end

disp('Registrations done.');
disp('----------------------------------------------------');
%
%
% 
%     if ( noOfSubdivisions == 3 )
%         NonrigidName = fullfile(subjDir, dofDir, '*hreg-3.dof');
%     end
% 
%     if ( noOfSubdivisions == 4 )
%         NonrigidName = fullfile(subjDir, dofDir, '*hreg-4.dof');
%     end
%     
%     if ( noOfSubdivisions == 5 )
%         NonrigidName = fullfile(subjDir, dofDir, '*hreg-5.dof');
%     end
%     
%     if ( isempty(dir(NonrigidName))== 0 )
%         continue;
%     end
% 
