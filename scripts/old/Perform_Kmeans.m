
p = dir(Kmeansfile);
if ( isempty(p) == 0 )
    Kmeans_InitialCentres = ReadKmeans_InitialCentres(Kmeansfile, classnumber);
    Kmeans_InitialCentres
end

if ( isempty(dir(KmeansResultFile)) == 1 )
    [x, indexes] = kmean_init(imagedata, header, brainmask);

    k = classnumber;
    if ( isempty(Kmeans_InitialCentres) == 0)

        M = zeros(classnumber, 1);
        M(:,1, 1) = Kmeans_InitialCentres; % initial intensity centroid for clustering

        for m = 2:TryNumber
            values = rand(k, 1)-0.5;
            values = values .* 150;
%             values = values .* 20;
            M(:,1, m) = M(:,1, 1) + values; 
        end
        [IDX,C,sumd,D] = kmeans(x, k, 'start', M, 'distance', 'cityblock', 'display', 'iter', 'EmptyAction', 'drop');
    else
        [IDX,C,sumd,D] = kmeans(x, k, 'distance', 'cityblock', 'display', 'iter', 'Replicates', TryNumber, 'EmptyAction', 'drop');
    end

    % save results
    kmeans_label = zeros(size(imagedata), 'uint32');
    [ndata, ndim] = size(indexes);
    for i = 1:ndata
        label = IDX(i);
        kmeans_label(indexes(i, 1), indexes(i, 2), indexes(i, 3)) = label;
    end

    filename = [Global_SegResult prefix '_kmeansResult.hdr'];
    SaveAnalyze(kmeans_label, header, KmeansResultFile, 'Grey' );
    clear ICX C sumd D
else
    disp('Loading the kmeans results ...');
    [kmeans_label, header] = LoadAnalyze(KmeansResultFile, 'Grey');
end