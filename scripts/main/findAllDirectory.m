function [subdir, dirCount] = findAllDirectory(rootDir)

% Previously FindAllDirectory
% find all subdirectorys

contents = dir(rootDir);

count = length(contents);
dirCount = 0;

subdir = cell(0);

for i = 1:count
    % Skip if not a directory
    if ( ~contents(i).isdir )
        continue;
    end
    
    temp = contents(i).name;
    
    % Skip if first character is '@', allows some directories to be left
    % alone. Also skip if we have '.' or '..'.
    if ( (temp(1) == '@') || (strcmp(temp, '.')) || (strcmp(temp, '..')))
        continue;
    end

    dirCount = dirCount + 1;
    subdir = [subdir {temp}];
    
end

