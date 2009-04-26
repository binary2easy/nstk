
function [ yOut, schemeDataOut ] = maskFlag_OutInSide(t, yIn, schemeDataIn)

% schemeDataIn.data0
% schemeDataIn.flag_Outside
% schemeDataIn.flag_Inside

disp(['current time is ' num2str(t)]);
disp(['maskFlag_OutInSide ...']);

if ( schemeDataIn.flag_outside )
    yOut = min(yIn, schemeDataIn.y0);
end

if ( schemeDataIn.flag_inside )
    yOut = max(yIn, schemeDataIn.y0);
end

if ( ~schemeDataIn.flag_inside && ~schemeDataIn.flag_outside )
    yOut = yIn;
end

schemeDataOut = schemeDataIn;

return;
