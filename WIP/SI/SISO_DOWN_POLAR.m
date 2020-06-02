%% WORKING DATA
file.user = 'Anne Brinkman'; % Computer username
file.testrun = 'TR5down_data2'; % testrun ID
file.name = strcat(file.testrun); %file name
file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\WIP\SI\',file.name,'.mat'); % file path on C:// drive
load(file.path); % import file
%% VALIDATION DATA
filed.testrun = 'TR6down_data2'; % testrun ID
filed.name = strcat(filed.testrun); %file name
filed.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\WIP\SI\',filed.name,'.mat'); % file path on C:// drive
load(filed.path); % import file
%% MAKE OBJECTS
% WORKING DATA
TR5_down = iddata([TR5down_data.filter_HR],[TR5down_data.Polaracc],0.01);
TR5_down.InputName = {'Activity Acceleration Polar'};
TR5_down.OutputName = {'Filtered HR'};
TR5_down.TimeUnit = 'seconds';
TR5_down.InputUnit = {'m/s^2'};
TR5_down.OutputUnit = {'1/60s'};                                             

% VALIDATION DATA
TR6_down = iddata([TR6down_data.filter_HR],[TR6down_data.Polaracc],0.01);
TR6_down.InputName = {'Activity Acceleration Polar'};
TR6_down.OutputName = {'Filtered HR'};
TR6_down.TimeUnit = 'seconds';
TR6_down.InputUnit = {'m/s^2'};
TR6_down.OutputUnit = {'1/60s'};                                               

%% SYSTEM IDENTIFICATION MODEL ARMAX BEST
Opt = armaxOptions;                     
DOWN_model = armax(TR5_down,[5 5 4 2])
%% SYSTEM IDENTIFICATION MODEL BOX JENKINS POLYNOMIAL                     
% Opt = bjOptions;                             
% Opt.InitialCondition = 'estimate';           
% nb = 6;   %zeros+1                       6            
% nc = 4;   %zeros+1 noise input           2                        
% nd = 0;   %poles noise input             1                      
% nf = 6;   %poles                         6          
% nk = 2;   %delay                         1          
% DOWN_model = bj(TR5_down,[nb nc nd  nf nk], Opt);
%% SYSTEM IDENTIFICATION TF
% Options = tfestOptions;                                                             
% Options.InitialCondition = 'estimate';                                                        
% DOWN_model = tfest(TR5_down, 6, 6, Options, 'Ts', 0.01)
%% Plots
subplot(2,3,1)
hold on
title('Input Signal TR5')
plot(TR5down_data.Timestamp,TR5down_data.Polaracc)
xlabel('Time of day')
ylabel('Polar Activity Acceleration [m/s^2]')
grid on

subplot(2,3,4)
hold on
title('Input Signal TR6')
plot(TR6down_data.Timestamp,TR6down_data.Polaracc)
xlabel('Time of day')
ylabel('Polar Activity Acceleration [m/s^2]')
grid on

subplot(2,3,2)
%figure(1)
compare(TR5_down,DOWN_model)
grid on

subplot(2,3,5)
%figure(2)
compare(TR6_down,DOWN_model)
grid on

subplot(2,3,3)
resid(TR5_down,DOWN_model)
grid on

subplot(2,3,6)
resid(TR6_down,DOWN_model)
grid on
figure(2)

% sim(DOWN_model,TR5down_data.Polaracc)
