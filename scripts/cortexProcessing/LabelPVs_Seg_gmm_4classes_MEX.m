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
% FAIRLY SURE THIS DLL CALL WILL NOT WORK IF 26 NEIGHBOUR CONNECTIVITY IS
% REQUIRED.  SEE MEX C++ CODE.
[LabeledSeg, Priors] = LabelPVs_Seg_gmm_Global_MEX(...
  single(mix.priors), ...  % 0 (argument index when in c++ code.
  mix.indexes, ...         % 1
  segResult, ...           % 2
  neighborNum, ...         % 3
  lamda,...                % 4
  xsize, ysize, zsize, ... % 5-7
  csflabel, ...            % 8
  wmlabel, ...             % 9 NB this can be an array with one or two elements.
  cortexlabel, ...         % 10
  pvlabel, ...             % 11
  nonbrainlabel);          % 12

mix.priors = Priors;
index = find(LabeledSeg==pvlabel);
mix.LabelPVs = [mix.LabelPVs; index];
return
