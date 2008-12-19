
function indexInPrior = GetPVs_WM2CSF(mix, suspectWMPVs, segResult, LabelSeg,...
    csflabel, cortexlabel, pvlabel, VolumeThres);
% check the first-order neighbor of suspectWMPVs
% if the most neighboring voxels are gm, this volume is assigned as the incorrectly classified csf
% the prior of wm should decrease and the csf prior should increase

[l,num] = bwlabeln(suspectWMPVs,26);
sizeL = size(l);            

xsize = mix.header.xsize;
ysize = mix.header.ysize;
zsize = mix.header.zsize;

ndata = size(mix.priors, 1);
disp(['Total region: ' num2str(num)]);

tic
% indexInPrior = GetPVs_WM2CSF_MEX(uint32(l), num, segResult, LabelSeg, mix.indexVolume, ...
%     csflabel, cortexlabel, pvlabel, VolumeThres, xsize, ysize, zsize, mix.neighborNum, ndata);

seglabels = [];
indexInPrior = [];
offsets = mix.offset;
numOffsets = size(offsets, 1);
disp(['Total region: ' num2str(num)]);
for ss = 1:num
    if ( mod(ss,50) == 0 )
        disp(['current region: ' num2str(ss)]);
    end
    [i, j, k] = ind2sub(sizeL, find(l==ss)); % row, col, depth
    numRegion = length(i);
    seglabels = [];
    for tt = 1:numRegion

        % PA CHANGING XY SUBSCRIPTS.
%         y = i(tt);
%         x = j(tt);
%         z = k(tt);
        x = i(tt);
        y = j(tt);
        z = k(tt);
        index = 0;
%         if (LabelSeg(y, x, z) ~= pvlabel)
        if (LabelSeg(x, y, z) ~= pvlabel)
            
            %neighbors = GetNeighbourhood2_6neighbors(suspectWMPVs, mix.header, mix.offsets, j(tt), i(tt), k(tt))
            neighbors = zeros(numOffsets, 1);
            
            for pp = 1:numOffsets
                px = x + offsets(pp, 1);
                py = y + offsets(pp, 2);
                pz = z + offsets(pp, 3);                
                if ( pointInROI([px py pz], [1, 1, 1], [xsize ysize zsize]) == true )
                    %PA CHANGING XY SUBSCRIPTS
                    %if (LabelSeg(py, px, pz) == pvlabel)
                    if (LabelSeg(px, py, pz) == pvlabel)
                        continue;
                    end
                    %PA CHANGING XY SUBSCRIPTS
                    %if (l(py, px, pz) > 0)
                    if (l(px, py, pz) > 0)
                        continue;
                    end
                    %PA CHANGING XY SUBSCRIPTS
                    %neighbors(index+1) = segResult(py, px, pz);
                    neighbors(index+1) = segResult(px, py, pz);
                    index = index + 1;
                end
            end
        end
        if ( index > 0 )
            seglabels = [seglabels; neighbors(1:index)];
        end
    end
    if ( isempty(seglabels) == 0 )
       
        recordflag = false;
        
        numGM = length(find(seglabels==cortexlabel));
        numCSF = length(find(seglabels==csflabel));
        numSegLabels = length(seglabels);
        
        if ( numGM/numSegLabels > VolumeThres )
            recordflag = true;
        end % around by GM
        
        if ( numCSF/numSegLabels > VolumeThres )
            recordflag = true;
        end % around by csf
        
        if ( (numCSF+numGM)/numSegLabels > 0.9 )
            recordflag = true;
        end % around by csf and GM

        if ( recordflag )
            currentIndexInPrior = zeros(numRegion, 1);
            for tt = 1:numRegion
                currentIndexInPrior(tt) = mix.indexVolume(i(tt), j(tt), k(tt));
            end   
            indexInPrior = [indexInPrior; currentIndexInPrior];
        end
    end
end
toc
return;