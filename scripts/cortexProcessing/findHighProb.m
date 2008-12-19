
function ind = findHighProb(prob, probablity_thres, minN)
% Find the index of items with relatively high probabilities

% Note the magic numbers!

ind = find(prob >= probablity_thres);

while (length(ind) < minN)
    % Threshold may be too high, lower it and try again.
    probablity_thres = probablity_thres - 0.0005;
    if (probablity_thres <= 0.02)
        % Have reached lowest acceptable threshold, bale out.
        ind = find(prob >= probablity_thres);
        break;
    end
    ind = find(prob >= probablity_thres);
end

if isempty(ind)
    disp('findHighProb.m :');
    error('length(ind) == 0');
end

return
