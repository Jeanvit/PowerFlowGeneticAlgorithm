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
global proc
global ps
global mpc
global res
algorithm_name='psopt';
algorithm_hd=str2func(algorithm_name);
test_bed_OPF_hd=str2func('test_bed_OPF');
system=57;
pop_size=100;
run_in_parallel=0;
show_lf_info=0;
refresh=100;

args{1}=system;
args{2}=show_lf_info;
args{3}=pop_size;
args{4}=refresh;
args{5}=algorithm_name;
args{6}=run_in_parallel;
args{7}=[];
args{8}=[];

v=ver;
toolbox_installed=any(strcmp('Parallel Computing Toolbox',{v.Name}));
if toolbox_installed
    isOpen=matlabpool('size')>0;
    if isOpen
        matlabpool close
    end
else
    run_in_parallel=0;
end

if run_in_parallel
    NumWorkers=3;
    local_sched=findResource('scheduler','type','local');
    local_sched.ClusterSize=NumWorkers;
    isOpen=matlabpool('size')>0;
    if ~isOpen
        matlabpool(NumWorkers);
    end
end

i=0;
stop_test_case=0;
while ~stop_test_case
    i=i+1;
    j=0;
    stop_scenario=0;
    while ~stop_scenario
        j=j+1;
        [stop_test_case,stop_scenario,err,obs]=test_bed_OPF_hd(i,j,1,args);
        args{7}=stop_test_case;
        args{8}=stop_scenario;
        if ~err
            parfor k=1:proc.n_run
                test_bed_OPF_hd(i,j,k,args);
                feval(algorithm_hd,test_bed_OPF_hd,i,j,k,args);
                fprintf('Run %d finished.\n',k);
            end
            test_bed_OPF_hd(i,j,987,args);
        end
    end
end

if run_in_parallel
    isOpen=matlabpool('size')>0;
	if isOpen
        matlabpool close
	end
end