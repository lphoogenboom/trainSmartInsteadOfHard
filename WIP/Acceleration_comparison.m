%clear all
clc
%load COM_MaxHRTest_3HZ_1354_till_1409.mat
dt = 0.33333 %s = sample time
%% Matlab accelerometer 
aX_m = AllVariables.Mat_Acc_X;
aY_m = AllVariables.Mat_Acc_Y;
aZ_m = AllVariables.Mat_Acc_Z;

a_m = sqrt(aX_m.^2+aY_m.^2+aZ_m.^2)- 9.81; %taking the norm (offset gravity)
%% Polar accelerometer
aX_p = AllVariables.Pol_Acc_X./100;
aY_p = AllVariables.Pol_Acc_Y./100;
aZ_p = AllVariables.Pol_Acc_Z./100;

a_p = sqrt(aX_p.^2+aY_p.^2+aZ_p.^2)- 9.81;
%% Matlab velocity integration
for n=2:length(a_m); %integrating using forward euler
    if n==2;
        v_m(n)= a_m(n)*dt;
    else
        v_m(n)= v_m(n-1) + (a_m(n)- a_m(n-1))*dt;
    end
end

%% Plot data 1
Matlab_velocity_tot = addvars(AllVariables,a_m,a_p); %plot

t = tiledlayout(3,2);
nexttile
title("Accelerometer comparison")
hold on;
xlabel("Time of Day")
ylabel("Acceleration Matlab [m/s^2]")
plot(Matlab_velocity_tot.Timestamp, Matlab_velocity_tot.a_m, 'red')
yyaxis right
ylabel("Acceleration Polar [m/s^2]")
plot(Matlab_velocity_tot.Timestamp, Matlab_velocity_tot.a_p, 'blue')
legend('Acceleration Matlab', 'Acceleration Polar')
%% Plot data 2 acc vs. HR & speed vs. HR
Matlab_velocity_tot2 = addvars(Matlab_velocity_tot,transpose(v_m)) %plot

nexttile
title("influence on HR Acceleration")
hold on;
xlabel("HR [BPM]")
ylabel("Acceleration [m/s^2]")
plot(Matlab_velocity_tot2.Pol_HR, Matlab_velocity_tot2.a_m, 'green')
plot(Matlab_velocity_tot2.Pol_HR, Matlab_velocity_tot2.a_p, 'blue')
legend('Acceleration Matlab', 'Acceleration Polar')
%% Plot data 3

nexttile
title("influence on HR Speed")
hold on;
xlabel("HR [BPM]")
ylabel("Speed [m/s]")
plot(Matlab_velocity_tot2.Pol_HR,Matlab_velocity_tot2.Mat_speed, 'red')
plot(Matlab_velocity_tot2.Pol_HR,Matlab_velocity_tot2.Var28,'black')
legend('Speed Matlab', 'Speed integration')
%% Plot data 5
nexttile
title("Speed (integrated) over time using Matlab accelerometer")
hold on;
xlabel("Time of Day")
ylabel("Speed [m/s]")
plot(Matlab_velocity_tot2.Timestamp, Matlab_velocity_tot2.Var28,'--')
legend('Speed')
%% Plot data 4
nexttile
title("HR over Time")
hold on;
xlabel("Time of Day")
ylabel("Hartrate [/(60s)]")
plot(Allvariables.Timestamp,AllVariables.Pol_HR, 'blue')
legend('Polar HR')

nexttile
title("Speed over Time")
hold on;
xlabel("Time of Day")
ylabel("Running vel [km/h]")
plot(AllVariables.Timestamp,(3.6.*AllVariables.Mat_speed), 'red')
legend('Matlab speed')


