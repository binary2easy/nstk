function data_noholes = statistical_AutoFill(data, header, numSteps, threshold)

% Perform repeated statistical filling to filter out holes and small
% errors.

data_noholes = data;

for i = 1:numSteps
  data_noholes = autoFillHoles(data_noholes, header);
  data_noholes = statistical_filling(data_noholes, header, threshold);
end

return;

function data_noholes = autoFillHoles(data, header)
% Fill the holes within the binary volume

data_noholes = data;

% pp = data;
% Previous step commented out.  It was made redundant by the next step.
pp = 1 - data;

label = 1;
[l, num] = bwlabeln(pp, 6);

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

volumes = zeros(num, 1);

total = xsize * ysize * zsize;

for i = 1:total
  if (l(i) > 0)
    volumes(l(i)) = volumes(l(i)) + 1;
  end
end

vd = sort(volumes, 'descend');
[largest, index] = max(volumes);

data_noholes(find(l ~= index(1))) = 1;

return

function data_noholes = statistical_filling(data, header, threshold)
% fix the small errors using the 3*3*3 statistical filter (Dale et al.,
% paper)

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

thresh = floor((1 - threshold) * 27);

data_noholes = data;

for k = 2:zsize-1
  for j = 2:ysize-1
    for i = 2:xsize-1

      label = data(j, i, k);
      neighbourhood = GetNeighbourhood(data, header, i, j, k, 3);
      
      numLabel = length(find(neighbourhood==label));
      
      if ( numLabel <= thresh )
        data_noholes(j, i, k) = 1 - label;
      end
    end
  end
end

return;