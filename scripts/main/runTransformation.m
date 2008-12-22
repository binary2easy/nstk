
function runTransformation(srcImg, output, dofName, target, appDir)

% Transform an image using a given dof and target, e.g. an anatomy.
%
% Previously called TransformationRun(target, source, output, dof)

if (exist(output))
    disp('runTransformation:');
    disp(['Output exists : ' output]);
    return;
end

command = [appDir '/transformation ' srcImg ' ' output ' -dofin ' dofName ' -target ' target ' -bspline' ];
disp(command);
system(command);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% OLD CODE:
% 
% if (isempty(dir(output))==0)
%     disp([' exists : ' output ' ... ' ]);
%     return;
% end
% 
% command = ['transformation' ' ' source ' ' output ' ' '-dofin' ' ' dof ' ' '-target' ' ' target ' '  '-bspline' ];
% command
% [s, w] = dos(command, '-echo');
% return