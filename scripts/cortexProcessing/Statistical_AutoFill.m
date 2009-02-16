
function data_noholes = Statistical_AutoFill(data, header, numStep, threshold)
% perform the numStep statistical filling to filter out holes and small
% errors
data_noholes = data;
for i = 1:numStep
    data_noholes = autoFillHoles(data_noholes, header);
    data_noholes = statistical_filling(data_noholes, header, threshold);
end
return;