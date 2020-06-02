%clc; clf; clear;
%load('C:\Users\lphoo\MATLAB Drive\Train Smart\Sensor Logs\Fitness Test 1\COM_MaxHRTest.mat');

figure(1);
title("Speed and HR over Time")
hold on;
xlabel("Time of Day")
ylabel("Hartrate [/(60s)]")
plot(AllVariables.Timestamp,AllVariables.Pol_HR, 'blue')
yyaxis right
ylabel("Running vel [km/h]")
plot(AllVariables.Timestamp,(3.6.*AllVariables.Mat_speed), 'red')

