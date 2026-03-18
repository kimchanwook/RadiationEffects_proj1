function Phi_est = estimate_fluence_from_events(nEvents, area_cm2)
%ESTIMATE_FLUENCE_FROM_EVENTS Convert number of simulated primaries to a
% nominal fluence by assuming a uniformly illuminated area.
%
% Phi_est = nEvents / area_cm2

arguments
    nEvents (1,1) double {mustBeNonnegative}
    area_cm2 (1,1) double {mustBePositive}
end

Phi_est = nEvents ./ area_cm2;
end
