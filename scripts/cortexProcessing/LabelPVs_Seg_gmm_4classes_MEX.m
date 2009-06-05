function [LabeledSeg, mix] = LabelPVs_Seg_gmm_4classes_MEX(mix, segResult, ...
                                    csflabel, wmlabel, cortexlabel, pvlabel,...
                                    nonbrainlabel)
% according to the prior knowledge to label the pvs from the initial
% segmentation
% the pvs arel labelled as pvlabel

disp('Label partial volumes ...');

num = length(wmlabel);
if (num > 1)
    for i = 2:num
        segResult(segResult == wmlabel(i)) = wmlabel(1);
    end
end

connectivity = mix.neighborNum;
lambda       = mix.lamda;

[LabeledSeg, Priors] = segLabelsPVCorrection_4classes(mix.priors, mix.indexes, segResult, connectivity, lambda, ...
  csflabel, wmlabel, cortexlabel, pvlabel, nonbrainlabel);

mix.priors = Priors;
index = find(LabeledSeg==pvlabel);
mix.LabelPVs = [mix.LabelPVs; index];

return
