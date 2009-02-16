function indexInPrior = GetPVs_WM2CSF(mix, suspectWMPVs, segResult, LabelSeg,...
    csflabel, cortexlabel, pvlabel, VolumeThres)

% Check the first-order neighbor of suspect WM PVs.
% If most of the neighbouring voxels are GM, this volume is assigned as
% incorrectly classified CSF the prior of WM should decrease and the CSF
% prior should increase.

% Connected components in WM PVs image
[components, numComps] = bwlabeln(suspectWMPVs, 26);
sizeComps = size(components);

xsize = mix.header.xsize;
ysize = mix.header.ysize;
zsize = mix.header.zsize;

ndata = size(mix.priors, 1);

disp(['Total region: ' num2str(numComps)]);

% tic

seglabels    = [];
indexInPrior = [];

offsets    = mix.offset;
numOffsets = size(offsets, 1);

disp(['Total region: ' num2str(numComps)]);

for compIndex = 1:numComps
  
  if ( mod(compIndex, 50) == 0 )
    disp(['current region: ' num2str(compIndex)]);
  end
  
  [i, j, k] = ind2sub(sizeComps, find(components == compIndex)); % row, col, depth
  
  regionVolume = length(i);
  seglabels = [];
  
  % Loop over current component.
  for tt = 1:regionVolume
    
    x = i(tt);
    y = j(tt);
    z = k(tt);
    index = 0;

    if (LabelSeg(x, y, z) ~= pvlabel)

      neighbors = zeros(numOffsets, 1);
            
      for pp = 1:numOffsets
        px = x + offsets(pp, 1);
        py = y + offsets(pp, 2);
        pz = z + offsets(pp, 3);

        if ( pointInROI([px py pz], [1, 1, 1], [xsize ysize zsize]) == true )

          if (LabelSeg(px, py, pz) == pvlabel)
            continue;
          end
                  
          if (components(px, py, pz) > 0)
            continue;
          end
                  
          neighbors(index+1) = segResult(px, py, pz);
          index = index + 1;
        end
      end
    end
    
    if ( index > 0 )
      seglabels = [seglabels; neighbors(1:index)];
    end
    
  end % Loop over current component.
  
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
      currentIndexInPrior = zeros(regionVolume, 1);
  
      for tt = 1:regionVolume
        currentIndexInPrior(tt) = mix.indexVolume(i(tt), j(tt), k(tt));
      end
      indexInPrior = [indexInPrior; currentIndexInPrior];
    end
  end
end

% toc

return;