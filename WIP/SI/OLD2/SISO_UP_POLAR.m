% WORKING DATA
file.user = 'Anne Brinkman'; % Inser computer username
file.testrun = 'TR5up_data2'; % testrun ID
file.name = strcat(file.testrun); %file name
file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\WIP\SI\',file.name,'.mat'); % file path on C:// drive
load(file.path); % import file
%% VALIDATION DATA
filed.testrun = 'TR6up_data2'; % testrun ID
filed.name = strcat(filed.testrun); %file name
filed.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\WIP\SI\',filed.name,'.mat'); % file path on C:// drive
load(filed.path); % import file
%% MAKE OBJECTS
% WORKING DATA
TR5_up = iddata([TR5up_data.filter_HR],[TR5up_data.Polaracc],0.01);
TR5_up.InputName = {'Activity Acceleration Polar'};
TR5_up.OutputName = {'Filtered HR'};
TR5_up.TimeUnit = 'seconds';
TR5_up.InputUnit = {'m/s^2'};
TR5_up.OutputUnit = {'1/60s'};                                             

% VALIDATION DATA
TR6_up = iddata([TR6up_data.filter_HR],[TR6up_data.Polaracc],0.01);
TR6_up.InputName = {'Activity Acceleration Polar'};
TR6_up.OutputName = {'Filtered HR'};
TR6_up.TimeUnit = 'seconds';
TR6_up.InputUnit = {'m/s^2'};
TR6_up.OutputUnit = {'1/60s'};    

%% SYSTEM IDENTIFICATION MODEL ARMAX                                                              
% Opt = armaxOptions;                                           
% Opt.InitialCondition = 'estimate';                            
% Opt.Focus = 'simulation';                                     
% MODEL_UP = armax(TR5_up,[1 6 0 1], Opt, 'IntegrateNoise', true);
%% SYSTEM IDENTIFICATION MODEL HW
% opt = nlhwOptions('InitialCondition', 'estimate');
% MODEL_UP = nlhw(TR5_up,[5 1 2],pwlinear('NumberofUnits',2),pwlinear('NumberofUnits',2));
%% SYSTEM IDENTIFICATION MODEL TF
Ts = 0.01;
iodelay = 0;
MODEL_UP = tfest(TR5_up,1,6,iodelay,'Ts',Ts,'Feedthrough',false)
%% SYSTEM IDENTIFICATION MODEL 
%opt = oeOptions('WeightingFilter',[0 10]);
% MODEL_UP = oe(TR5_up, [1 6 0], opt);
%% Plots
subplot(2,3,1)
hold on
title('Input Signal TR5')
plot(TR5up_data.Timestamp,TR5up_data.Polaracc)
xlabel('Time of day')
ylabel('Polar Activity Acceleration [m/s^2]')
grid on

subplot(2,3,4)
hold on
title('Input Signal TR6')
plot(TR6up_data.Timestamp,TR6up_data.Polaracc)
xlabel('Time of day')
ylabel('Polar Activity Acceleration [m/s^2]')
grid on

subplot(2,3,2)
%figure(1)
compare(TR5_up,MODEL_UP)
grid on

subplot(2,3,5)
%figure(2)
compare(TR6_up,MODEL_UP)
grid on

subplot(2,3,3)
resid(TR5_up,MODEL_UP)
grid on

subplot(2,3,6)
resid(TR6_up,MODEL_UP)
grid on
%sim(BEST_MODEL,TR_data.Polaracc)