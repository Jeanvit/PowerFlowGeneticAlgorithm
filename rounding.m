%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task Force on Modern Heuristic Optimization Test Beds
% Working Group on Modern Heuristic Optimization
% Intelligent Systems Subcommittee
% Power System Analysis, Computing, and Economic Committee
%
% Sebastian Wildenhues (E-Mail: sebastian.wildenhues@uni-due.de)
% 14th February 2014
%
% Application of Modern Heuristic Optimization Algorithms 
% for Solving Optimal Power Flow Problems
% 
% Incorporating customized rounding for discrete/binary 
% components/variables.
%
% This function is called, in addition to an internal rounding, prior 
% to every individual function evaluation, i.e. power flow calculation, 
% in test_bed_OPF.p. You are allowed to modify this routine to include your 
% rounding strategy, but the function syntax, i.e. x_out=rounding(x_in), 
% should be kept.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_out=rounding(x_in)
    % 
    x_out=round(x_in);
end