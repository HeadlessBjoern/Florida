%% Cleanup Routine for The Eylink Eyetracker
IOPort('CloseAll');
%Screen('CloseAll');
Eyelink('Command', 'clear_screen 0');
% Restore keyboard output to Matlab:
%ListenChar(0);
% Shutdown Eyelink:
Eyelink('StopRecording');
Eyelink('CloseFile');
Eyelink('Shutdown'); %DN: commented out for now. Uncomment later
fprintf('Stopped the Eyetracker\n');