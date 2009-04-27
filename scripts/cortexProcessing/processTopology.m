
function schemeData = processTopology(schemeData)
% fill the B according to the schemeData.LastData
% more initialization operation can be added into this function

% inside point, B=1;
index = find(schemeData.LastData <= 0);
schemeData.B(index) = 1;

return;
