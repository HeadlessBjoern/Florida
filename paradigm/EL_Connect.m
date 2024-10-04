%% Connect & Setup Eyelink Tacker
% A window called 'window' needs to be present to initiate the Tracker
try
el=EyelinkInitDefaults(ptbWindow); %Connecting to the Eyelink Tracker
el.backgroundcolour = [par.BGcolor par.BGcolor par.BGcolor];
el.calibrationtargetcolour = [0 0 0];
EyelinkUpdateDefaults(el);
catch
    error('Error Connecting to the Eyetracker');
end

if ~EyelinkInit(0, 1)
    error('Error Connecting to the Eyetracker');
end
try
    [v, vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    % Change Tracker Settings 
    % Setting what data to get from Tracker (Based on Manual v 1.0.6)
    fprintf('Setting up the Tracker \n' );
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    % Possible Commands:
    %
    % LEFT,RIGHT - Sets the intended tracking eye (usually include both LEFT and RIGHT)
    % GAZE - includes screen gaze position data
    % GAZERES - includes units-per-degree screen resolution at point of gaze
    % HREF - head-referenced eye position data
    % HTARGET - target distance and X/Y position (EyeLink Remote only)
    % PUPIL - raw pupil coordinates
    % AREA - pupil size data (diameter or area)
    % BUTTON - buttons 1-8 state and change flags
    % STATUS - warning and error flags
    % INPUT - input port data lines
    %
    % The default data is:
    % file_sample_data =LEFT,RIGHT,GAZE,GAZERES,PUPIL,HREF,AREA,HTARGET,STATUS,INPUT
    %
    
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    % Possible Commands:
    %
    % GAZE - includes display (gaze) position data.
    % GAZERES - includes units-per-degree screen resolution (for start, end of event)
    % HREF - includes head-referenced eye position
    % AREA - includes pupil area or diameter
    % VELOCITY - includes velocity of parsed position-type (average, peak, start and end)
    % STATUS - includes warning and error flags, aggregated across event (not yet supported)
    % FIXAVG - include ONLY averages in fixation end events, to reduce file size
    % NOSTART - start events have no data other than timestamp
    %
    % Some example settings are given below:
    % GAZE,GAZERES,AREA,HREF,VELOCITY - default: all useful data
    % GAZE,GAZERES,AREA,FIXAVG,NOSTART - reduced data for fixations
    % GAZE,AREA,FIXAVG,NOSTART - minimal data
    %
    
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON');
    % Possible Commands:
    %
    % LEFT, RIGHT - Sets the intended tracking eye (usually include both LEFT and RIGHT)
    % FIXATION - includes fixation start and end events
    % FIXUPDATE - includes fixation (pursuit) state update events
    % SACCADE - includes saccade start and end events
    % BLINK - includes blink start and end events
    % MESSAGE - includes messages (ALWAYS use)
    % BUTTON - includes button 1..8 press or release events
    % INPUT - includes changes in input port lines
    %
    % Default event configuration:
    % file_event_filter= LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON
    %
    Eyelink('command', 'sample_rate = %d',500);
    Eyelink('Command', 'clear_screen 0');
    Eyelink('Command', 'set_idle_mode');
    Eyelink('Command', 'screen_pixel_coords = %d %d %d %d',0,0,screenWidth-1,screenHeight-1);
    disp('Setup Sucessful');
catch
    error('Error Connecting to the Eyetracker');
end