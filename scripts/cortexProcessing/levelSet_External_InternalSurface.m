function levelSet_External_InternalSurface(wmSegRoiNoHoles, header, normalSpeed, data0, lsParams, noOfClasses)


outputFilename = [lsParams.prefix  '_levelset_Result_' num2str(noOfClasses) 'classes.nii.gz'];
outputFilename = fullfile(lsParams.resultDir, outputFilename);



factorCFL        = lsParams.factorCFL;
accuracy         = lsParams.accuracy;
bValue           = lsParams.bValue;
errorMax         = lsParams.errorMax;
flag_outside     = lsParams.flag_outside; % target surface must be outside the data0 surface
flag_inside      = lsParams.flag_inside; % target surface must be inside the data0 surface
tMax             = lsParams.tMax;
tPlot            = lsParams.tPlot;
prefix           = lsParams.prefix;
reInitialStep    = lsParams.reInitialStep;
tMax_ReIntialize = lsParams.tMax_ReIntialize;
resultDir        = lsParams.resultDir;

% mkdir(resultDir);
%---------------------------------------------------------------------------
% Integration parameters.
t0 = 0;                      % Start time.
singleStep = 0;              % Plot at each timestep (overrides tPlot).

% Period at which intermediate plots should be produced.
% tPlot = (tMax - t0) / (plotSteps - 1);

% How close (relative) do we need to get to tMax to be considered finished?
small = 100 * eps;

%---------------------------------------------------------------------------
% What level set should we view?
level = 0;
%--------------------------------------------------------------------------
% Create the grid.
g = [];
g.dim = 3;
% ==========================

xsize = header.xsize;
ysize = header.ysize;
zsize = header.zsize;

xvoxelsize = header.xvoxelsize;
yvoxelsize = header.yvoxelsize;
zvoxelsize = header.zvoxelsize;

% g.min = [-xvoxelsize * (xsize-1)/2.0; -yvoxelsize * (ysize-1)/2.0; -zvoxelsize * (zsize-1)/2.0];
% g.max = [xvoxelsize * (xsize-1)/2.0; yvoxelsize * (ysize-1)/2.0; zvoxelsize * (zsize-1)/2.0];

g.min = [-xvoxelsize * (xsize-1)/2.0; -yvoxelsize * (ysize-1)/2.0; -zvoxelsize * (zsize-1)/2.0];
g.max = [xvoxelsize * (xsize-1)/2.0; yvoxelsize * (ysize-1)/2.0; zvoxelsize * (zsize-1)/2.0];

g.dx = [header.xvoxelsize; header.yvoxelsize; header.zvoxelsize];

g.bdry = @addGhostExtrapolate;

g = processGrid(g, wmSegRoiNoHoles);

%---------------------------------------------------------------------------

% Set up time approximation scheme.
integratorOptions = odeCFLset('factorCFL', factorCFL, 'stats', 'on');

% Choose approximations at appropriate level of accuracy.
%   Same accuracy is used by both components of motion.
switch(accuracy)
 case 'low'
  derivFunc = @upwindFirstFirst;
  integratorFunc = @odeCFL1;
 case 'medium'
  derivFunc = @upwindFirstENO2;
  integratorFunc = @odeCFL2;
 case 'high'
  derivFunc = @upwindFirstENO3;
  integratorFunc = @odeCFL3;
 case 'veryHigh'
  derivFunc = @upwindFirstWENO5;
  integratorFunc = @odeCFL3;
 otherwise
  error('Unknown accuracy level %s', accuracy);
end

%---------------------------------------------------------------------------
% Set up motion in the normal direction.
normalFunc = @termNormal;
normalData.grid = g;
normalData.speed = double(normalSpeed);
normalData.derivFunc = derivFunc;

%---------------------------------------------------------------------------
curvatureFunc = @termCurvature;
curvatureData.grid = g;
curvatureData.curvatureFunc = @curvatureSecond;
curvatureData.b = bValue;

%--------------------------------------------------------------------------

% Convergence criteria
deltaMax = errorMax * max(g.dx) * prod(g.N);

%---------------------------------------------------------------------------
% Combine components of motion.
if ( curvatureData.b ~= 0 )
    schemeFunc = @termSum;
    schemeData.innerFunc = { normalFunc; curvatureFunc };
    schemeData.innerData = { normalData; curvatureData };
else
    schemeFunc = @termSum;
    schemeData.innerFunc = { normalFunc };
    schemeData.innerData = { normalData };
end
schemeData.data0 = data0;
schemeData.y0 = data0(:);
schemeData.flag_outside = flag_outside;
schemeData.flag_inside = flag_inside;
%---------------------------------------------------------------------------
% Let the integrator know what function to call.
integratorOptions = odeCFLset(integratorOptions, ...
                              'postTimestep', @maskFlag_OutInSide);
%--------------------------------------------------------------------------
% Loop until tMax (subject to a little roundoff).
tNow = t0;
startTime = cputime;
data = data0;
tLastReInitial = t0;

while(tMax - tNow > small * tMax)
    disp(['tNow = ' num2str(tNow) ' ... ']);
    % Reshape data array into column vector for ode solver call.
    y0 = data(:);

    % How far to step?
    tSpan = [ tNow, min(tMax, tNow + tPlot) ];

    % Take a timestep.
    [ t y ] = feval(integratorFunc, schemeFunc, tSpan, y0,...
                  integratorOptions, schemeData);
    tNow = t(end);

    % Get back the correctly shaped data array
    data = reshape(y, g.shape);

%     if ( flag_outside )
%         data = min(data, data0);
%     end
%     
%     if ( flag_inside )
%         data = max(data, data0);
%     end
    % Check for convergence (except for the first loop).
    
%     if( norm(y - y0, 1) < deltaMax )
%         disp('the update of phi is too small ...');
%         break;
%     end

%     filename = fullfile(resultDir, [prefix '_levelset_Result_' num2str(tNow) '.hdr']);
%     SaveAnalyze(data, header, filename, 'Real');

    if ( (tNow - tLastReInitial) >= reInitialStep );
        disp(['tNow = ' num2str(tNow) ': Reinitializing ... ']);
        tLastReInitial = tNow;
        
        data = signedDistanceIterative(g, data, accuracy, tMax_ReIntialize, errorMax);

%         filename = fullfile(resultDir, [prefix '_levelset_Result_afterReInitialization_' num2str(tNow) '.hdr']);
%         SaveAnalyze(data, header, filename, 'Real');
    end
end

endTime = cputime;
fprintf('Total execution time %g seconds', endTime - startTime);


SaveAnalyze(data, header, outputFilename, 'Real');


