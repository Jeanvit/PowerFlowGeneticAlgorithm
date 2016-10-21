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
% Incorporating static penalty constraint handling method.
%
% This routine is called subsequent to every function evaluation, 
% i.e. power flow calculation. It does not affect the calculations 
% done in test_bed_OPF.p, which calculates internally the fitness by
% using static penalty constraint handling method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,g]=constraint_handling(o,g)
    % You may use procedural information 
    % such as function evaluation counter 
    % proc.i_eval to dynamically adjust
    % your constraint handling method.
    global proc
    % Uniform penalty coefficient.
	penalty=1e10;
    % Sum up all violations.
    % Note that, at this point, constraint 
    % vector g consists only of elements
    % >=0 due to g(g<1e-4)=0 as internal
    % preliminary step.
	g=sum(g);
    % Fitness function.
	f=o+penalty*g;
end