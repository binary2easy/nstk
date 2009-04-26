function levelSet_GM_Enhancement()

mkdir(resultDir);
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
% g.min = [-xvoxelsize * (xsize-1)/2.0; -yvoxelsize * (ysize-1)/2.0; -zvoxelsize * (zsize-1)/2.0];
% g.max = [xvoxelsize * (xsize-1)/2.0; yvoxelsize * (ysize-1)/2.0; zvoxelsize * (zsize-1)/2.0];

g.min = [-yvoxelsize * (ysize-1)/2.0; -xvoxelsize * (xsize-1)/2.0; -zvoxelsize * (zsize-1)/2.0];
g.max = [yvoxelsize * (ysize-1)/2.0; xvoxelsize * (xsize-1)/2.0; zvoxelsize * (zsize-1)/2.0];

g.dx = [header.yvoxelsize; header.xvoxelsize; header.zvoxelsize];

g.bdry = @addGhostExtrapolate;

g = processGrid(g, imagedata);

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
normalData.speed = normalSpeed;
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
%schemeFunc = @termSum;
schemeFunc = normalFunc;
% schemeData.innerFunc = { normalFunc; curvatureFunc };
% schemeData.innerData = { normalData; curvatureData };
schemeData = normalData;
schemeData.data0 = data0;
schemeData.y0 = data0(:);
%---------------------------------------------------------------------------
% Let the integrator know what function to call.
integratorOptions = odeCFLset(integratorOptions, ...
                              'postTimestep', @postTimestepTTR);
%--------------------------------------------------------------------------
% Loop until tMax (subject to a little roundoff).
tNow = t0;
startTime = cputime;
data = data0;

%========================================
% call the TTR function once
y0 = data(:);
[y, schemeData] = postTimestepTTR(tNow, y0, schemeData);
%========================================

while(tMax - tNow > small * tMax)
    disp(['tNow = ' num2str(tNow) ' ... ']);
    % Reshape data array into column vector for ode solver call.
    y0 = data(:);

    % How far to step?
    tSpan = [ tNow, min(tMax, tNow + tPlot) ];

    % Take a timestep.
    [ t, y, schemeData ] = feval(integratorFunc, schemeFunc, tSpan, y0,...
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
    if( norm(y - y0, 1) < deltaMax )
        disp('the update of phi is too small ...');
        break;
    end

    filename = fullfile(resultDir, [prefix '_levelset_Result_' num2str(tNow) '.hdr']);
%     SaveAnalyze(data, header, filename, 'Real');

    data = signedDistanceIterative(g, data, accuracy, tMax_ReIntialize, errorMax);

%     filename = fullfile(resultDir, [prefix '_levelset_Result_afterReInitialization_' num2str(tNow) '.hdr']);
%     SaveAnalyze(data, header, filename, 'Real');
    
    filename = fullfile(resultDir, [prefix  '_TTR_' num2str(tNow) '.hdr']);
    ttr = schemeData.ttr;
    TTR = reshape(ttr, g.shape);
    index = find(TTR==inf);
    TTR(index(:)) = 10*tMax;
%     SaveAnalyze(double(TTR), header, filename, 'Real');
end

endTime = cputime;
fprintf('Total execution time %g seconds', endTime - startTime);

TTR_filename = [prefix  '_TTR.hdr'];
ttr = schemeData.ttr;
TTR = reshape(ttr, g.shape);
index = find(TTR==inf);
TTR(index(:)) = 10*tMax;
SaveAnalyze(double(TTR), header, TTR_filename, 'Real');

filename = [prefix  '_levelset_Result.hdr'];
SaveAnalyze(data, header, filename, 'Real');