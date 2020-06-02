%% Data preset
% file.user = 'Anne Brinkman'; % Computer username
% file.testrun = '3'; % testrun ID
% file.freq = 4; % Frequency 4/50/100/200 Hz
% file.start = '1439'; % starting time of file [hhmm]
% file.end = '1613'; % ending time of file [hhmm]
% 
% file.name = strcat('COM_testrun',file.testrun,'_',string(file.freq),'HZ_',file.start,'_till_',file.end); %file name
% file.path = strcat('C:\Users\',file.user,'\MATLAB Drive\Train Smart\Sensor Logs\',file.name,'.mat'); % file path on C:// drive
% load(file.path); % import file
% allVariables = AllVariables; % naming prefference

load('C:\Users\Anne Brinkman\MATLAB Drive\Train Smart\Sensor Logs\COM_testrun3_4HZ_1439_till_1613_geenpolarEcgAcc.mat')
BLU = BEST_LINEAR_FIT
BLD = BEST_LINEAR_DOWN
v = AllVariables.Mat_speed
sim(BLU,v);

for n=3:length(AllVariables.Mat_speed)
    if (v(n) > v(n-1))
        HR(n) = sim(BEST_LINEAR_FIT,v(n))+60;
    if (v(n) < v(n-1))
        HR(n)= sim(BEST_LINEAR_DOWN,v(n)) + 60;
    end
    end
end

figure(1)
plot(HR)

figure(2)
plot(AllVariables.Timestamp,AllVariables.Pol_HR)
