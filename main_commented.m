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
% Test bed declarations V1.4
%
% Employing MATPOWER as underlying power flow and basic Particle Swarm  
% Evoluation (PSO) algorithm as optimization engine, you can use the 
% test bed declarations as the template shown below.
% Information is given with regard to the established data management, 
% e.g. to incorporate parts of it into your implementation.
% 
% Results will be buffered and agglomerated automatically for storage to 
% formatted ASCII-files. Refer to problem definitions and implementation 
% guidelines for details.
%
% Note:
% This implementation has been tested using various MATLAB versions and
% hardware platforms. Feel free to contact us in case of incompatibilities.
% A MATPOWER installation must be on the MATLAB search path.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
clc
%--------------------------------------------------------------------------
%% Structure containing procedual information
global proc
%--------------------------------------------------------------------------
% Fieldname     Description
%--------------------------------------------------------------------------
% algorithm_    Name of your implementation (for post-processing purposes).
% name
%--------------------------------------------------------------------------
% consider_     Whether or not to consider selected contingencies. 
% contingencies In the current implementation, this value is set to 1 and
%               cannot be modified. That is, in 57, 118 and 300 bus
%               systems, contingencies will be included in the framework.
%               Regarding this, an intervention scheme ensures that tailing 
%               contingencies are bypassed after conducting constraint 
%               handling as soon as any violation has been detected for 
%               intermediate contingencies. This strongly benefits the 
%               computational efficiency and quality of solutions for a 
%               given number of function evaluations while ensuring 
%               comparability between different implementations.
%--------------------------------------------------------------------------
% contingencies Branches representing contingency elements.
%               Systems:
%               57, 118 and 300 bus
%--------------------------------------------------------------------------
% i_eval        Function evaluation counter.
%               This value is set after every power flow calculation.
%               You can retrieve its local value (cf. parallel processing) 
%               from everywhere you want, e.g. to dynamically adjust your 
%               constraint handling method.
%--------------------------------------------------------------------------
% i_p           Current particle under consideration.
%--------------------------------------------------------------------------
% i_run         Current trail.
%--------------------------------------------------------------------------
% init_flag     Flag for internal purposes.
%--------------------------------------------------------------------------
% last_         Function evaluation denoting the last successful update
% improvement   of the global best solution. This refers to the minimum
%               fitness function value subsequent to the internal static 
%               penalty constraint handling.
%--------------------------------------------------------------------------
% n_contingency Number of contingencies for individual systems.
%--------------------------------------------------------------------------
% n_eval        Number of function evaluations.
%               Fixed values (for every testcase and scenario):
%               10e3:  41 bus (WPP) system
%               50e3:  57 bus system
%               100e3: 118 bus system
%               150e3: 300 bus system
%--------------------------------------------------------------------------
% n_run         Number of trails.
%               31 for every system, test case and scenario.
%--------------------------------------------------------------------------
% n_scenario    Number of scenarios for individual test case.
%--------------------------------------------------------------------------
% n_test_case   Number of test cases for individual system.
%--------------------------------------------------------------------------
% noticed       Flag for internal purposes.
%--------------------------------------------------------------------------
% opt           Vector containing MATPOWER options.
%--------------------------------------------------------------------------
% pop_size      Number of individuals entering the function evaluation.
%               Note that this value does not necessarily equal the total 
%               number of individuals. You are free to reset this value 
%               wherever you want, provided that consistency exists between
%               pop_size and the number of individuals being generated.
%--------------------------------------------------------------------------
% refresh       Frequency at which intermediate results of individual
%               computational cores/threads are updated within the MATLAB 
%               command window. The format is as follows
%               for 57, 118 and 300 bus systems:
%               fprintf('trail: %5d,     i_eval: %5d,...   
%               o_best: %12.7f,     f_best: %12.7f\n',...
%               proc.i_run,proc.i_eval,best_objective,best_fitness);
%
%               for 41 bus (WPP) system:
%               fprintf('trail: %5d,     i_eval: %5d,...   
%               o_best: %12.7f,     f_best: %12.7f,     delta_Q_PCC\n',...
%               proc.i_run,proc.i_eval,best_objective,best_fitness,...
%               Q_slack);
%
%               Q_slack refers to error delta_Q_PCC between the reactive 
%               power reference and the actual reactive power at the point 
%               of common coupling (PCC). If (abs(Q_slack)<eps), this value 
%               differs from that entering the constraint vector, 
%               i.e. delta_Q_PCC_cv=0 due to tolerance eps=0.1. 
%--------------------------------------------------------------------------
% run_          Whether or not to to run independent trails independently 
% in_parallel   from each other using multiple computational cores/threads.
%               In each case, starting individual trails involves the 
%               random number generation seed to be initialized according
%               to "rand(''state'',(trial=proc.i_run)*sum(100*clock))".
%               This option requires a licensed installation of MATLAB 
%               Parallel Computing Toolbox.
%--------------------------------------------------------------------------                                                 
% scenario      Scenario.
%               Possible values:
%               1:    57, 118 and 300 bus systems
%               1-96: 41 bus (WPP) system
%--------------------------------------------------------------------------
% show_lf_info  Whether or not to display certain information in case of 
%               non-converging power flow, or in case of interventions 
%               that occurred due to individuals' infeasibility.
%--------------------------------------------------------------------------
% stop_         Flag indicating the last scenario for current test case.
% scenario      This value should not be reset.
%--------------------------------------------------------------------------
% stop_         Flag indicating the last test case for current system.
% test_case     This value should not be reset.
%--------------------------------------------------------------------------
% system        Number of buses denoting a system.
%               Possible values:
%               41 (WPP), 57, 118, 300
%--------------------------------------------------------------------------
% t1            Starting time for individual trails.
%               This value is relevant to post-processing and should 
%               not be reset.
%--------------------------------------------------------------------------
% test_case     Optimization problem definition.
%               1: Optimal Reactive Power Dispatch (ORPD)
%                  Objective: minimize(Active Power Losses) 
%                             with respect to no-contingency conditions
%
%                                        Systems
%                  57, 118 and 300 bus         41 bus
%
%                  Subject to:
%                  g=[v_load-v_max,...         g=[v-v_max,...
%                     v_min-v_load,...            v_min-v,...
%                     s_branch-s_branch_max,...   s_branch-s_branch_max,...
%                     Q_gen-Q_gen_max,...         (abs(Q_slack)<eps)],
%                     Q_gen_min-Q_gen]
%
%                  establishing from:
%                  n_constraints=...           n_constraints=...
%                       ps.n_load+...               ps.n_bus+...
%                       ps.n_load+...               ps.n_bus+...
%                       numel(mpc{i_c}.branch...    numel(mpc{i_c}.branch...
%                          (:,1))+...                  (:,1))+...
%                       ps.n_gen_VS+...             1
%                       ps.n_gen_VS
%                  numbers of system elements
%                  for every contingency i_c.
%
%                  Individuals are defined as:
%                  x=[u_gen_set,...            x=[Q_WT,...            
%                     tap_OLTC,...                tap_OLTC,...
%                     X_bin_shunt]                X_cont_shunt,...
%                                                 X_disc_shunt],
%
%                  establishing from:
%                                   ps.D=ps.n_gen_VS+...
%                                        ps.n_OLTC+...
%                                        ps.n_SH
%                  numbers of variables/components.
%                  
%                  Note: 
%                  Q_slack represents error delta_Q_PCC between the
%                  reactive power reference and the actual reactive power                                 
%                  at the PCC. If (abs(Q_slack)<eps), delta_Q_PCC_cv=0 
%                  will enter the constraint vector due to eps=0.1. 
%                  The reference is modeled as imaginary part of a dummy 
%                  load at 220 kV slack bus 1, whose real component equals
%                  WPP's active power output for the current scenario.
%                  
%                  You can access individuals' components explicitly for 
%                  modifications. For instance, in terms of indexes, they 
%                  are defined for the ORPD problem and all systems as:
%                                   x=[ps.i_gen_VS_opt,...     
%                                      ps.i_OLTC_opt,...
%                                      ps.i_SH_opt]
%
%                  However, by default, the test bed declaration will 
%                  automatically provide all the required information to 
%                  your implementation in order to enable generation of 
%                  individuals within the specified min/max bounds.
%                  It should be pointed out that continuous components/
%                  variables are, in principle, not restricted to the 
%                  minimum and maximum bounds as defined by ps.x_min and 
%                  ps.x_max, respectively. Rather, they are allowed to 
%                  temporarily exceed these bounds, whereas existing final 
%                  violations will be subject to examiners' penalizations.
%                  In contrast, discrete and binary components/variables, 
%                  such as on-load tap changers and shunt elements, 
%                  are restricted to their valid control range and will be 
%                  fixed when exeeding a corresponding physical bound, 
%                  e.g. the highest possible OLTC tap postion.
%                  
%               2: Optimal Active-Reactive Power Dispatch (OARPD).
%                  Objective: minimize(Overall Fuel Cost)
%                             with respect to no-contingency conditions
%                  
%                                        Systems
%                  57, 118 and 300 bus
% 
%                  Subject to:
%                  g=[P_slack-P_slack_max,...
%                     v_load-v_max,...         
%                     v_min-v_load,...            
%                     s_branch-s_branch_max,...
%                     Q_gen-Q_gen_max,...  
%                     Q_gen_min-Q_gen],
%
%                  establishing from:
%                  n_constraints=1+...
%                       ps.n_load+...
%                       ps.n_load+...
%                       numel(mpc{i_c}.branch...
%                          (:,1))+...
%                       ps.n_gen_VS+...
%                       ps.n_gen_VS
%                  numbers of system elements
%                  for every contingency i_c.
%                  
%                  Individuals are defined as:
%                  x=[P_gen_set,...
%                     u_gen_set,...
%                     tap_OLTC,...               
%                     X_bin_shunt],
%
%                  establishing from:
%                  ps.D=ps.n_gen_PG+...
%                       ps.n_gen_VS+...
%                       ps.n_OLTC+...
%                       ps.n_SH;
%                  numbers of 
%                  variables/components.
%
%                  In terms of indexes:
%                  x=[ps.i_gen_PG_opt,...
%                     ps.i_gen_VS_opt,...     
%                     ps.i_OLTC_opt,...
%                     ps.i_SH_opt]
%--------------------------------------------------------------------------
% test_         String of test case (for post-processing purposes).
% case_name
%--------------------------------------------------------------------------
% test_         Flag for internal purposes.
% case_save
%--------------------------------------------------------------------------
%% Structure containing power system and optimization related information
global ps
%--------------------------------------------------------------------------
% Fieldname     Description
%--------------------------------------------------------------------------
% D             Dimensionality of the individual problem, i.e. test case.
%--------------------------------------------------------------------------
% D_cont        Number of continuous problem dimensions.
%--------------------------------------------------------------------------
% D_disc        Number of discrete/binary problem dimensions.
%--------------------------------------------------------------------------
% OLTC_max      On-load tap changers' upper voltage limit (p.u.).
%--------------------------------------------------------------------------
% OLTC_min      On-load tap changers' lower voltage limit (p.u.).
%--------------------------------------------------------------------------
% OLTC_         On-load tap changers' voltage control range (p.u.).
% range_val
%--------------------------------------------------------------------------
% OLTC_         On-load tap changers' equidistant tap positions (integers).
% steps
%--------------------------------------------------------------------------
% OLTC_         On-load tap changers' additional voltages (p.u.).     
% steps_val
%--------------------------------------------------------------------------
% SH_bus        Whether or not controllable/switchable shunt elements are 
%               connected to individual buses.
%--------------------------------------------------------------------------
% SH_max        Controllable/switchable shunts' upper reactive power limit.
%--------------------------------------------------------------------------
% SH_min        Controllable/switchable shunts' lower reactive power limit.
%--------------------------------------------------------------------------
% SH_range_val  Shunt elements' control/switching range.
%--------------------------------------------------------------------------
% SH_steps      Switchable shunts' discrete step instances (integers).
%               Equal to [0 1] for controllable shunt elements.
%--------------------------------------------------------------------------
% SH_steps_val  Shunt elements' control/switching range (Mvar).
%--------------------------------------------------------------------------
% gen_          Slack generator's upper active power output limit.
% PG_SL_max
%--------------------------------------------------------------------------
% gen_          Generators' upper active power output limit.
% PG_nonSL_max
%--------------------------------------------------------------------------
% gen_          Generators' lower active power output limit.
% PG_nonSL_min  Note: gen_PG_nonSL_min=0.3xgen_PG_nonSL_max
%--------------------------------------------------------------------------
% gen_Q_max     Generators' upper reactive power output limit.
%--------------------------------------------------------------------------
% gen_Q_min     Generators' lower reactive power output limit.
%--------------------------------------------------------------------------
% i_OLTC_opt    Individuals' indexes of on-load tap changers.
%--------------------------------------------------------------------------
% i_SH_opt      Individuals' indexes of controllable/switchable 
%               shunt elements.
%--------------------------------------------------------------------------
% i_SH_v        Shunt bus indexes.
%--------------------------------------------------------------------------
% i_bus_v       Bus indexes.
%--------------------------------------------------------------------------
% i_gen_SL      Slack generator bus index.
%--------------------------------------------------------------------------
% i_gen_VS_opt  Individuals' indexes of generators and wind turbines 
%               receiving voltage and reactive power setpoints,
%               respectively.
%--------------------------------------------------------------------------
% i_gen_v       Generator bus indexes.
%--------------------------------------------------------------------------
% i_gen_v0      Load bus indexes/names.
%--------------------------------------------------------------------------
% i_gen_v_nonSL Generator bus indexes/names (except slack).
%--------------------------------------------------------------------------
% i_load_nz_v   Load bus indexes.
%               Since wind turbines are modeled as loads, these correspond
%               to generator bus indexes in 41 bus (WPP) system.
%--------------------------------------------------------------------------
% n_OLTC        Number of on-load tap changers.
%--------------------------------------------------------------------------
% n_SH          Number of controllable/switchable shunt elements.
%--------------------------------------------------------------------------
% n_bus         Number of buses.
%--------------------------------------------------------------------------
% n_gen_PG      Number of generators receiving active power setpoints.
%               Relevant only for test case 2 (OARPD problem) in 57, 118 and 
%               300 bus systems.
%--------------------------------------------------------------------------
% n_gen_VS      Number of generators and wind turbines receiving voltage
%               and reactive power setpoints, respectively.
%--------------------------------------------------------------------------
% n_load        Number of loads.
%--------------------------------------------------------------------------
% n_steps_OLTC  Number of on-load tap changers' tap positions.
%--------------------------------------------------------------------------
% n_steps_SH    Number of switchable shunts' discrete steps.
%               Equal to 2 also for controllable shunt elements.
%--------------------------------------------------------------------------
% v_max         Maximum voltage magnitudes.
%               57, 118 and 300 bus systems: load buses only
%               41 bus (WPP) system: every bus.
%--------------------------------------------------------------------------
% v_min         Minimum voltage magnitudes.
%               57, 118 and 300 bus systems: load buses only
%               41 bus (WPP) system: every bus   
%--------------------------------------------------------------------------
% x_max         Individuals' upper bounds.
%--------------------------------------------------------------------------
% x_min         Individuals' lower bounds.
%--------------------------------------------------------------------------
% x_type        Vector classifying individuals' components according to:
%               0: Generator voltage and wind turbine reactive power
%                  setpoints, respectively (continuous)
%               1: On-load tap changer positions (discrete)
%               2: Shunt elements (discrete and binary)
%--------------------------------------------------------------------------
%% Cell array containing structures of system data
%--------------------------------------------------------------------------
global mpc
%--------------------------------------------------------------------------
% Usage
% mpc{i_c}.fieldname, where i_c 
% denotes the contingency index.
% i_c>1 for 57, 118, 300 systems.
% Refer to the MATPOWER manual 
% for details.
%
% For 41 (WPP) system, 
% additional fields exist:
%--------------------------------------------------------------------------
% Fieldname     Description
%--------------------------------------------------------------------------
% WPP_dispatch  Day profile of active power dispatch for individual wind
%               turbines.
% WPP_q_ref_PCC Day profile of WPP reactive power requirement at PCC.
%--------------------------------------------------------------------------
%% Cell array containing structures of intermediate results
%--------------------------------------------------------------------------
global res
%--------------------------------------------------------------------------
% Fieldname     Description
%--------------------------------------------------------------------------
% complexity    Computing time corresponding to individual trial.
%--------------------------------------------------------------------------
% constraint_   Constraint violation corresponding to the global best
% violations    individual/solution.
%--------------------------------------------------------------------------
% fitness       Fitness progress over function evaluations.
%--------------------------------------------------------------------------
% intermediate_ Progress over function evaluations corresponding to the
% variables     global best individual/solution.
%--------------------------------------------------------------------------
% objective     Objective progress over function evaluations.
%--------------------------------------------------------------------------
% variables 	Best individual/solution.
%--------------------------------------------------------------------------
% For 41 (WPP) system, 
% additional fields exist:
%--------------------------------------------------------------------------
% delta_Q_PCC   Error between the reactive power reference and the actual 
%               reactive power at the PCC. If (abs(Q_slack)<eps), 
%               this value differs from that entering the constraint 
%               vector. It is printed in the MATLAB command window.
%--------------------------------------------------------------------------
% voltages      Bus voltages corresponding to the best individual/solution.
%--------------------------------------------------------------------------
%% Control parameters
%--------------------------------------------------------------------------
% Name of your implementation.
% This label is used both for
% the function call via handle
% algorithm_hd, as well as for
% designating formatted ASCII 
% files and folders. Therefore,
% type in the name of your 
% implementation's *.m-file.
algorithm_name='psopt';
% Function handle to your implementation.
algorithm_hd=str2func(algorithm_name);
% Function handle to test bed declarations.
test_bed_OPF_hd=str2func('test_bed_OPF');
% Possible values for system: 
% 41 (WPP), 57, 118 and 300
system=41;
pop_size=1;
run_in_parallel=0;
show_lf_info=0;
refresh=500;
%--------------------------------------------------------------------------
%% Argument cell to be passed to test bed declarations
%--------------------------------------------------------------------------
args{1}=system;
args{2}=show_lf_info;
args{3}=pop_size;
args{4}=refresh;
args{5}=algorithm_name;
args{6}=run_in_parallel;
args{7}=[];
args{8}=[];
%--------------------------------------------------------------------------
%% Parallelization
%--------------------------------------------------------------------------
v=ver;
% Whether or not MATLAB parallel computing toolbox is installed.
toolbox_installed=any(strcmp('Parallel Computing Toolbox',{v.Name}));
% If yes, the cluster 
% is deactivated at first.
if toolbox_installed
    isOpen=matlabpool('size')>0;
    if isOpen
        matlabpool close
    end
% If not, trails will be 
% processed in sequence.
else
    run_in_parallel=0;
end

% Activation of cluster 
% consisting of NumWorkers 
% computational cores/threads.
if run_in_parallel
    NumWorkers=3;
    local_sched=findResource('scheduler','type','local');
    local_sched.ClusterSize=NumWorkers;
    isOpen=matlabpool('size')>0;
    if ~isOpen
        matlabpool(NumWorkers);
    end
end
%--------------------------------------------------------------------------
%% Main procedure
%-----------------------------Test case loop-------------------------------
% In case of 57, 
% 118 and 300 bus 
% systems, you can 
% skip test case 1 
% (ORPD) and directly 
% run test case 2 
% (OARPD) by setting 
% i=1.
i=0;
stop_test_case=0;
while ~stop_test_case
    i=i+1;
    %-------------------------Scenario loop--------------------------------
    % In case of 41 
    % bus (WPP) system, 
    % you can run 
    % individual 
    % scenarios by 
    % setting 0<j<95.
    j=0;
    stop_scenario=0;
    while ~stop_scenario
        j=j+1;
        % Initialization of power system and optimization related
        % quantities for current test case i and scenario j.
        [stop_test_case,stop_scenario,err,obs]=test_bed_OPF_hd(i,j,1,args);
        args{7}=stop_test_case;
        args{8}=stop_scenario;
        if ~err
            %----Stochastically independent trials loop--------------------
            % The random number generation seed will be 
            % initialized according to "rand(''state'',...
            % (trial=k)*sum(100*clock))".
            % 
            % If running in parallel, individual trails 
            % will not be processed in any ordered sequence, 
            % which becomes obvious from intermediate results 
            % being printed in MATLAB command window output.
            
            % To prematurely stop running the procedure
            % in terms of independent trials, you may use
            % a statement as the following.
            % This will be without effect on output of 
            % intermediate results to formatted ASCII files.
%             %%%%%%%%%%%%%
%             proc.n_run=3;
%             %%%%%%%%%%%%%
            parfor k=1:proc.n_run
                test_bed_OPF_hd(i,j,k,args);
                % Call to your implementation.
                feval(algorithm_hd,test_bed_OPF_hd,i,j,k,args);
                fprintf('Run %d finished.\n',k);
            end
            %----Stochastically independent trials loop--------------------
            % Deinitialization.
            % Value 987 serves as control flag 
            % and should not be modified.
            test_bed_OPF_hd(i,j,987,args);
        end
    end
    %-------------------------Scenario loop--------------------------------
end
%-----------------------------Test case loop-------------------------------
%% Parallelization
% Deactivation of 
% shared-memory session.
if run_in_parallel
    isOpen=matlabpool('size')>0;
	if isOpen
        matlabpool close
	end
end
%--------------------------------------------------------------------------