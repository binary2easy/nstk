function ldLibPathString = getLDLibPathString
%
% Fixes some library loading errors that can happen on Linux installations
% of MatLab. Sometimes, the MatLab install puts stuff first in the load
% library path set that can affect system calls.
%

ldLibPathString = '';

if ~strfind(computer, 'GLNX')
  return
end

% Seem to be on a Linux box.
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

