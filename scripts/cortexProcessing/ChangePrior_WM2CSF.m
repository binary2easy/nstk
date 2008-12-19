
function mix = ChangePrior_WM2CSF(mix, indexes, LabelSeg, pvlabel)
% decrease the prior of wm PVs and increase their csf priors

num = size(indexes,1);
lamda = mix.lamda;
for k = 1:num
    
    priors = mix.priors(indexes(k), :);
    priors(2) = priors(2)*lamda;
    if ( mix.ncentres == 4 )
        priors(3) = priors(3)*lamda;
    end
    if ( mix.ncentres == 5 )
        priors(3) = priors(3)*lamda;
        priors(4) = priors(4)*lamda;
    end
    temp = 1 - sum(priors);
    csfNew = priors(1) + temp;
    priors(1) = csfNew;
    mix.priors(indexes(k), :) = priors;
    
end
return;