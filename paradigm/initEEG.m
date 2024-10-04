% start EEG recording (ANT Neuro EEG system)

% add ppdev-mex-master to path 
addpath(PPDEV_PATH)

% define port
port = 1;

% Open the parallel port
ppdev_mex('Open', port);

% define Site and "stayup"
SITE = 'A'; % when using ANT Neuro its 'A'
stayup = 0; 

% start recording EEG by sending trigger 1:
trigger = 1;

sendtrigger(trigger,port,SITE,stayup)

% wait for EEG recording to start. It takes ca 10 s. 
% Or put initEEG before ET calibration, which also takes some time...
% WaitSecs(15);

