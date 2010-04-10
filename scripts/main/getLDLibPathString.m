function ldLibPathString = getLDLibPathString

ldLibPathString = '';

if ~strfind(computer, 'GLNX')
  return
end

% Linux box.

% Which shell?

shellType = getenv('SHELL');

if strfind(shellType, 'bash')
  ldLibPathString = 'export LD_LIBRARY_PATH="/usr/lib:/lib:{LD_LIBRARY_PATH}"';
elseif strfind(shellType, 'csh')
  ldLibPathString = 'setenv LD_LIBRARY_PATH /usr/lib:/lib:{LD_LIBRARY_PATH}';
else
  disp('getLDLibPathString : Unsupported shell type');
end

return