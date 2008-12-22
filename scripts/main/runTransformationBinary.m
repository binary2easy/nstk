
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

command = [appDir '/transformation ' srcImg ' ' output ' -dofin ' dofName ' -target ' target ' -linear' ];
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% OLD CODE:

% Alternative to using matlab toolbox imclose function (image proc
% toolbox).

% command = ['threshold ' output ' ' output ' 0'];
% disp(command);
% system(command);
% 
% command = ['closing ' output ' ' output];
% disp(command);
% system(command);

% Hui's original script:

% if (isempty(dir(output))==0)
%     disp([' exists : ' output ' ... ' ]);
%     return;
% end
% 
% command = ['transformation' ' ' source ' ' output ' ' '-dofin' ' ' dof ' ' '-target' ' ' target ' '  '-bspline' ];
% command
% [s, w] = dos(command, '-echo');
% 
% [data, header] = loadAnalyze(output, 'Grey');
% se = strel('ball', 3, 3, 0);
% pp = imclose(data, se);
% pp(find(pp>0)) = 1;
% SaveAnalyze(uint32(pp), header, output, 'Grey');
% 
% return