clear; clc;
%% Data preset
file.user = 'lphoo'; % Computer username [ lphoo | Anne Brinkman ]
file.testrun = '5'; % testrun ID
file.freq = 100; % Frequency 4/50/100/200 Hz
file.start = '0756'; % starting time of file [hhmm]
file.end = '0910'; % ending time of file [hhmm]

file.name = strcat('COM_testrun',file.testrun,'_',string(file.freq),'HZ_',file.start,'_till_',file.end); %file name
file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\Sensor Logs\',file.name,'.mat'); % file path on C:// drive
% load(file.path); % import file
allVariables = AllVariables; % naming prefference

% traject imestamps
traj.time = allVariables.Timestamp;
traj.duration = length(traj.time); %run duration
traj.freqs = file.freq*(0:(traj.duration/2))/traj.duration;

% traject accelerations
traj.acc.x = {allVariables.Mat_Acc_X};
traj.acc.y = {allVariables.Mat_Acc_Y};
traj.acc.z = {allVariables.Mat_Acc_Z};
traj.acc.norm = vecnorm(transpose([cell2mat(traj.acc.x) cell2mat(traj.acc.y) cell2mat(traj.acc.z)]));

% traject velocity
traj.vel.norm = [allVariables.Mat_speed];

% traject heartrate
traj.hr.norm = allVariables.Pol_HR;

clear AllVariables allVariables
%% Fast Fourrier Transformrms
traj.vel.fft = fft(traj.vel.norm);
traj.acc.fft = fft(traj.acc.norm);
traj.hr.fft = fft(traj.hr.norm); 
%% Visual Representation
clf;

% scaling data for plotting
traj.acc.mag = abs(traj.acc.fft/traj.duration);
traj.acc.magPos = traj.acc.mag(1:(1+traj.duration/2));

traj.vel.mag = abs(traj.vel.fft/traj.duration);
traj.vel.magPos = traj.vel.mag(1:(1+traj.duration/2));

traj.hr.mag = abs(traj.hr.fft/traj.duration);
traj.hr.magPos = traj.hr.mag(1:(1+traj.duration/2));


% plotting
subplot(2,4,1) % Acceleration time domain
plot(traj.time,traj.acc.norm, 'color', 	'#EDB120' )
title('Acc Norm Time Domain')
ylabel('Acceleration [m s^{-2}]')
grid on

subplot(2,4,2) % Velocity time domain
plot(traj.time,traj.vel.norm, 'color', '#77AC30')
title('Vel Norm Time Domain')
ylabel('Velocity [m s^{-1}]')
grid on

subplot(2,4,3) % HR time domain
plot(traj.time,traj.hr.norm, 'color' , 	'#4DBEEE')
title('HR Norm Time Domain')
ylabel('Heartbeat Rate [60 s^{-1}]')
grid on

subplot(2,4,4) % HR spectogram
traj.hr.spectorgram = spectrogram(traj.hr.norm);
spectrogram(traj.hr.norm);
title('HR Spectrogram');
grid on

subplot(2,4,5) % Acceleration FFT
semilogy(traj.freqs,traj.acc.magPos, 'color', 	'#EDB120' )
title('Acc Norm FFT')
ylabel('|Magnitude|')
xlabel('Frequency \omega')
grid on

subplot(2,4,6) % Velocity FFT
semilogy(traj.freqs,traj.vel.magPos, 'color', '#77AC30');
title('Vel Norm FFT')
ylabel('|Magnitude|')
xlabel('Frequency \omega')
grid on

subplot(2,4,7) % HR FFT
semilogy(traj.freqs,traj.hr.magPos, 'color' , 	'#4DBEEE');
title('HR Norm FFT')
ylabel('|Magnitude|')
xlabel('Frequency \omega')
grid on

disp('Done')