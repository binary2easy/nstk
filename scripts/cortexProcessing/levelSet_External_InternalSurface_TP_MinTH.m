function levelSet_External_InternalSurface_TP_MinTH(wmData, data0, ...
  normalSpeed, thicknessSpeed, header, lsParams, outputFilename, noOfClasses)


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
g.max = [ xvoxelsize * (xsize-1)/2.0;  yvoxelsize * (ysize-1)/2.0;  zvoxelsize * (zsize-1)/2.0];

g.dx = [header.xvoxelsize; header.yvoxelsize; header.zvoxelsize];

g.bdry = @addGhostExtrapolate;

g = processGrid(g, wmData);

voxelsize = (xvoxelsize + yvoxelsize + zvoxelsize)/3;
%---------------------------------------------------------------------------

% Set up time approximation scheme.
integratorOptions = odeCFLset('factorCFL', lsParams.factorCFL, 'stats', 'on');

% Choose approximations at appropriate level of accuracy.
%   Same accuracy is used by both components of motion.
switch(lsParams.accuracy)
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
curvatureData.b = lsParams.bValue;

%--------------------------------------------------------------------------
% the restriction of minimal thickness
minThicknessFunc = @termNormal;
minThicknessData.grid = g;
minThicknessData.speed = thicknessSpeed;
minThicknessData.derivFunc = derivFunc;
%--------------------------------------------------------------------------

% Convergence criteria
deltaMax = lsParams.errorMax * max(g.dx) * prod(g.N);

%---------------------------------------------------------------------------
% Combine components of motion.
if ( lsParams.minThickness_flag )
    if ( curvatureData.b ~= 0 )
        schemeFunc = @termSum;
        schemeData.innerFunc = { normalFunc; curvatureFunc; minThicknessFunc };
        schemeData.innerData = { normalData; curvatureData; minThicknessData };
    else
        schemeFunc = @termSum;
        schemeData.innerFunc = { normalFunc; minThicknessFunc };
        schemeData.innerData = { normalData; minThicknessData };
    end
else
    if ( curvatureData.b ~= 0 )
        schemeFunc = @termSum;
        schemeData.innerFunc = { normalFunc; curvatureFunc };
        schemeData.innerData = { normalData; curvatureData };
    else
        schemeFunc = @termSum;
        schemeData.innerFunc = { normalFunc };
        schemeData.innerData = { normalData };
    end
end
schemeData.data0 = data0;
schemeData.y0 = data0(:);
schemeData.shape = g.shape;

% for max/min operation
schemeData.flag_outside = lsParams.flag_outside;
schemeData.flag_inside = lsParams.flag_inside;

% for the topology perserving level set
schemeData.B        = zeros(size(data0), 'uint8');
schemeData.LastY    = schemeData.y0;
schemeData.LastData = data0;

schemeData.connectivityObject     = 18;
schemeData.connectivityBackground = 6;

schemeData.saveFlag  = lsParams.saveFlag;
schemeData.header    = header;
schemeData.resultDir = lsParams.resultDir;

schemeData.minThickness = lsParams.minThickness;
schemeData.maxThickness = lsParams.maxThickness;
schemeData.voxelsize    = voxelsize;

schemeData = processTopology(schemeData);

global ntimes;
ntimes = 0;
%---------------------------------------------------------------------------
% Let the integrator know what function to call.
% postTimeFunctions = {@checkTopology; @maskFlag_OutInSide};
postTimeFunctions = {@checkTopology; @minThickness_Force; @maskFlag_OutInSide};

integratorOptions = odeCFLset(integratorOptions, ...
                              'postTimestep', postTimeFunctions);
%--------------------------------------------------------------------------
% Loop until tMax (subject to a little roundoff).
tNow = t0;
startTime = cputime;
data = data0;
tLastReInitial = t0;

tMax = lsParams.tMax;

while(tMax - tNow > small * tMax)
  
    disp(['tNow = ' num2str(tNow) ' ... ']);
    % Reshape data array into column vector for ode solver call.
    y0 = data(:);

    % How far to step?
    tSpan = [ tNow, min(tMax, tNow + lsParams.tPlot) ];

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
    
%     if( norm(y - y0, 1) < deltaMax )
%         disp('the update of phi is too small ...');
%         break;
%     end

    if ( abs(tNow - 1.5) < 0.01 )
      filename = fullfile(lsParams.resultDir, [lsParams.prefix '_levelset_Result_' num2str(tNow) '_' num2str(noOfClasses) 'classes.nii.gz']);
      saveAnalyze(data, header, filename, 'Real');
    end
    
    if ( (tNow - tLastReInitial) >= lsParams.reInitialStep );
        disp(['tNow = ' num2str(tNow) ': Reinitializing ... ']);
        tLastReInitial = tNow;
        
        data = signedDistanceIterative(g, data, lsParams.accuracy, lsParams.tMax_ReIntialize, lsParams.errorMax);

%         filename = fullfile(resultDir, [prefix '_levelset_Result_afterReInitialization_' num2str(tNow) '.hdr']);
%         saveAnalyze(data, header, filename, 'Real');
    end
end

endTime = cputime;
fprintf('Total execution time %g seconds', endTime - startTime);

% filename = [prefix  '_levelset_Result_TH.hdr'];
saveAnalyze(data, header, outputFilename, 'Real');





