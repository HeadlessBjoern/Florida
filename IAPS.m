% Florida / IAPS
%
% This code requires PsychToolbox. https://psychtoolbox.org
% This was tested with PsychToolbox version 3.0.15, and with MATLAB R2022a.

%% EEG and ET
% Start recording EEG
disp('STARTING EEG RECORDING...');
initEEG;

% Calibrate ET (Tobii Pro Fusion)
disp('CALIBRATING ET...');
calibrateET;

%% Task
HideCursor(whichScreen);

% Define triggers
TASK_START = 10; % trigger for ET cutting
FIXATION = 15; % trigger for fixation cross
PRESENTATION = 21; % trigger for digit presentation
POSITIVE = 31; %trigger for positive condition
NEGATIVE = 32; %trigger for negative condition
NEUTRAL = 33;  %trigger for neutral condition
TASK_END = 90; % trigger for ET cutting

% Set up equipment parameters
equipment.viewDist = 800;               % Viewing distance in millimetres
equipment.ppm = 3.6;                    % Pixels per millimetre !! NEEDS TO BE SET. USE THE MeasureDpi FUNCTION !!
equipment.greyVal = .5;
equipment.blackVal = 0;
equipment.whiteVal = 1;
equipment.gammaVals = [1 1 1];          % The gamma values for color calibration of the monitor

% Set up stimulus parameters Fixation
stimulus.fixationOn = 1;                % Toggle fixation on (1) or off (0)
stimulus.fixationSize_dva = .50;        % Size of fixation cross in degress of visual angle
stimulus.fixationColor = 1;             % Color of fixation cross (1 = white; 0 = black)
stimulus.fixationLineWidth = 3;         % Line width of fixation cross
stimulus.regionHeight_dva = 7.3;
stimulus.regionWidth_dva = 4;
stimulus.regionEccentricity_dva = 3;

% Set up color parameters
color.textVal = 0;                  % Color of text
color.targetVal = 1;

% Set up text parameters
text.color = 0;                     % Color of text (0 = black)

startExperimentText = ['You will see a number of pictures in a row. \n\n' ...
    '\n\n' ...
    'Please look at the center of the screen. \n\n' ...
    '\n\n' ...
    'Press any key to continue.'];

% Shuffle rng for random elements
rng('default');
rng('shuffle');                     % Use MATLAB twister for rng

% Set up Psychtoolbox Pipeline
AssertOpenGL;

% Imaging set up
screenID = whichScreen;
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
Screen('Preference', 'SkipSyncTests', 0); % For linux (can be 0)

% Window set-up
[ptbWindow, winRect] = PsychImaging('OpenWindow', screenID, equipment.greyVal);
PsychColorCorrection('SetEncodingGamma', ptbWindow, equipment.gammaVals);
[screenWidth, screenHeight] = RectSize(winRect);
screenCentreX = round(screenWidth/2);
screenCentreY = round(screenHeight/2);
flipInterval = Screen('GetFlipInterval', ptbWindow);
Screen('BlendFunction', ptbWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
experiment.runPriority = MaxPriority(ptbWindow);

% Set font size for instructions and stimuli
Screen('TextSize', ptbWindow, 20);

global psych_default_colormode;                     % Sets colormode to be unclamped 0-1 range.
psych_default_colormode = 1;

global ptb_drawformattedtext_disableClipping;       % Disable clipping of text
ptb_drawformattedtext_disableClipping = 1;

% Calculate equipment parameters
equipment.mpd = (equipment.viewDist/2)*tan(deg2rad(2*stimulus.regionEccentricity_dva))/stimulus.regionEccentricity_dva; % Millimetres per degree
equipment.ppd = equipment.ppm*equipment.mpd;    % Pixels per degree

% Fix coordiantes for fixation cross
stimulus.fixationSize_pix = round(stimulus.fixationSize_dva*equipment.ppd);
fixHorizontal = [round(-stimulus.fixationSize_pix/2) round(stimulus.fixationSize_pix/2) 0 0];
fixVertical = [0 0 round(-stimulus.fixationSize_pix/2) round(stimulus.fixationSize_pix/2)];
fixCoords = [fixHorizontal; fixVertical];

% Create data structure for preallocating data
data = struct;

% Show task instruction text
DrawFormattedText(ptbWindow,startExperimentText,'center','center',color.textVal);
startExperimentTime = Screen('Flip',ptbWindow);
disp('Participant is reading the instructions');
waitResponse = 1;
while waitResponse
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
end

Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1);
endTime = Screen('Flip',ptbWindow);

% Send triggers for start of task (ET cutting)
Eyelink('Message', num2str(TASK_START));
Eyelink('command', 'record_status_message "START"');
sendtrigger(TASK_START,port,SITE,stayup);

HideCursor(whichScreen);

%% Experiment Loop
for trial = 1:numel(stimIDs)
    try
        disp(['Start of Trial ' num2str(trial)]); % Output of current trial #

        %% Central fixation interval (jittered 2000 - 3000ms)
        % Load the image
        img = imread('/home/methlab/Desktop/IAPS/FIXATION.BMP');

        % Convert the image matrix to a Psychtoolbox texture
        fixTexture = Screen('MakeTexture', ptbWindow, img);

        % Get the size of the image
        [imgHeight, imgWidth, dim3] = size(img);

        % Get the center coordinates of the screen
        [screenX, screenY] = RectCenter(winRect);

        % Define the destination rectangle for the image (centered on the screen)
        dstRect = [screenX - imgWidth / 2, screenY - imgHeight / 2, screenX + imgWidth / 2, screenY + imgHeight / 2];

        % Draw the image on the screen
        Screen('DrawTexture', ptbWindow, fixTexture, [], dstRect);
        Screen('Flip', ptbWindow);

        % Send triggers for fixation
        Eyelink('Message', num2str(FIXATION));
        Eyelink('command', 'record_status_message "FIXATION"');
        sendtrigger(FIXATION,port,SITE,stayup);

        % Wait for a jittered interval of 2 - 3s
        timing.cfi(trial) = (randsample(2000:3000, 1))/1000; % Duration of the jittered inter-trial interval
        WaitSecs(timing.cfi(trial));

        %% Presentation of stimulus (2s)

        % Pick .bpm file name from randomized list of all pictures
        stimID(trial) = stimIDs(randStim(trial));

        % Load the image
        img = imread(['/home/methlab/Desktop/IAPS/IAPS_stimuli2/' num2str(stimID(trial)) '.bmp']);

        % Convert the image matrix to a Psychtoolbox texture
        imgTexture = Screen('MakeTexture', ptbWindow, img);

        % Get the size of the image
        [imgHeight, imgWidth, dim3] = size(img);

        % Get the center coordinates of the screen
        [screenX, screenY] = RectCenter(winRect);

        % Define the destination rectangle for the image (centered on the screen)
        dstRect = [screenX - imgWidth / 2, screenY - imgHeight / 2, screenX + imgWidth / 2, screenY + imgHeight / 2];

        % Draw the image on the screen
        Screen('DrawTexture', ptbWindow, imgTexture, [], dstRect);
        Screen('Flip', ptbWindow);

        % Send triggers for presentation
        Eyelink('Message', num2str(PRESENTATION));
        Eyelink('command', 'record_status_message "STIMULUS"');
        sendtrigger(PRESENTATION,port,SITE,stayup);

        % Send triggers for condition
        stimIDtbl = table(stimID(trial));
        if ismember(stimIDtbl, tblPos) == 1
            TRIGGER = POSITIVE;
            disp(['Positive Stimulus: ' num2str(stimID(trial))])
        elseif ismember(stimIDtbl, tblNeg) == 1
            TRIGGER = NEGATIVE;
            disp(['Negative Stimulus: ' num2str(stimID(trial))])
        elseif ismember(stimIDtbl, tblNeut) == 1
            TRIGGER = NEUTRAL;
            disp(['Neutral Stimulus: ' num2str(stimID(trial))])
        end
        Eyelink('Message', num2str(TRIGGER));
        Eyelink('command', 'record_status_message "STIMULUS"');
        sendtrigger(TRIGGER,port,SITE,stayup);

        % Display picture for 2 seconds
        WaitSecs(2);

    catch
        psychrethrow(psychlasterror);
    end
end

%% End task, save data and inform participant about accuracy and extra cash

% Send triggers for end of task (ET cutting)
Eyelink('Message', num2str(TASK_END));
Eyelink('command', 'record_status_message "TASK_END"');
sendtrigger(TASK_END,port,SITE,stayup);

% Save data
subjectID = num2str(subject.ID);
filePath = fullfile(DATA_PATH, subjectID);
mkdir(filePath)
fileName = [subjectID '_IAPS.mat'];

% Save data
saves = struct;
saves.data = data;
saves.data.stimID = stimID;
saves.experiment = experiment;
saves.screenWidth = screenWidth;
saves.screenHeight = screenHeight;
saves.screenCentreX = screenCentreX;
saves.screenCentreY = screenCentreY;
saves.startExperimentTime = startExperimentTime;
saves.subjectID = subjectID;
saves.subject = subject;
saves.text = text;
saves.timing = timing;
saves.flipInterval = flipInterval;

% Save triggers
trigger = struct;
trigger.FIXATION = FIXATION;
trigger.TASK_START = TASK_START;
trigger.PRESENTATION = PRESENTATION;
trigger.POSITIVE = POSITIVE;
trigger.NEGATIVE = NEGATIVE;
trigger.NEUTRAL = NEUTRAL;
trigger.TASK_END = TASK_END;

% Stop and close EEG and ET recordings
disp('SAVING DATA...');
save(fullfile(filePath, fileName), 'saves', 'trigger');
closeEEGandET;

try
    PsychPortAudio('Close');
catch
end

% Quit
Screen('CloseAll');