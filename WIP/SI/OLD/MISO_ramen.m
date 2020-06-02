%load('C:\Users\Anne Brinkman\MATLAB Drive\Train Smart\Sensor Logs\COM_testrun3_4HZ_1439_till_1613_geenpolarEcgAcc.mat')
%load('C:\Users\Anne Brinkman\Downloads\COM_testrun4_4HZ_1010_till_1148_timegap_10_42_28_till_10_50_35.mat')
load('C:\Users\Anne Brinkman\MATLAB Drive\Train Smart\Sensor Logs\COM_testrun5_4HZ_0805_till_0910.mat')
clc
fs = 200;
%% Band pass filter
%Acc Matlab
SN1 = AllVariables(:,1).Variables; % Measured signal
SN2 = AllVariables(:,2).Variables; % Measured signal
SN3 = AllVariables(:,3).Variables; % Measured signal
%Acc Polar
SN4 = AllVariables(:,4).Variables; % Measured signal
SN5 = AllVariables(:,5).Variables; % Measured signal
SN6 = AllVariables(:,6).Variables; % Measured signal
% Band pass frequency range is between 0.5 and 30 Hz. 
f1 = 0.5; f2=30;
% Normalized pass frequency ranges (Wn1, Wn2):
Wn1=f1/(0.5*fs);      
Wn2=f2/(0.5*fs);      
% Second order (N=2) filter passes all signal components within           
% a frequency range of: [Wn1 Wn2]
N=2;
% Compute second order filter coefficients:
[b, a]    = butter(N, [Wn1, Wn2], 'bandpass');
%matlab 
filter_F1  = filter(b, a, SN1);
filter_F2  = filter(b, a, SN2);
filter_F3  = filter(b, a, SN3);
%Polar
filter_F4  = filter(b, a, SN4);
filter_F5  = filter(b, a, SN5);
filter_F6  = filter(b, a, SN6);
% Take FFT... of the filtered signal: filter_F
%% creating single activity model
a_f = sqrt(filter_F1.^2+filter_F2.^2+filter_F3.^2);%taking the norm
a_m = smoothdata(a_f,'movmedian','SmoothingFactor',0.4);

a_f2 = sqrt(filter_F4.^2+filter_F5.^2+filter_F6.^2);%taking the norm polar
a_m2 = smoothdata(a_f2,'movmedian','SmoothingFactor',0.40);

MIMOM_data= addvars(AllVariables,a_m)
MISOM = iddata([MIMOM_data.Pol_HR],[MIMOM_data.Mat_speed, MIMOM_data.a_m],0.25);
MISOM.InputName = {'MIMOM_data.Mat_speed';'MIMOM_data.a_m'};
MISOM.OutputName = {'MIMOM_data.Pol_HR'} 
get(MISOM)

MIMO_data= addvars(AllVariables,a_m2)
MISO = iddata([MIMO_data.Pol_HR],[MIMO_data.Mat_speed, MIMO_data.a_m2],0.25);
MISO.InputName = {'MIMO_data.Mat_speed';'MIMO_data.a_m2'};
MISO.OutputName = {'MIMO_data.Pol_HR'} 
get(MISO)

plot(MISO(:,1,1))
plot(MISO(:,1,2))