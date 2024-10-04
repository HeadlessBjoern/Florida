%% Connect Eyetracker & Calibrate

bgClr                   = 127;
Screen('Preference', 'SyncTestSettings', 0.002);    % the systems are a little noisy, give the test a little more leeway
[ptbWindow,winRect] = PsychImaging('OpenWindow', whichScreen, bgClr, [], [], [], [], 4);
hz=Screen('NominalFrameRate', ptbWindow);
Priority(1);
Screen('BlendFunction', ptbWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference', 'TextAlphaBlending', 1);
Screen('Preference', 'TextAntiAliasing', 2);
% This preference setting selects the high quality text renderer on
% each operating system: It is not really needed, as the high quality
% renderer is the default on all operating systems, so this is more of
% a "better safe than sorry" setting.
Screen('Preference', 'TextRenderer', 1);
KbName('UnifyKeyNames');    % for correct operation of the setup/calibration interface, calling this is required

subjectID = num2str(subject.ID);
filePath = fullfile(DATA_PATH, subjectID);

edfFile = [subjectID,'_', 'IAPS.edf'];

try
    % Connect the Eytracker, it needs a window
    EL_Connect;
    try % open file to record data to
        disp('creating edf file');
        status=Eyelink('Openfile', edfFile);
    catch
        disp('Error creating the file on Tracker');
    end

    EL_Calibrate

    Eyelink('command', ['record_status_message "OCC' num2str(BLOCK) ' EEG"']);
catch
    %window=Screen('OpenWindow', whichScreen, par.BGcolor);
    disp('No Eyetracker');
end

Screen('CloseAll')

Eyelink('StartRecording');
WaitSecs(0.1)