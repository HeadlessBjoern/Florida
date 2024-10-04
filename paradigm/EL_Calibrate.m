try
    % Setup for Calibration
    % TODO ADD MORE INFO FOR SETTINGS!
    try
        Snd('Close');
        PsychPortAudio('Close');
    catch
    end
    fprintf('Starting Calibration \n' );
    Eyelink('Command', 'saccade_velocity_threshold = 35');
    Eyelink('Command', 'saccade_acceleration_threshold = 9500');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
    Eyelink('Command', 'active_eye = LEFT');
    Eyelink('Command', 'calibration_type = HV9');
    Eyelink('Command', 'enable_automatic_calibration = YES');
    Eyelink('Command', 'automatic_calibration_pacing = 500');
    Eyelink('Command', 'set_idle_mode');
    % Run Calibration, Calibration and Validation need to be accesed over the Stim computer
    % In the End, ESC must be pressed to continue
    HideCursor(whichScreen);
    %ListenChar(2);
    Eyelink('StartSetup',1);
    disp('Calibration done');
    
%     ShowCursor(whichScreen);
%     SetMouse(400,300,1);
    disp('Calibration done');
    try
        Snd('Close');
        PsychPortAudio('Close');
    catch
    end
    Screen('CloseAll');
catch
    disp('Error running the calibration');
end