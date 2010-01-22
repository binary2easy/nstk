
function LabeledSeg = LabelPVs_Seg_slow_fillLabeledSeg(segResult, header, ...
                                    csflabel, wmlabel, cortexlabel, pvlabel,...
                                    nonbrainlabel, neighborwidth)
% According to the prior knowledge to label the pvs from the initial
% segmentation
% the pvs arel labelled as pvlabel

disp('Label partial volumes ...');

segResult2 = segResult;

num = length(wmlabel);
if (num > 1)
    for i = 2:num
        segResult2(segResult == wmlabel(i)) = wmlabel(1);
    end
end

p = wmlabel(1);
wmlabel = p;

LabeledSeg = segResult;

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

for k = 1:zsize
    for j = 1:ysize
        for i = 1:xsize

            label = segResult2(i, j, k);

            % if the pixel is nonbrain or csf or background (label 0), continue
            if ( (label == 0) || (label == csflabel) || (label == nonbrainlabel) )
                continue;
            end

            [~, neighbors] = GetNeighbourhood2(segResult2, header, i, j, k, neighborwidth);

            if ( label == wmlabel )

                % between csf and non-brain tissue
                if ( (isempty(find(neighbors == csflabel, 1))      == 0) && ...
                     (isempty(find(neighbors == nonbrainlabel, 1)) == 0) )
                    LabeledSeg(i, j, k) = csflabel;
                    continue;
                end

                % between csf and gm
                if ( (isempty(find(neighbors == csflabel, 1))    == 0) && ...
                     (isempty(find(neighbors == cortexlabel, 1)) == 0) )
                    LabeledSeg(i, j, k) = cortexlabel;
                    continue;
                end

                % between non-brain tissue and gm
                if ( (isempty(find(neighbors == nonbrainlabel, 1)) == 0) && ...
                     (isempty(find(neighbors == cortexlabel, 1))   == 0) )
                    LabeledSeg(i, j, k) = cortexlabel;
                    continue;
                end

            end

            if ( label == cortexlabel )

                % between csf and non-brain tissue
                if ( (isempty(find(neighbors == csflabel, 1))      == 0) && ...
                     (isempty(find(neighbors == nonbrainlabel, 1)) == 0) )
                    LabeledSeg(i, j, k) = csflabel;
                    continue;
                end

                if ( (isempty(find(neighbors == csflabel, 1)) == 0) && ...
                     (isempty(find(neighbors == 0, 1))        == 0) )
                    LabeledSeg(i, j, k) = csflabel;
                    continue;
                end

                if ( (isempty(find(neighbors == wmlabel, 1)) == 0) && ...
                     (isempty(find(neighbors == 0, 1))       == 0) )
                    LabeledSeg(i, j, k) = wmlabel;
                    continue;
                end
            end
        end
    end
end
