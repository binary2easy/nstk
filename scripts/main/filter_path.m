function filter_path(pattern)

all = path;
patt = ['([^' pathsep ']+)' pathsep];

[entries] = regexp(all, patt, 'tokens');
for i = 1:length(entries)
     entry = char(entries{i});
     if (~isempty(strfind(entry, pattern)))
         rmpath(entry);
     end;
end;