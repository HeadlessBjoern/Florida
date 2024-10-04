% setup the Screen
% XOrgConfCreator % run only once and tell psychtoolbox, how to organize
% screens
% XOrgConfSelector % if issues with copying the file on LInux, run the next line in
% terminal:
% sudo cp /home/methlab/.Psychtoolbox/XorgConfs/90-ptbconfig_2_xscreens_2_outputs_amdgpu.conf /etc/X11/xorg.conf.d/90-ptbxorg.conf
% to reverse:
% sudo cp /home/methlab/.Psychtoolbox/XorgConfs/90-ptbconfig_1_xscreens_1_outputs_amdgpu.conf /etc/X11/xorg.conf.d/90-ptbxorg.conf
% Restart computer to confirm the changes!

Screen('Screens') % sanity check, whether 2 screens detected

% Set Screen to run experiment on
whichScreen = 1;   

% set resolution and refresh rate
screenWidth = 800;
screenHeight = 600;
refreshRate = 100;
SetResolution(whichScreen, screenWidth, screenHeight, []);
Screen('ConfigureDisplay', 'Scanout', whichScreen, 0, [], [], refreshRate); % refresh rate of 100hz (only for Linux)
par.BGcolor = 192;

% photo diode
% define the background and diode stimulus
backColor = [0, 0, 0]; % black
stimColor = [1500, 1500, 1500]; % white
backDiameter = 35;
stimDiameter = 33;
backPos = [4, screenHeight - 20]; % solte 4 sein anstatt 40
stimPos = [4, screenHeight - 20]; % solte 4 sein
