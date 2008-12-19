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
        segResult(find(segResult == wmlabel(i))) = wmlabel(1);
    end
end

% p = wmlabel(1);
% wmlabel = p;

neighborNum = mix.neighborNum;
lamda = mix.lamda;
xsize = mix.header.xsize;
ysize = mix.header.ysize;
zsize = mix.header.zsize;

% THE FOLLOWING DLL NEEDS REBUILDING.  ENSURE OUTPUT AND INPUT HAVE THE
% SAME DIMENSIONS.
[LabeledSeg, Priors] = LabelPVs_Seg_gmm_Global_MEX(single(mix.priors), mix.indexes, segResult, neighborNum, lamda,...
    xsize, ysize, zsize, csflabel, wmlabel, cortexlabel, pvlabel, nonbrainlabel);

mix.priors = Priors;
index = find(LabeledSeg==pvlabel);
mix.LabelPVs = [mix.LabelPVs; index];
return
