function [shockpoints, shockvalues, shocks] = ...
  getShockPoints(grid, TTR, SignedPressureForce_GMEnhanced, internal_LS_result, shockThreshold)

% NB! previously the 4th parameter was called SDF i.e. a signed distance
% function - but the data loaded prior to calling is the result of the
% internal LS step.  Which is a kind of signed distance function anyway I
% guess.


% Get the shock points
% shockpoints: N*1 vector, indexes of shock points
% shockvalues: correponding shock values F(x)*norm(gradient(D(x)))

deriv_x = centeredFirstSecond(grid, TTR, 1);
deriv_y = centeredFirstSecond(grid, TTR, 2);
deriv_z = centeredFirstSecond(grid, TTR, 3);

grad_Mag = sqrt(deriv_x.^2 + deriv_y.^2 + deriv_z.^2);

clear deriv_x deriv_z deriv_y

shocks = SignedPressureForce_GMEnhanced .* grad_Mag;

shockpoints = find( (internal_LS_result > 0) & (shocks <= shockThreshold) );

shockvalues = shocks(shockpoints);

return;