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
BLOCK0 = 29; % trigger for start training block
BLOCK1 = 31; % trigger for start of block 1
BLOCK2 = 32; % trigger for start of block 2
BLOCK3 = 33; % trigger for start of block 3
ENDBLOCK0 = 39; % trigger for end training block
ENDBLOCK1 = 41; % trigger for end of block 1
ENDBLOCK2 = 42; % trigger for end of block 2
ENDBLOCK3 = 43; % trigger for end of block 3
TASK_END = 90; % trigger for ET cutting

% Set up experiment parameters
experiment.nTrials = 20;            % 3 blocks x 20 trials

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


loadingText = 'Loading actual task...';

startExperimentText = ['You will see a number of pictures in a row. \n\n' ...
    '\n\n' ...
    'Please look at the center of the screen. \n\n' ...
    '\n\n' ...
    'Press any key to continue.'];

startBlockText = 'Press any key to begin the next block.';

% Set up temporal parameters (in seconds)
timing.presentation = 2;     % Duration of digit presentation

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

% Show loading text
DrawFormattedText(ptbWindow,loadingText,'center','center',color.textVal);
Screen('Flip',ptbWindow);

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
data.stimuli{1, experiment.nTrials} = 0;

% Preallocate looping variables
blankJitter(1:experiment.nTrials) = 0;

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

% Send triggers for block and output
if BLOCK == 1
    TRIGGER = BLOCK1;
elseif BLOCK == 2
    TRIGGER = BLOCK2;
elseif BLOCK == 3
    TRIGGER = BLOCK3;
else
    TRIGGER = BLOCK0;
end

if TRAINING == 1
    disp('Start of Block 0 (Training)');
else
    disp(['Start of Block ' num2str(BLOCK)]);
end

Eyelink('Message', num2str(TRIGGER));
Eyelink('command', 'record_status_message "START BLOCK"');
sendtrigger(TRIGGER,port,SITE,stayup);

HideCursor(whichScreen);

%% Experiment Loop
noFixation = 0;
for thisTrial = 1:experiment.nTrials

    disp(['Start of Trial ' num2str(thisTrial)]); % Output of current trial #

    %% Central fixation interval (jittered 2000 - 30000ms)
    Screen('DrawLines',ptbWindow,fixCoords,stimulus.fixationLineWidth,stimulus.fixationColor,[screenCentreX screenCentreY],2); % Draw fixation cross
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1);
    Screen('Flip', ptbWindow);
    Eyelink('Message', num2str(FIXATION));
    Eyelink('command', 'record_status_message "FIXATION"');
    sendtrigger(FIXATION,port,SITE,stayup);
    timing.cfi(thisTrial) = (randsample(2000:3000, 1))/1000; % Duration of the jittered inter-trial interval
    WaitSecs(timing.cfi(thisTrial));

    %% Presentation of stimuli (2s)
    % Increase size of stimuli
    Screen('TextSize', ptbWindow, 50);
    % Define stimulus
    if data.trialSetSize(thisTrial) == experiment.setSizes(1)
        stimulusText = ['X ', 'X ', 'X ', num2str(thisTrialSequenceLetters(1)), ' + ', ...
            num2str(thisTrialSequenceLetters(2)), ' X', ' X', ' X'];
    elseif data.trialSetSize(thisTrial) == experiment.setSizes(2)
        stimulusText = ['X ', num2str(thisTrialSequenceLetters(1)), ' ', num2str(thisTrialSequenceLetters(2)), ' ', ...
            num2str(thisTrialSequenceLetters(3)), ' + ', num2str(thisTrialSequenceLetters(4)), ' ', ...
            num2str(thisTrialSequenceLetters(5)), ' ', num2str(thisTrialSequenceLetters(6)), ' X'];
    elseif data.trialSetSize(thisTrial) == experiment.setSizes(3)
        stimulusText = [num2str(thisTrialSequenceLetters(1)), ' ', num2str(thisTrialSequenceLetters(2)), ' ', ...
            num2str(thisTrialSequenceLetters(3)), ' ', num2str(thisTrialSequenceLetters(4)), ' + ', ...
            num2str(thisTrialSequenceLetters(5)), ' ', num2str(thisTrialSequenceLetters(6)), ' ', ...
            num2str(thisTrialSequenceLetters(7)), ' ', num2str(thisTrialSequenceLetters(8))];
    end
    stimulusLetters(thisTrial) = {thisTrialSequenceLetters(1:data.trialSetSize(thisTrial))};
    data.stimulusText(thisTrial) = {stimulusText};
    % Present stimuli (with cross in middle)
    DrawFormattedText(ptbWindow, stimulusText,'center','center',text.color);
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1);
    Screen('DrawDots',ptbWindow, stimPos, stimDiameter, stimColor,[],1);
    Screen('Flip', ptbWindow);
    % Return size of text to default
    Screen('TextSize', ptbWindow, 20);
    % Send triggers for Presentation
    TRIGGER = PRESENTATION;
    Eyelink('Message', num2str(TRIGGER));
    Eyelink('command', 'record_status_message "STIMULUS"');
    sendtrigger(TRIGGER,port,SITE,stayup);
    Eyelink('Message', num2str(DIGITOFF));
    Eyelink('command', 'record_status_message "DIGITOFF"');
    sendtrigger(DIGITOFF,port,SITE,stayup);

end

%% End task, save data and inform participant about accuracy and extra cash

% Send triggers for end of block and output
if BLOCK == 1
    TRIGGER = ENDBLOCK1;
elseif BLOCK == 2
    TRIGGER = ENDBLOCK2;
elseif BLOCK == 3
    TRIGGER = ENDBLOCK3;
else
    TRIGGER = ENDBLOCK0;
end

disp(['End of Block ' num2str(BLOCK)]);

% Send triggers for end of block (ET cutting)
Eyelink('Message', num2str(TRIGGER));
Eyelink('command', 'record_status_message "END BLOCK"');
sendtrigger(TRIGGER,port,SITE,stayup);

% Send triggers for end of task (ET cutting)
Eyelink('Message', num2str(TASK_END));
Eyelink('command', 'record_status_message "TASK_END"');
sendtrigger(TASK_END,port,SITE,stayup);

% Save data
subjectID = num2str(subject.ID);
filePath = fullfile(DATA_PATH, subjectID);
mkdir(filePath)
fileName = [subjectID '_IAPS_block' num2str(BLOCK) '.mat'];

% Save data
saves = struct;
saves.data = data;
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
trigger.BLOCK0 = BLOCK0;
trigger.BLOCK1 = BLOCK1;
trigger.BLOCK2 = BLOCK2;
trigger.BLOCK3 = BLOCK3;
trigger.ENDBLOCK0 = ENDBLOCK0;
trigger.ENDBLOCK1 = ENDBLOCK1;
trigger.ENDBLOCK2 = ENDBLOCK2;
trigger.ENDBLOCK3 = ENDBLOCK3;
trigger.TASK_END = TASK_END;

% Stop and close EEG and ET recordings
disp(['BLOCK ' num2str(BLOCK) ' FINISHED...']);
disp('SAVING DATA...');
save(fullfile(filePath, fileName), 'saves', 'trigger');
closeEEGandET;

try
    PsychPortAudio('Close');
catch
end

%% Wait at least 10 Seconds between Blocks (only after Block 1 has finished, not after Block 6)
waitTime = 10;
intervalTime = 1;
timePassed = 0;
printTime = 10;

waitTimeText = ['Please wait for ' num2str(printTime) ' seconds...' ...
    ' \n\n ' ...
    ' \n\n Block ' (num2str(BLOCK+1)) ' will start afterwards.'];

DrawFormattedText(ptbWindow,waitTimeText,'center','center',color.textVal);
Screen('Flip',ptbWindow);
disp('Break started');

while timePassed < waitTime
    pause(intervalTime);
    timePassed = timePassed + intervalTime;
    printTime = waitTime - timePassed;
    waitTimeText = ['Please wait for ' num2str(printTime) ' seconds...' ...
        ' \n\n ' ...
        ' \n\n Block ' (num2str(BLOCK+1)) ' will start afterwards.'];
    DrawFormattedText(ptbWindow,waitTimeText,'center','center',color.textVal);
    Screen('Flip',ptbWindow);
    disp(printTime);
end

% Quit
Screen('CloseAll');