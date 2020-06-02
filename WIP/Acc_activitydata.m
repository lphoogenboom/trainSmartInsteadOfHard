clc
clear all
%% Fill in data
file.user = 'Anne Brinkman';
file.name = 'COM_testrun5down_100HZ_0820_till_0845';
% Fll in if matlab/polar/gps/HR speed data is valid (1= valid 0= invalid)
Matlab  = 1 ;
Polar   = 1 ;
Speed   = 1 ;
HR      = 1 ; 
% smoothing over ... sec
S   = 40; %amount of seconds used to smooth data

% Order filter
N = 3 ; %order acc filter
N2 = 2; % order HR filter 
% Band pass frequency range standard f1= 0.5 hz and f2= 30 Hz. 
f1 = 0.2; f2=30; % ACC
f3 = 0.0035; % HR low pass filter cut of

% rescaling polar Acc data seems to be collected in mG instead of G
d = 0.001; 

%% uploading data
file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\Sensor Logs\',file.name,'.mat');
load(file.path);
%% extracting HZ from data file
c   = second(AllVariables.Timestamp);
HZ  = round(mean( 1./diff(c) ));
%% Preload HR for System identification    
ti = 1/HZ;
if Speed == 1
    GPS = AllVariables.Mat_speed;
end
%% Band pass filter
% Normalized pass frequency ranges (Wn1, Wn2):
Wn1=f1/(0.5*HZ);      
Wn2=f2/(0.5*HZ);      
% Second order (N=2) filter passes all signal components within           
% a frequency range of: [Wn1 Wn2]
% Compute second order filter coefficients:
[b, a]    = butter(N, [Wn1, Wn2], 'bandpass');
if (Matlab == 1 && Polar == 1)
    %matlab 
    filter_mat = filtfilt(b,a,[AllVariables.Mat_Acc_X, AllVariables.Mat_Acc_Y, AllVariables.Mat_Acc_Z])*d;
    %Polar
    filter_pol = filtfilt(b,a,[AllVariables.Pol_Acc_X, AllVariables.Pol_Acc_Y, AllVariables.Pol_Acc_Z])*d;
elseif (Matlab == 1 && Polar == 0)
    %matlab 
    filter_mat = filtfilt(b,a,[AllVariables.Mat_Acc_X, AllVariables.Mat_Acc_Y, AllVariables.Mat_Acc_Z])*d;
elseif (Matlab == 0 && Polar == 1)
    %Polar
    filter_pol = filtfilt(b,a,[AllVariables.Pol_Acc_X, AllVariables.Pol_Acc_Y, AllVariables.Pol_Acc_Z])*d;
end
if HR == 1
    Wn = f3/(0.5*HZ);
    [b, a]    = butter(N2,Wn,'low');
    filter_HR = filtfilt(b,a,AllVariables.Pol_HR);
end
%% creating single activity model
if (Matlab == 1 && Polar == 1)
    a_m = sqrt(filter_mat(:,1).^2+filter_mat(:,2).^2+filter_mat(:,3).^2);%taking the norm matlab
    a_p2 = sqrt(filter_pol(:,1).^2+filter_pol(:,2).^2+filter_pol(:,3).^2);%taking the norm polar
elseif (Matlab == 1 && Polar == 0)
    a_m = sqrt(filter_mat(:,1).^2+filter_mat(:,2).^2+filter_mat(:,3).^2);%taking the norm matlab    
elseif (Matlab == 0 && Polar == 1)
    a_p2 = sqrt(filter_pol(:,1).^2+filter_pol(:,2).^2+filter_pol(:,3).^2);%taking the norm polar
end

%% Cumulative trapezoidal numerical integration
% time vector
t   = height(AllVariables(:,1));
t   = linspace(0, t, t)*ti;
%t = c;
% integration
if (Matlab == 1 && Polar == 1) % Velocity matlab & Polar
    %V1  = [filter_mat(:,1), filter_mat(:,2), filter_mat(:,3)];
    V1  = cumtrapz(t,filter_mat);
    V1  = sqrt(V1(:,1).^2+V1(:,2).^2+V1(:,3).^2);
    V2  = cumtrapz(t,filter_pol);
    V2  = sqrt(V2(:,1).^2+V2(:,2).^2+V2(:,3).^2);
elseif (Matlab == 1 && Polar == 0) % Velocity matlab
    V1  = cumtrapz(t,filter_mat);
    V1  = sqrt(V1(:,1).^2+V1(:,2).^2+V1(:,3).^2);
elseif (Matlab == 0 && Polar == 1) % Velocity Polar
    V2  = cumtrapz(t,filter_pol);
    V2  = sqrt(V2(:,1).^2+V2(:,2).^2+V2(:,3).^2);
end

%% smoothing
SA = S*HZ;
if (Matlab == 1 && Polar == 1) % smoothing matlab & Polar
    %Smoothin acc
    Matlabacc = smoothdata(a_m,'gaussian',SA); 
    Polaracc = smoothdata(a_p2,'gaussian',SA);
    %Smoothing velo
    Matlabvelocity = smoothdata(V1,'gaussian',SA);
    Polarvelocity = smoothdata(V2,'gaussian',SA);
elseif (Matlab == 1 && Polar == 0) %smoothing matlab
    Matlabacc = smoothdata(a_m,'gaussian',SA);
    Matlabvelocity = smoothdata(V1,'gaussian',SA);
elseif (Matlab == 0 && Polar == 1) %smoothing polar
    Polaracc = smoothdata(a_p2,'gaussian',SA);
    Polarvelocity = smoothdata(V2,'gaussian',SA);
end


%% plotting
if (Matlab == 1 && Polar == 1) % Velocity matlab & Polar
    figure(1),clf(1)
    title("Filtered and normalized ACC data")
    hold on;
    xlabel("Time [min]")
    ylabel("Activity data (average acc)")
    plot(AllVariables.Timestamp,Matlabacc,'r',AllVariables.Timestamp,Polaracc,'green')%add interpolation
    if HR == 1
        yyaxis right
        ylabel("Running vel [km/h]")
        plot(AllVariables.Timestamp,filter_HR,'b')
        legend('Matlab Activity','Polar Activity','HR')
    else
        legend('Matlab Activity','Polar Activity')
    end
    hold off

    figure(2),clf(2)
    title("Trapezoidal integration to velocity")
    hold on;
    xlabel("Time [min]")
    ylabel("velocity")
    if Speed   == 1
        plot(AllVariables.Timestamp,Matlabvelocity,'r',AllVariables.Timestamp,Polarvelocity,'g',AllVariables.Timestamp,GPS,'c')%add interpolation
        if HR == 1
            yyaxis right
            ylabel("Running vel [km/h]")
            plot(AllVariables.Timestamp,filter_HR,'b')
            legend('Matlab velocity','Polar velocity','gps velocity','HR')
        else
            legend('Matlab velocity','Polar velocity','gps velocity')
        end
    elseif Speed   == 0
        plot(AllVariables.Timestamp,Matlabvelocity,'r',AllVariables.Timestamp,Polarvelocity,'g')%add interpolation
        if HR == 1
            yyaxis right
            ylabel("Running vel [km/h]")
            plot(AllVariables.Timestamp,filter_HR,'b')
            legend('Matlab velocity','Polar velocity','HR')
        else
            legend('Matlab velocity','Polar velocity')
        end
    end
        
    hold off
elseif (Matlab == 1 && Polar == 0) %smoothing matlab
    figure(1),clf(1)
    title("Filtered and normalized ACC data")
    hold on;
    xlabel("Time [min]")
    ylabel("Activity data (average acc)")
    plot(AllVariables.Timestamp,Matlabacc,'r')%add interpolation
    if HR == 1
        yyaxis right
        ylabel("Running vel [km/h]")
        plot(AllVariables.Timestamp,filter_HR,'b')
        legend('Matlab Activity','HR')
    else
        legend('Matlab Activity')
    end
    hold off

    figure(2),clf(2)
    title("Trapezoidal integration to velocity")
    hold on;
    xlabel("Time [min]")
    ylabel("velocity")
    if Speed   == 1
        plot(AllVariables.Timestamp,Matlabvelocity,'r',AllVariables.Timestamp,GPS,'c')%add interpolation
        if HR == 1
            yyaxis right
            ylabel("Running vel [km/h]")
            plot(AllVariables.Timestamp,filter_HR,'b')
            legend('Matlab velocity','gps velocity','HR')
        else
            legend('Matlab velocity','gps velocity')
        end
    elseif Speed   == 0
        plot(AllVariables.Timestamp,Matlabvelocity,'r')%add interpolation
        if HR == 1
            yyaxis right
            ylabel("Running vel [km/h]")
            plot(AllVariables.Timestamp,filter_HR,'b')
            legend('Matlab velocity','HR')
        else
            legend('Matlab velocity')
        end
    end
    hold off
elseif (Matlab == 0 && Polar == 1)
    figure(1),clf(1)
    title("Filtered and normalized ACC data")
    hold on;
    xlabel("Time [min]")
    ylabel("Activity data (average acc)")

    plot(AllVariables.Timestamp,Polaracc,'green')%add interpolation
    if HR == 1
        yyaxis right
        ylabel("Running vel [km/h]")
        plot(AllVariables.Timestamp,filter_HR,'b')
        legend('Polar Activity','HR')
    else
        legend('Polar Activity')
    end
    hold off

    figure(2),clf(2)
    title("Trapezoidal integration to velocity")
    hold on;
    xlabel("Time [min]")
    ylabel("velocity")

    if Speed   == 1
        plot(AllVariables.Timestamp,Polarvelocity,'g',AllVariables.Timestamp,GPS,'c')%add interpolation
         if HR == 1
            yyaxis right
            ylabel("Running vel [km/h]")
            plot(AllVariables.Timestamp,filter_HR,'b')
            legend('Polar velocity','gps velocity','HR')
        else
            legend('Polar velocity','gps velocity')
        end
    elseif Speed   == 0
        plot(AllVariables.Timestamp,Polarvelocity,'g')%add interpolation
         if HR == 1
            yyaxis right
            ylabel("Running vel [km/h]")
            plot(AllVariables.Timestamp,filter_HR,'b')
            legend('Polar velocity','HR')
        else
            legend('Polar velocity')
        end
    end
    hold off
end

%% NEW TIMETABLES
TR5down_data = addvars(AllVariables,filter_HR,Polaracc);