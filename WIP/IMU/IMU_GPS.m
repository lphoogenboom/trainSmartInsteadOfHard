% Filter to perform censor fusion on IMU + GPS data
% Bachelor Thesis - Train Smart instead of Hard with Systems and Control: System Identification of Humans
% Laurens Hoogenboom
% 20-5-2020

%% Clean up data 
clear; clc;
load('C:\Users\lphoo\MATLAB Drive\Train Smart\Sensor Logs\COM_MaxHRTest_4HZ_1354_till_1409.mat');
allVariables = Allvariables; % fixing broken naming conventions
clear Allvariables;

% Calculating elapsed time
t1 = datevec(allVariables.Timestamp(1));
t2 = datevec(allVariables.Timestamp(end));
elapsedTime = etime(t2 , t1); 

% orientation euler angs and quaternions from IMU (phone)
trajOrientation.x = {allVariables.Mat_Pitch};
trajOrientation.y = {allVariables.Mat_Roll};
trajOrientation.z = {allVariables.Mat_Azimuth};
trajOrientEu = [cell2mat(trajOrientation.x) cell2mat(trajOrientation.z) cell2mat(trajOrientation.z)]; % Euler angs
trajOrient = quaternion(trajOrientEu, 'rotvecd'); % quaternions

% position degs and metres from GPS
trajPosition.latitude = {allVariables.Mat_latitude};
trajPosition.longitude = {allVariables.Mat_longitude};
trajPosition.altitude = {allVariables.Mat_altitide};
trajPos = [cell2mat(trajPosition.latitude) cell2mat(trajPosition.longitude) cell2mat(trajPosition.altitude)]; %[ lat long alt ]

refloc = [trajPos(1,1) trajPos(1,2) trajPos(1,3)]; % Reference location of measurements
trajPosFlat = zeros(size(trajPos));
for i = 1:(length(allVariables.Timestamp))
        trajPosFlat(i,:) = lla2flat( trajPos(i,:) , [ refloc(1) refloc(2) ] , refloc(2) , refloc(3));
end

% absolute velocity from GPS data
% trajVel = allVariables.Mat_speed;
trajVel = zeros(length(allVariables.Timestamp),3);
for i=1:(length(trajVel)-1)
        d1 = datevec(allVariables.Timestamp(i));
        d2 = datevec(allVariables.Timestamp(i+1));
        dTime = etime(d2 , d1); 
        trajVel(i+1, :) = ( trajPosFlat(i+1,:) - trajPosFlat(i,:) ) ./ dTime;
end

% Accelerations from IMU (phone)
trajAcceleration.x = {allVariables.Mat_Acc_X};
trajAcceleration.y = {allVariables.Mat_Acc_Y};
trajAcceleration.z = {allVariables.Mat_Acc_Z};
trajAcc = [cell2mat(trajAcceleration.x) cell2mat(trajAcceleration.y) cell2mat(trajAcceleration.z)];% [ x y z ]

% Angulare velocities from IMU (phone)
trajAngularVel.x = {allVariables.Mat_AV_X};
trajAngularVel.y = {allVariables.Mat_AV_Y};
trajAngularVel.z = {allVariables.Mat_AV_Z};
trajAngVel = [cell2mat(trajAngularVel.x) cell2mat(trajAngularVel.y) cell2mat(trajAngularVel.z)]; % [ x y z]

clear i trajOrientation trajPosition trajAcceleration trajAngularVel d1 d2 t1 t2 dTime 
%% Filter Init

imuFs = 3; % IMU  sensors frequency
gpsFs = 3; % GPS sensors frequency
imuSamplesPerGPS = (imuFs/gpsFs); % is one in our case
assert(imuSamplesPerGPS == fix(imuSamplesPerGPS), 'GPS sampling rate must be an integer factor of IMU sampling rate.'); % Error handling; Must be int

fusionfilt = insfilter;
fusionfilt.IMUSampleRate = imuFs;
fusionfilt.ReferenceLocation = refloc;

%% GPS Sensor Init

gps = gpsSensor('UpdateRate', gpsFs);
gps.ReferenceLocation = refloc;

%% IMU Sensors Init

imu = imuSensor('accel-gyro-mag', 'SampleRate', imuFs);
[x , y , z] = sph2cart(1+37/60, 67+2/60,49.18);imu.MagneticField = [ x  -y -z ];

clear x y z
%% Filter State vector Init

initstate = zeros(22,1);
initstate(1:4) = compact((trajOrient(1))); 
initstate(5:7) = ( trajPos(1,:));
initstate(8:10) = ( trajVel(1,:));
initstate(11:13) =  imu.Gyroscope.ConstantBias./imuFs;
initstate(14:16) =  imu.Accelerometer.ConstantBias./imuFs;
initstate(17:19) =  imu.MagneticField;
initstate(20:22) = imu.Magnetometer.ConstantBias;

fusionfilt.State = initstate;

%% Data feedthrough

secondsToSimulate = elapsedTime;
numSamples = length(allVariables.Timestamp);

pqOrient = quaternion.zeros(numSamples,1);
pqPos = zeros(numSamples,3);

fcnt = 3600
for i=1:fcnt  
        [ accel, gyro, mag ] = imu( trajAcc(fcnt,:) , trajAngVel(fcnt,:) , trajOrient(fcnt) );
      
        predict( fusionfilt , accel , gyro ); % update states
        
        [ fusedPos , fusedOrient ] = pose(fusionfilt);
        
        pqOrient(fcnt) = fusedOrient;
        pqPos(fcnt,:) = fusedPos;
        
        [ lla , gpsvel ] = gps( trajPos(fcnt,:) , trajVel(fcnt,:) ); % LLA = lat long alt
        
        Rmag = 0.05; % Magnetometer measurement noise
        Rvel = 0.1; % GPS Velocity measurement noise
        Rpos = 70; % GPS Position measurement noise
        
        fusegps(fusionfilt , lla , Rpos , gpsvel , Rvel);
        
        fusemag(fusionfilt, mag , Rmag);
end

clear fcnt accel gyro mag lla gpsvel

%% Visual representation
subplot(1,2,1)
plot(trajPosFlat(:,1),trajPosFlat(:,2), 'color', '#EDB120');

subplot(1,2,2)

plot(pqPos(:,1),pqPos(:,2),'color',	'#D95319')

display('Done');
 










