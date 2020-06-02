%clear all
clc
%load COM_MaxHRTest_3HZ_1354_till_1409.mat
dt = 0.33333; %s = sample time
%% Matlab accelerometer Matlabtot file (not consistent sample time)
aX_m = AllVariables.Mat_Acc_X;
aY_m = AllVariables.Mat_Acc_Y;
aZ_m = AllVariables.Mat_Acc_Z;

a_m = sqrt(aX_m.^2+aY_m.^2+aZ_m.^2)- 9.81; %taking the norm (offset gravity)
 
 for n=2:length(a_m) %integrating using forward euler
     if n==2
         v_m(n)= a_m(n)*dt;
     else
         v_m(n)= v_m(n-1) + (a_m(n)- a_m(n-1))*dt;
     end
 end

%for n=1:(length(a_m)-1) % forward euler
%        v_m(n+1) = v_m(n)+ dt * a_m(n);
%end

%for n=2:length(a_m) %integrating using forward euler
%    if n==2
%        v_m(n)= a_m(n)*dt;
%    else
%        v_m(n)= v_m(n-1) + (a_m(n))*dt;
%    end
%end

%Matlab_velocity_tot = addvars(AllVariables,transpose(v_m)); %plot

figure(1);
title("Speed (integrated) over time using Matlab accelerometer")
hold on;
xlabel("time")
ylabel("Speed [m/s]")
plot(AllVariables.Timestamp,transpose(v_m)) %Matlab_velocity_tot.Var26)



