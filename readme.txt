- This algorithm tries to find the optimal solution for an Electric Power Flow Problem through a Genetic Algorithm
	- The selection occurs via Tournament with a 1 vs 1 game
	- The recombination points is random
	- The mutations also occurs in random individuals

- More details about the Power Flow Problem can be seen in the docs folder
- The code I implemented is in the psopt file




%Original readme.txt
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This is a brief description of the Matlab-based codes of the test bed for the Panel 
Session and Competition on Application of Modern Heuristic Optimization Algorithms 
for Optimal Power Flow Problems (OPF) to be held at the 2014 IEEE PES General Meeting

History of releases:
Version                Date              Notes
test_bed_OPF_V10       27.09.2013        ---
test_bed_OPF_V11       30.09.2013        Bug related to storage of results to folder 
 					 ..\output_data_(proc.algorithm_name) fixed.
test_bed_OPF_V12       16.12.2013        Operating system portability issue fixed.
test_bed_OPF_V12       16.12.2013 	 Tolerance band eps=1e-1 introduced with respect 
					 to fitness and objective function value.
					 This is in order to relax the problems' severity 
					 level and stimulates obtaining more reasonable
					 outcome in terms of feasibility of solutions.
test_bed_OPF_V13       11.02.2014	 Branch ratings corrected (upgraded) for WPP.
test_bed_OPF_V13       11.02.2014	 Internal handling of branch constraints adapted.
                                         Although final numerical outcome is unaffected,
                                         these may have certain influence on the search.
test_bed_OPF_V14       14.02.2014	 Global best fitness returned to the optimization.
					 For example (cf. psopt.m):
					 [fit,obj,g_sum,pos,fit_best]=feval(fhd,ii,jj,kk,args,pos),
					 where fit_best refers to the global best fitness
					 as is determined in test_bed_OPF.m and stored to 
					 the corresponding ACSII file for evaluation purposes.
test_bed_OPF_V14       14.02.2014	 Previous tolerance band eps=1e-1 ignored.
					 This is in order to provide the organizers with
					 continuous fitness measures around final solutions. 
					 Note that these may be characterized by very small 
					 constraint violations and could adversely affect 
					 decision making with respect to the numerical outcome.
test_bed_OPF_V14       14.02.2014	 Number of function evaluations increased from 150000 
					 to 300000 for 300 bus test system (both test cases).

Code Structure
==============
readme.txt:      this file

main.m:          main program which allows selecting the OPF test case to be solved, 
                 calling the routine written for your optimization algorithm,
                 deciding whether to use or not parallel computing
                
psopt.m:         exemplary implementation with particle swarm optimization (PSO)
                 indicating the few additions needed to interface the test suit codes
                 with your algorithm's code

test_bed_OPF.p:  an encrypted code used for function evaluation and automatic saving
                 of results in formatted ASCII-files contained in a zipped folder named 
                 algorithm_name_output_data.zip. The folder is created once a scenario of a 
                 test case for an individual system is solved for first time. Newly created 
                 results are automatically added to this folder. Before submission of results, 
                 please check whether the folder contains a total of 510 files, which should 
                 automatically have been assigned their names according to following convention:
                 (Name of your implementation)_(Number of buses denoting the system)_
		 (Number of test case)_(Number of scenario)_(xyz).txt
                 where (xyz) stands for:
                 complexity    Computing time corresponding to individual trial.
		 constraint_   Constraint violation corresponding to the global best
		    violations individual/solution.
 		 fitness       Fitness progress over function evaluations.
		 objective     Objective progress over function evaluations.
		 variables     Final best individual/solution.
                   
constraint_handling.m:   exemplary external function used for constraint handling. 
                         You can freely modify this file to include your own 
                         strategy. This routine does not affect the calculations 
			 done in test_bed_OPF.p.

rounding.m:      exemplary external function employed for rounding the real numbers used 
                 to code the discrete/binary optimization variables. You are allowed to modify 
		 this file to include your own rounding method, but the function syntax, 
		 i.e. x_out=rounding(x_in), should be kept, because it is called internally in 
                 test_bed_OPF.p before every function evaluation. If a rounded variable 
                 violates its boundary, it will be automatically fixed in test_bed_OPF.p to 
                 the corresponding limit.

Remarks
=======
This implementation has been tested using various MATLAB versions and
% hardware platforms. Feel free to contact us in case of incompatibilities.
MATLAB Parallel Computing Toolbox is needed if parallel computing is chosen in main.m
A MATPOWER installation must be on the MATLAB search path. 
This toolbox can be freely downloaded from 
http://www.pserc.cornell.edu/matpower/.

Contact
=======
Prof. István Erlich (istvan.erlich@uni-due.de) 
Dr. José L. Rueda (jose.rueda@uni-due.de)
Sebastian Wildenhues, M.Sc. (sebastian.wildenhues@uni-due.de)

Terms of use
============
These codes constitute free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the 
Free Software Foundation, either version 3 of the License, or (at your option) 
any later version.

The codes are distributed in the hope that they will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for details. 
<http://www.gnu.org/licenses/>

The decrypted version of test_bed_OPF.p, i.e. test_bed_OPF.m, will be made available
after the 2014 IEEE PES General Meeting at <http://www.uni-due.de/ean/>.
