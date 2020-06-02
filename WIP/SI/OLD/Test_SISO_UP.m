%% Data preset
file.user = 'Anne Brinkman'; % Computer username
file.testrun = '3'; % testrun ID
file.freq = 4; % Frequency 4/50/100/200 Hz
file.start = '1440'; % starting time of file [hhmm]
file.end = '1510'; % ending time of file [hhmm]

file.name = strcat('COM_testrun',file.testrun,'_',string(file.freq),'HZ_',file.start,'_till_',file.end); %file name
file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\Sensor Logs\',file.name,'.mat'); % file path on C:// drive
load(file.path); % import file
allVariables = AllVariables; % naming prefference
% https://nl.mathworks.com/help/ident/gs/identify-linear-models-using-the-command-line.html
%% SYSTEM IDENTIFICATION
% BEST LINEAR MODEL
SISO_UP = iddata([AllVariables.Pol_HR],[AllVariables.Mat_speed],0.25);
SISO_UP.InputName = {'SISO_data.Mat_speed'};
SISO_UP.OutputName = {'SISO_data.Pol_HR'}

% Set validation data properties
SISO_UP.TimeUnit = 'seconds';
SISO_UP.InputUnit = {'m/s'};
SISO_UP.OutputUnit = '1/60s';
                                                                                                
 % Import   mydata                                                        
 Upward_Step = SISO_UP  % Rename                                           
                                                                          
% Transfer function estimation                                            
 Options = tfestOptions;                                                  
 Options.WeightingFilter = [0 2.38761];                                   
 Options.InitialCondition = 'estimate';                                   
 Options.Regularization.Lambda = 0.1;                                 
 
 np = 2 %poles
 nz = 6 %zeros
 
 BEST_LINEAR_FIT = tfest(Upward_Step, np, nz, Options, 'Ts', 0.25, 'Feedthrough', true)
 %compare(SISO_UP,BEST_LINEAR_FIT)         
 %resid(SISO_UP,BEST_LINEAR_FIT)  
 
 %simout = sim(BEST_LINEAR_FIT,5)
                                     