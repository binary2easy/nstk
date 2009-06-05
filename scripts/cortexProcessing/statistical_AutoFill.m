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
% Help fill the holes within the binary volume data

data_noholes = data;

background = 1 - data;

[labels, num] = bwlabeln(background, 6);

volumes = zeros(num, 1);

for i = 1:num
  temp = labels == i;
  volumes(i) = sum(temp(:));
end

[largest, index] = max(volumes);

data_noholes(labels ~= index(1)) = 1;

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
      
      neighbourhood = data(i-1:i+1, j-1:j+1, k-1:k+1);
      
      label = data(i, j, k);
      equalNbrs = neighbourhood == label;
      
      if ( sum(equalNbrs(:)) <= thresh )
        data_noholes(i, j, k) = 1 - label;
      end
 
    end
  end
end

return;