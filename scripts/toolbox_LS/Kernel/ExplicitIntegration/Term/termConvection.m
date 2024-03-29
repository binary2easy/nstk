function [ ydot, stepBound, schemeData ] = termConvection(t, y, schemeData)
% termConvection: approximate a convective term in an HJ PDE with upwinding.
%
% [ ydot, stepBound, schemeData ] = termConvection(t, y, schemeData)
%
% Computes an approximation of motion by a constant velocity field V(x,t)
%   for a Hamilton-Jacobi PDE (often called convective or advective
%   flow).  The PDE is:
%
%            D_t \phi = -V(x,t) \dot \grad \phi.
%
% Based on methods outlined in O&F, chapter 3.  The more conservative
%   CFL condition (3.10) is used.
%
% parameters:
%   t            Time at beginning of timestep.
%   y            Data array in vector form.
%   schemeData	 A structure (see below).
%
%   ydot	 Change in the data array, in vector form.
%   stepBound	 CFL bound on timestep for stability.
%   schemeData   The same as the input argument (unmodified).
%
% schemeData is a structure containing data specific to this type of 
%   term approximation.  For this function it contains the field(s)
%
%   .grid	 Grid structure (see processGrid.m for details).
%   .derivFunc   Function handle to upwinded finite difference 
%                  derivative approximation.
%   .velocity	 A description of the velocity field (see below).
%
% It may contain additional fields at the user's discretion.
%
% schemeData.velocity can describe the velocity field in one of two ways:
%   1) For time invariant velocity fields, a cell vector (length grid.dim) 
%      of flow velocities, where each cell contains a scalar or an array 
%      the same size as data.
%   2) For general velocity fields, a function handle to a function
%      with prototype velocity = velocityFunc(t, data, schemeData),
%      where the output velocity is the cell vector from (1) and
%      the input arguments are the same as those of this function
%      (except that data = y has been reshaped to its original size).
%      In this case, it may be useful to include additional fields in
%      schemeData.
%
% For evolving vector level sets, y may be a cell vector.  If y is a cell
%   vector, schemeData may be a cell vector of equal length.  In this case
%   all the elements of y (and schemeData if necessary) are ignored except
%   the first.  As a consequence, if schemeData.velocity is a function handle
%   the call to velocityFunc will be performed with a regular data array
%   and a single schemeData structure (as if no vector level set was present).
%
% In the notation of OF text,
%
%   data = y	  \phi, reshaped to vector form.
%   derivFunc	  Function to calculate phi_i^+-.
%   velocity	  V(x).
%
%   delta = ydot  -V \dot \grad \phi, with upwinded approx to \grad \phi
%                   and reshaped to vector form.

% Copyright 2004 Ian M. Mitchell (mitchell@cs.ubc.ca).
% This software is used, copied and distributed under the licensing 
%   agreement contained in the file LICENSE in the top directory of 
%   the distribution.
%
% Ian Mitchell 5/14/03.
% Calling parameters significantly modified, Ian Mitchell 2/6/04.
% Updated to handle vector level sets.  Ian Mitchell 11/23/04.

  %---------------------------------------------------------------------------
  % For vector level sets, ignore all the other elements.
  if(iscell(schemeData))
    thisSchemeData = schemeData{1};
  else
    thisSchemeData = schemeData;
  end

  checkStructureFields(thisSchemeData, 'grid', 'velocity', 'derivFunc');

  grid = thisSchemeData.grid;

  %---------------------------------------------------------------------------
  if(iscell(y))
    data = reshape(y{1}, grid.shape);    
  else
    data = reshape(y, grid.shape);
  end

  %---------------------------------------------------------------------------
  % Get velocity field.
  if(isa(thisSchemeData.velocity, 'cell'))
    velocity = thisSchemeData.velocity;
  elseif(isa(thisSchemeData.velocity, 'function_handle'))
    velocity = feval(thisSchemeData.velocity, t, data, thisSchemeData);
  else
    error('schemeData.velocity must be a cell vector or a function handle');
  end
  
  %---------------------------------------------------------------------------
  % Approximate the convective term dimension by dimension.
  delta = zeros(size(data));
  stepBoundInv = 0;
  for i = 1 : grid.dim
    
    % Get upwinded derivative approximations.
    [ derivL, derivR ] = feval(thisSchemeData.derivFunc, grid, data, i);
    
    % Figure out upwind direction.
    v = velocity{i};
    flowL = (v < 0);
    flowR = (v > 0);
    
    % Approximate convective term with upwinded derivatives
    %   (where v == 0 derivative doesn't matter).
    deriv = derivL .* flowR + derivR .* flowL;
    
    % Dot product requires sum over dimensions.
    delta = delta + deriv .* v;
    
    % CFL condition.
    stepBoundInv = stepBoundInv + max(abs(v(:))) / grid.dx(i);
  end
  
  %---------------------------------------------------------------------------
  stepBound = 1 / stepBoundInv;
  
  % Reshape output into vector format and negate for RHS of ODE.
  ydot = -delta(:);
