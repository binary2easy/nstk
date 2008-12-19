
function prefix = CreatePrefix(home, Global_flag, Local_flag, Atlas_flag_Global, Atlas_flag_Local,...
    Kmeans_flag_Global, Kmeans_flag_Local, MRF_flag_Global, MRF_flag_Local, Four_classes_flag, Five_classes_flag, ...
    partsNumber, GMM_PVs_flag, GMM_PVs_flag_Local)

% according to the program setting, generate an unique prefix

prefix = [];

% ================== %

if ( Global_flag )
    prefix = [prefix 'Global_'];


    if ( Atlas_flag_Global )
        prefix = [prefix 'Atlas_'];
    end

    if ( Kmeans_flag_Global )
        prefix = [prefix 'Kmeans_'];
    end

    if ( MRF_flag_Global )
        prefix = [prefix 'MRF_'];
    end
    
    if ( GMM_PVs_flag )
        prefix = [prefix 'GmmPVs_'];  
    end
end

% ================== %
if ( Local_flag )
    prefix = [prefix 'Local_'];


    if ( Atlas_flag_Local )
        prefix = [prefix 'Atlas_'];
    end

    if ( Kmeans_flag_Local )
        prefix = [prefix 'Kmeans_'];
    end

    if ( MRF_flag_Local )
        prefix = [prefix 'MRF_'];
    end
    
    if ( GMM_PVs_flag_Local )
        prefix = [prefix 'GmmPVs_'];  
    end
end

if ( Local_flag )
    prefix = [prefix 'PartNumber_' num2str(partsNumber) '_'];
end


% ================== %

if ( Four_classes_flag )
    prefix = [prefix '4classes'];
end

if ( Five_classes_flag )
    prefix = [prefix '5classes'];
end
% ================== %

% find specific subject name
ind = find(home == '/');
if ( isempty(ind) == 1 )
    ind = find(home == '\');
end

if ( isempty(ind) == 1 )
    return;
end

subjectname = home(ind(end)+1:end);

prefix = [subjectname '_' prefix ];

return;
