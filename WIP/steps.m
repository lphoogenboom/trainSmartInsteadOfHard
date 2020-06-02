%clear all
clc
%load COM_MaxHRTest_200HZ_1354_till_1409.mat
%load('C:\Users\Anne Brinkman\MATLAB Drive\Train Smart\Sensor Logs\COM_MaxHRTest_200HZ_1354_till_1409.mat')
dt = 5 %ms ;

Yacc = AllVariables.Mat_Acc_Y;
yacc = addvars(AllVariables, Yacc);
[pks, locs] = findpeaks(Yacc,'MinPeakDistance', 50); 
timeBetweenPeaks = [0;diff(locs)*dt./1000]

%figure(2)
%plot(Yacc)

%figure(3)
%findpeaks(Yacc)

t = tiledlayout(1,2);
%nexttile
%title("Acceleration - Y")
%hold on;
%plot(AllVariables.Timestamp,Yacc)
%xlabel('Time of Day')
%ylabel('Acceleration [m/s^2]')

%nexttile
%title("Peaks Acceleration - Y")
%hold on;
%plot(AllVariables.Timestamp(locs),pks)
%xlabel('Time of Day')
%ylabel('Acceleration [m/s^2]')

nexttile
title("Step Time")
hold on;
plot(AllVariables.Timestamp(locs),timeBetweenPeaks, 'red')
xlabel('Time of Day')
ylabel('Time [s]')

nexttile
title("Step Frequency")
hold on;
plot(AllVariables.Timestamp(locs),1./timeBetweenPeaks, 'red')
xlabel('Time of Day')
ylabel('Frequency [1/s]')

