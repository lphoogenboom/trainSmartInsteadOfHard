clc
clear all
%% Data preset
file.user = 'Anne Brinkman'; % Computer username
file.testrun = '3'; % testrun ID
file.freq = 4; % Frequency 4/50/100/200 Hz
file.start = '1510'; % starting time of file [hhmm]
file.end = '1530'; % ending time of file [hhmm]

file.name = strcat('COM_testrun',file.testrun,'_',string(file.freq),'HZ_',file.start,'_till_',file.end); %file name
file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\Sensor Logs\',file.name,'.mat'); % file path on C:// drive
load(file.path); % import file
allVariables = AllVariables; % naming prefference
% https://nl.mathworks.com/help/ident/gs/identify-linear-models-using-the-command-line.html
%% SYSTEM IDENTIFICATION 
% BEST LINEAR MODEL
SISO_DOWN = iddata([AllVariables.Pol_HR],[AllVariables.Mat_speed],0.25);
SISO_DOWN.InputName = {'Speed'};
SISO_DOWN.OutputName = {'HR'}  

% Set validation data properties
SISO_DOWN.TimeUnit = 'seconds';
SISO_DOWN.InputUnit = {'m/s'};
SISO_DOWN.OutputUnit = '1/60s';
                                                  
 % Import   DOWNWARD_STEP  
 DOWNWARD_STEP = SISO_DOWN                              
                                                      
% Transfer function estimation                         
 Options = tfestOptions;                               
 Options.Display = 'on';                               
 Options.WeightingFilter = [0 2.01062];                
 Options.InitialCondition = 'estimate';                
                                                       
BEST_LINEAR_DOWN = tfest(DOWNWARD_STEP, 4, 4, Options, 'Ts', 0.25)                
%  Opt = bjOptions;  %Box-Jenkins Polynomial model                                
%  Opt.InitialCondition = 'estimate';                
%  %Opt.WeightingFilter = 0 2.0;                      
%  Opt.Focus = 'simulation';                         
%  nb = 4; %zeros                                          
%  nc = 3; %zeros noise                                          
%  nd = 2; %poles noise                                          
%  nf = 4; %poles                                          
%  nk = 1; %delay                                        
%  BEST_LINEAR_DOWN = bj(DOWNWARD_STEP,[nb nc nd  nf nk], Opt)
t = tiledlayout(2,2);
compare(SISO_DOWN, BEST_LINEAR_DOWN)  
%resid(SISO_DOWN, BEST_LINEAR_DOWN)
