clear all
clc
%load C:\Users\lphoo\MATLAB Drive\Train Smart\Sensor Logs\COM_MaxHRTest_3HZ_1354_till_1409.mat
%load('C:\Users\Anne Brinkman\MATLAB Drive\Train Smart\Sensor Logs\COM_MaxHRTest_3HZ_1354_till_1409.mat')
%load('C:\Users\thami\MATLAB Drive\Train Smart\Sensor Logs\COM_MaxHRTest_3HZ_1354_till_1409.mat')
load('C:\Users\Anne Brinkman\MATLAB Drive\Train Smart\Sensor Logs\COM_testrun5_4HZ_0805_till_0910.mat')
dt = 0.33333; %s = sample time
%% Filter Lowpass Kaiser (verschillende FIR LP filters not much of a difference)
Hd = designfilt('lowpassfir','FilterOrder',100,'CutoffFrequency',100, ...
       'DesignMethod','window','Window',{@kaiser,3},'SampleRate',2000);
   
%% Filter Lowpass Chebyshev
%Hd = designfilt('lowpassfir','FilterOrder',100,'CutoffFrequency',150,...
  %'SampleRate',2500,'Window',{'chebwin',90});
%% Filter Lowpass Hamming
%Hd = designfilt('lowpassfir','FilterOrder',100,'CutoffFrequency',200,...
  % 'SampleRate',3000,'Window','hamming');
%% Matlab accelerometer 
aX_m = AllVariables.Mat_Acc_X;
aY_m = AllVariables.Mat_Acc_Y;
aZ_m = AllVariables.Mat_Acc_Z;

a_m = sqrt(aX_m.^2+aY_m.^2+aZ_m.^2)- 9.81; %taking the norm (offset gravity)
y1 = filter(Hd,a_m);
%% Filter Highpass
%Fs = 1000;
%Hd2 = designfilt('highpassfir','FilterOrder',200,'CutoffFrequency',100, ...
%       'DesignMethod','window','Window',{@kaiser,3},'SampleRate',Fs);
   
%y12 = filter(Hd2,a_m);
%Matlab_velocity_tot = addvars(Allvariables,a_m,y12,y1)
%plot(Matlab_velocity_tot.Timestamp, Matlab_velocity_tot.a_m,Matlab_velocity_tot.Timestamp, Matlab_velocity_tot.y12,Matlab_velocity_tot.Timestamp, Matlab_velocity_tot.y1)
%legend('norm','Hp','Lp')
%% Polar accelerometer
aX_p = AllVariables.Pol_Acc_X./100;
aY_p = AllVariables.Pol_Acc_Y./100;
aZ_p = AllVariables.Pol_Acc_Z./100;

a_p = sqrt(aX_p.^2+aY_p.^2+aZ_p.^2)- 9.81;
y2 = filter(Hd,a_p);
%% Matlab velocity integration
for n=2:length(y1) %integrating using forward euler
    if n==2
         y3(n)= y1(n)*dt;
    else
         y3(n)= y3(n-1) + (y1(n)- y1(n-1))*dt;
    end
end

for n=2:length(a_m) %integrating using forward euler
    if n==2
        v_m(n)= a_m(n)*dt;
    else
        v_m(n)= v_m(n-1) + (a_m(n)- a_m(n-1))*dt;
    end
end
%% Polar velocity integration
for n=2:length(a_p) %integrating using forward euler
    if n==2
        v_p(n)= a_p(n)*dt;
    else
        v_p(n)= v_p(n-1) + (a_p(n)- a_p(n-1))*dt;
    end
end

for n=2:length(y2) %integrating using forward euler
    if n==2
        y4(n)= y2(n)*dt;
    else
        y4(n)= y4(n-1) + (y2(n)- y2(n-1))*dt;
    end
end
%% Curve
Matlab_velocity_tot = addvars(AllVariables,a_m,abs(a_p),abs(transpose(v_m)),abs(transpose(v_p)),abs(y1),abs(y2),abs(transpose(y3)),abs(transpose(y4))); %plot
x = transpose(linspace(1,length(a_m),length(a_m))); %length vector
O = 57; %polynomial order

p = polyfit(x, a_m ,O);
v = polyval(p, x);

p2 = polyfit(x, a_p, O);
v2 = polyval(p2,x);

p3 = polyfit(x, transpose(v_m), 50);
v3 = polyval(p3,x);

p4 = polyfit(x, transpose(v_p),50);
v4 = polyval(p4,x);
%% Curve Combi
Matlab_velocity_tot = addvars(AllVariables,a_m,a_p,transpose(v_m),transpose(v_p),y1,y2,transpose(y3),transpose(y4)); %plot
x = transpose(linspace(1,length(a_m),length(a_m))); %length vector
O1 = 85; %polynomial order

pc = polyfit(x, y1 ,O1);
vc = polyval(pc, x);

p2c = polyfit(x, y2, O1);
v2c = polyval(p2c,x);

p3c = polyfit(x, transpose(y3),O1);
v3c = polyval(p3c,x);

p4c = polyfit(x, transpose(y4),O1);
v4c = polyval(p4c,x);

%% Peaks Data
[pks, locs] = findpeaks(Matlab_velocity_tot.y1,'MinPeakDistance', 5, 'MinPeakHeight',0)
pcc = polyfit(locs, pks ,21);
vcc = polyval(pcc, locs);

[pks1, locs1] = findpeaks(Matlab_velocity_tot.y2,'MinPeakDistance', 5, 'MinPeakHeight',0)
pcc1 = polyfit(locs1, pks1 ,21);
vcc1 = polyval(pcc1, locs1);

[pks2, locs2] = findpeaks(Matlab_velocity_tot.Var32,'MinPeakDistance', 5, 'MinPeakHeight',0)
pcc2 = polyfit(locs2, pks2 ,21);
vcc2 = polyval(pcc2, locs2);

[pks3, locs3] = findpeaks(Matlab_velocity_tot.Var33,'MinPeakDistance', 5, 'MinPeakHeight',0)
pcc3 = polyfit(locs3, pks3 ,21);
vcc3 = polyval(pcc3, locs3);

%% Plot Curve
t = tiledlayout(4,5);
nexttile
title("Accelerometer Matlab (original)")
hold on;
xlabel("Time of Day")
ylabel("Acceleration [m/s^2]")
plot(Matlab_velocity_tot.Timestamp, (Matlab_velocity_tot.a_m), 'red')
%legend('Acceleration Matlab')

nexttile
title("Accelerometer Curved Matlab")
hold on
plot(Matlab_velocity_tot.Timestamp, (v))
xlabel('Time of Day');
ylabel('Acceleration  [m/s^2]');
%legend('Acceleration Curve')

nexttile
title(" Accelerometer Filtered Lowpass (Matlab)")
hold on;
plot(Matlab_velocity_tot.Timestamp, (Matlab_velocity_tot.y1))
xlabel('Time of Day')
ylabel('Acceleration [m/s^2]')
% legend('Original Signal','Filtered Data')

nexttile
title("Accelerometer Combi Matlab")
hold on
plot(Matlab_velocity_tot.Timestamp, (vc))
xlabel('Time of Day');
ylabel('Acceleration  [m/s^2]');
%legend('Acceleration Curve')

nexttile
plot(Matlab_velocity_tot.Timestamp(locs), vcc,Matlab_velocity_tot.Timestamp(locs),pks)
title("Accelerometer Filtered Matlab Peaks")
hold on;
xlabel('Time of Day')
ylabel('Acceleration [m/s^2]')
% legend('filtered data','Curve Peaks','Peaks','Location','northwestoutside')
%% 2
nexttile
title("Accelerometer Polar (original)")
hold on;
xlabel("Time of Day")
ylabel("Acceleration [m/s^2]")
plot(Matlab_velocity_tot.Timestamp, (Matlab_velocity_tot.a_p), 'red')
%legend('Acceleration Polar')

nexttile
title("Accelerometer Curved Polar")
hold on
plot(Matlab_velocity_tot.Timestamp, (v2))
xlabel('Time of Day');
ylabel('Acceleration  [m/s^2]');
%legend('Acceleration Curve')

nexttile
title("Accelerometer Filtered Lowpass (Polar)")
hold on;
plot(Matlab_velocity_tot.Timestamp,(Matlab_velocity_tot.y2))
xlabel('Time of Day')
ylabel('Acceleration [m/s^2]')
% legend('Original Signal','Filtered Data')

nexttile
title("Accelerometer Combi Polar")
hold on
plot(Matlab_velocity_tot.Timestamp, (v2c))
xlabel('Time of Day');
ylabel('Acceleration  [m/s^2]');
%legend('Acceleration Curve')

nexttile
plot(Matlab_velocity_tot.Timestamp(locs1), vcc1,Matlab_velocity_tot.Timestamp(locs1),pks1)
title("Accelerometer Filltered Polar Peaks")
hold on;
xlabel('Time of Day')
ylabel('Acceleration [m/s^2]')
%% 3
nexttile
title("Velocity integrated Matlab")
hold on;
xlabel("Time of Day")
ylabel("Velocity [m/s]")
plot(Matlab_velocity_tot.Timestamp, (Matlab_velocity_tot.Var28), 'red')
%legend('Velocity Matlab')

nexttile
title("Velocity integrated Curved Matlab")
hold on
plot(Matlab_velocity_tot.Timestamp, (v3))
xlabel('Time of Day');
ylabel('Velocity  [m/s]');
%legend('Velocity Curve')

nexttile
title("Velocity Filtered Lowpass (Matlab)")
hold on;
plot(Matlab_velocity_tot.Timestamp,(Matlab_velocity_tot.Var32))
xlabel('Time of Day')
ylabel('Velocity [m/s]')
% legend('Original Signal','Filtered Data')

nexttile
title("Velocity integrated Combi Matlab")
hold on
plot(Matlab_velocity_tot.Timestamp, (v3c))
xlabel('Time of Day');
ylabel('Velocity  [m/s]');
%legend('Velocity Curve')

nexttile
plot(Matlab_velocity_tot.Timestamp(locs2), vcc2,Matlab_velocity_tot.Timestamp(locs2),pks2)
title("Velocity Integrated Matlab Peaks")
hold on;
xlabel('Time of Day')
ylabel('Speed [m/s]')
%% 4
nexttile
title("Velocity integrated Polar")
hold on;
xlabel("Time of Day")
ylabel("Velocity [m/s]")
plot(Matlab_velocity_tot.Timestamp, (Matlab_velocity_tot.Var29), 'red')

nexttile
title("Velocity integrated Curved Polar")
hold on
plot(Matlab_velocity_tot.Timestamp, (v4))
xlabel('Time of Day');
ylabel('Velocity  [m/s]');
%legend('Velocity Curve')

nexttile
title("Velocity Filtered Lowpass (Polar)")
hold on;
plot(Matlab_velocity_tot.Timestamp,(Matlab_velocity_tot.Var33))
xlabel('Time of Day')
ylabel('Velocity [m/s]')
%legend('Velocity Polar')

nexttile
title("Velocity integrated Combi Polar")
hold on
plot(Matlab_velocity_tot.Timestamp, (v4c))
xlabel('Time of Day');
ylabel('Velocity  [m/s]');
%legend('Velocity Curve')

nexttile
plot(Matlab_velocity_tot.Timestamp(locs3), vcc3,Matlab_velocity_tot.Timestamp(locs3),pks3)
title("Velocity Integrated Polar Peaks")
hold on;
xlabel('Time of Day')
ylabel('Speed [m/s]')
%% Velocity & HR
%nexttile
%title("Speed over Time")
%hold on;
%xlabel("Time of Day")
%ylabel("Speed [m/s]")
%plot(Allvariables.Timestamp,(Allvariables.Mat_speed), 'red')
%legend('Matlab speed')

%nexttile
%title("HR over Time")
%hold on;
%xlabel("Time of Day")
%ylabel("Hartrate [/(60s)]")
%plot(Allvariables.Timestamp,Allvariables.Pol_HR, 'blue')
%legend('Polar HR')
