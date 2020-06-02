clear; clc; clf;
%% Importing and Processing Data

load("C:\Users\lphoo\MATLAB Drive\Train Smart\Sensor Logs\COM_MaxHRTest_4HZ_1354_till_1409.mat");

time = Allvariables.Timestamp;
deltaTimes = seconds(diff(time));
sampleRate = 1/mean(deltaTimes);

SLong = smooth(Allvariables.Mat_longitude, 0.005 , 'moving');
SLat = smooth(Allvariables.Mat_latitude, 0.005 ,'moving');

%% Data Visual Representation

subplot(2,1,1)
plot(Allvariables.Mat_longitude, Allvariables.Mat_latitude)
subplot(2,1,2)
plot(SLong,SLat)