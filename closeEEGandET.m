% Stop EEG and ET recordings and save the data

    % stop recoring EEG of current task:
    trigger = 2; % 2 stops the ANT Neuro
    sendtrigger(trigger,port,SITE,stayup)
    ppdev_mex('CloseAll');

fprintf('Stop Recording Track\n');
Eyelink('StopRecording');
Eyelink('CloseFile');
fprintf('Downloading File\n');
EL_DownloadDataFile;
EL_Cleanup;

pathEdf2Asc = '/usr/bin/edf2asc';  
disp("CONVERTING EDF to ASCII...")
system([pathEdf2Asc ' "' fullfile(filePath, edfFile) '" -y']);