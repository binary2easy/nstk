function dofName = findBestDof(subjID, dofDir, templateType)
%
% Find the best transformations from the template to the subject out of
% rigid, affine or non-rigid options available.
%

% Are there any hreg produced transformations?
dirString = fullfile(dofDir, 'hreg-*');
dirResult = dir(dirString);

if (isempty(dirResult))
    % Is there an affine transformation available?
    dirString = fullfile(dofDir, 'areg-*');
    dirResult = dir(dirString);
    if (isempty(dirResult))
        % Last chance! Rigid available?
        dirString = fullfile(dofDir, 'rreg-*');
        dirResult = dir(dirString);
        if (isempty(dirResult) || size(dirResult,1) > 1)
            disp('No transformations available to map templates to subject');
            disp(['Subject      : ' subjID]);
            disp(['Template type: ' templateType]);
            error('');
        end
        % Use rreg.
        dofName = fullfile(dofDir, ['rreg-' templateType, '-' subjID '.dof']);
    end
    % Use areg
    dofName = fullfile(dofDir, ['areg-' templateType, '-' subjID '.dof']);
else
    % Use hreg, find the best resolution of control points.
    noOfDofs = size(dirResult, 1);
    spacings = zeros(1, noOfDofs);
    for i = 1:noOfDofs
        str = dirResult(i).name;
        str = regexprep(str, 'mm.dof.gz', '');
        str = regexprep(str, '.*-', '');
        spacings(i) = str2num(str);
    end

    minSpacing = spacings(find (spacings == min(spacings)));
    dofName = fullfile(dofDir, ['hreg-' templateType, '-' subjID '-' num2str(minSpacing) 'mm.dof.gz']);
end

