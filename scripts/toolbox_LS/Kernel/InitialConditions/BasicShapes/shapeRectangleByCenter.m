function data = shapeRectangleByCenter(grid, center, widths)
% shapeRectangleByCenter: implicit surface function for a (hyper)rectangle.
%
%   data = shapeRectangleByCenter(grid, center, widths)
%
% Creates an implicit surface function (close to signed distance) 
%   for a coordinate axis aligned (hyper)rectangle specified by its
%   center and widths in each dimension.
%
% Can be used to create intervals and slabs 
%   by choosing components of the widths as +Inf.
%
% The default parameters for shapeRectangleByCenter and 
%   shapeRectangleByCorners produce different rectangles.
%
% parameters:
%   grid	Grid structure (see processGrid.m for details).
%   center      Vector specifying center of rectangle.  Defaults to zeros.
%   widths      Vector specifying widths of each side of the rectangle.
%                 May be a scalar, in which case all dimensions
%                 have the same width.  Defaults to 1.
%
%   data	Output data array (of size grid.size) containing the
%                 implicit surface function.

% Copyright 2004 Ian M. Mitchell (mitchell@cs.ubc.ca).
% This software is used, copied and distributed under the licensing 
%   agreement contained in the file LICENSE in the top directory of 
%   the distribution.
%
% Ian Mitchell, 6/23/04

%---------------------------------------------------------------------------
% Default parameter values.
if(nargin < 2)
  center = zeros(grid.dim, 1);
end
if(nargin < 3)
  widths = 1;
end

if(length(widths) == 1)
  widths = widths * ones(grid.dim, 1);
end

%---------------------------------------------------------------------------
% Implicit surface function calculation.
%   This is basically the intersection (by max operator) of halfspaces.
%   While each halfspace is generated by a signed distance function,
%   the resulting intersection is not quite a signed distance function.

% For the computation, we really want the lower and upper corners.
for i = 1 : grid.dim
  lower(i) = center(i) - 0.5 * widths(i);
  upper(i) = center(i) + 0.5 * widths(i);
end

data = shapeRectangleByCorners(grid, lower, upper);

%---------------------------------------------------------------------------
% Warn the user if there is no sign change on the grid
%  (ie there will be no implicit surface to visualize).
if(all(data(:) < 0) || (all(data(:) > 0)))
  warning([ 'Implicit surface not visible because function has ' ...
            'single sign on grid' ]);
end
