% WML_test.m

% Originally written by Krista Ehinger, December 2012
% Downloaded on Oct 2, 2020 from : http://www.kehinger.com/PTBexamples.html
% Modified by Sophia Vinci-Booher in 2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sca; clear all; clc;
Screen('Preference','SkipSyncTests', 1);
PsychJavaTrouble;
localDir = '~/Desktop/wml-mri/';
% saveDir = fullfile(rootDir, 'data');

saveDir = '~/Google Drive/data-mri/';

% Add location of support files to path.
addpath(genpath(fullfile(localDir, 'supportFiles')));

settingsImageSequence; % Load all the settings from the file
rand('state', sum(100*clock)); % Initialize the random number generator

% User input.
prefs.subID = str2num(deblank(input('\nPlease enter the subID number (e.g., 101): ', 's')));%'101';

% Load in the mapping between the subID and training group.
load(fullfile(localDir, 'supportFiles/WML_subID_mappings.mat'));

%% Set session information.

% symbol counterbalance group: 1, 2, 3
prefs.group = symbol_counterbalance_group(find(subID == prefs.subID));
% scanning day: 1, 2, 3
prefs.day = str2num(deblank(input('\nPlease enter the MRI day (e.g., 1, 2, or 3): ', 's')));%'1';
% functional run: 1, 2
prefs.run = str2num(deblank(input('\nPlease enter the MRI run number (e.g., 1 or 2): ', 's')));%'1';

ch = input(['You have indicated that this run number ' num2str(prefs.run) ' of MRI day ' num2str(prefs.day) ' for participant ' num2str(prefs.subID) '. Is this entirely correct [y, n]? '], 's');
if strcmp(ch, 'no') || strcmp(ch, 'NO') || strcmp(ch, 'n') || strcmp(ch, 'N')
    error('Please start over and be sure to enter the information correctly.');
elseif ~strcmp(ch, 'yes') && ~strcmp(ch, 'YES') && ~strcmp(ch, 'y') && ~strcmp(ch, 'Y')
    error('Your response must be either y or n. Please start over and be sure to enter the information correctly.');
end
clear ch

%%%%%%%%%%%%%%%%%%%%% Parameters: DO NOT CHANGE. %%%%%%%%%%%%%%%%%%%%%%%%
prefs.backColor = [255 255 255];   % (0 0 0) is black, (255 255 255) is white
prefs.foreColor = [0 0 0];
prefs.scale = 150;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Screen.
% prefs.s1 = max(Screen('Screens')); % Choose the screen that is most likely not the controller screen.
prefs.s0 = min(Screen('Screens')); % Find primary screen.

%% Select window according to number of screens present. (Assumes that the desired device for display will have the highest screen number.)

% Choose dimension of window according to available screens. If only one
% screen available, them set the window to be a short portion of it b/c
% testing. If two screens are available, then set the window to be the
% % second screen b/c experiment.
%     [prefs.w1, prefs.w1Size] = PsychImaging('OpenWindow', prefs.s0, prefs.backColor);
prefs.w1Size = [0 0 1920 1200];
prefs.w1Width = prefs.w1Size(3); prefs.w1Height = prefs.w1Size(4);
prefs.xcenter = prefs.w1Width/2; prefs.ycenter = prefs.w1Height/2;
%     % Dimensions of stimulus presentation area.
prefs.rectForStim = [prefs.w1Width/2-prefs.scale/2 prefs.w1Height/2-prefs.scale/2 prefs.w1Width/2+prefs.scale/2 prefs.w1Height/2+prefs.scale/2];

% Hide cursor and orient to the Matlab command window for user input.
commandwindow;

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen
whichScreen = prefs.s0; %0 is computer, 1 is tablet
% window1=prefs.w1;
[window1, ~] = Screen('Openwindow',whichScreen,backgroundColor,prefs.w1Size,[],2);
slack = Screen('GetFlipInterval', window1)/2;
prefs.w1 = window1;
W=prefs.w1Width; % screen width
H=prefs.w1Height; % screen height
Screen(prefs.w1,'FillRect',prefs.backColor);
Screen('Flip', prefs.w1);
HideCursor([], prefs.w1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the image files for the experiment. There are different groups
% because the target/distractor symbols were counterbalanced across
% subjects.
if prefs.group == 1
    imageFolder = fullfile(localDir, 'stimuli/symbols_all_group1/');
elseif prefs.group == 2
    imageFolder = fullfile(localDir, 'stimuli/symbols_all_group2/');
elseif prefs.group == 3
    imageFolder = fullfile(localDir, 'stimuli/symbols_all_group3/');
end

% Select the distractor block, so that a participant does not see the same
% distractor more than once in the experiment and so that the distractors
% occur randomly across blocks between participants.
t_imgList = dir(fullfile(imageFolder,'S*.bmp'));
d_imgList = dir(fullfile(imageFolder,'D*.bmp'));
t_hand_imgList = dir(fullfile(imageFolder,'HS*.bmp'));
d_hand_imgList = dir(fullfile(imageFolder,'HD*.bmp'));
if prefs.day == 1 && prefs.run == 1
    d_imgList = d_imgList(distractor_list(161:200, prefs.subID));
elseif prefs.day == 2 && prefs.run == 1
    d_imgList = d_imgList(distractor_list(201:240, prefs.subID));
elseif prefs.day == 3 && prefs.run == 1
    d_imgList = d_imgList(distractor_list(241:280, prefs.subID));
elseif prefs.day == 1 && prefs.run == 2
    d_imgList = d_imgList(distractor_list(281:320, prefs.subID));
elseif prefs.day == 2 && prefs.run == 2
    d_imgList = d_imgList(distractor_list(321:360, prefs.subID));
elseif prefs.day == 3 && prefs.run == 2
    d_imgList = d_imgList(distractor_list(360:400, prefs.subID));
end

% Get the noise image files for the experiment
n_imageFolder = fullfile(localDir, 'stimuli/noise_masks/');

% % Select the noise images.
% n_imgList = dir(fullfile(n_imageFolder,'nm*.bmp'));

% Set up the output file
outputfile = fopen([saveDir '/mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '.txt'],'a');
fprintf(outputfile, 'subID\t block\t condition\t trial\t trial onset\t imageFile\t response\t RT\t imageFolder\n');

% Start screen
Screen('FillRect', prefs.w1, prefs.backColor);
PresentCenteredText(prefs.w1,'Ready?', 60, prefs.foreColor, prefs.w1Size);
Screen('Flip',prefs.w1);
% Wait for RA to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end

nTrials = 16;
nOneBacks = 2;

nBlocks = 12;
condition = Shuffle([repmat(1, [1 nBlocks/2]) repmat(2, [1 nBlocks/2]) repmat(3, [1 nBlocks/2]) repmat(4, [1 nBlocks/2])]); % four conditions:
% 1=learned, typed, 2=unlearned, typed, 3=learned, handwritten, 4=unlearned, handwritten.

% ListenChar(2);
for b = 1:nBlocks
    
    disp(['Block ', num2str(b)])
    
    % Fixation block before and after every condition block.
    % Show fixation cross
    drawCross(prefs.w1,W,H);
    tFixation = Screen('Flip', prefs.w1);
    
    % Record.
    if b == 1
        tStartAll = tFixation;
        fprintf(outputfile, '======= Beginning of first fixation at %2.2f ======\n', tFixation-tStartAll);
        fixationDuration = 20;
    else
        fprintf(outputfile, '======= Beginning of fixation number %d at %2.2f ======\n', b, tFixation-tStartAll);
        fixationDuration = 12; % Length of fixation in seconds
    end
    
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
    
    % Randomize the trial list
    randomizedTrials = set_onebacks(nTrials, nOneBacks);
    
    % Determine if this is a learned (condition == 1) or an unlearned
    % (condition ==2) block.
    if condition(b) == 1
        imgList = t_imgList;
    elseif condition(b) == 2
        imgList = d_imgList;
    elseif condition(b) == 3
        imgList = t_hand_imgList;
    elseif condition(b) == 4
        imgList = d_hand_imgList;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Run experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    trial = 0;
    % Run experimental trials
    for t = randomizedTrials
        
        trial = trial + 1;
        
        % Load image
        file = imgList(t).name;
        img = imread(fullfile(imageFolder,file));
        imageDisplay = Screen('MakeTexture', prefs.w1, img);
        
        %         % Load noise mask
        %         n_file = n_imgList(t).name;
        %         img = imread(fullfile(n_imageFolder,n_file));
        %         n_imageDisplay = Screen('MakeTexture', prefs.w1, img);
        
        % Screen priority
        Priority(MaxPriority(prefs.w1));
        Priority(2);
        
        % Show the images
        Screen(prefs.w1, 'FillRect', backgroundColor);
        Screen('DrawTexture', prefs.w1, imageDisplay, [], prefs.rectForStim);
        startTime = Screen('Flip', prefs.w1); % Start of trial
        
        % Get keypress response
        rt = 0;
        resp = 'NA';
        
        while (GetSecs - startTime) < trialTimeout
            
            [keyIsDown,secs,keyCode] = KbCheck;
            respTime = GetSecs;
            pressedKeys = find(keyCode);
            
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                clear all
                close all
                sca
                return;
            end
            
            % Check for response keys
            if ~isempty(pressedKeys)            
                for i = 1:length(responseKeys)                   
                    if KbName(responseKeys{i}) == pressedKeys(1)                       
                        resp = responseKeys{i};
                        rt = respTime - startTime;                     
                    end                  
                end              
            end
            
            % Replace symbol with fixation cross after 0.5 seconds. 
            if (GetSecs - startTime) >= symboldisplayduration
                
                drawCross(prefs.w1,W,H);
                Screen('Flip', prefs.w1); %0.50 is the amount of time the symbol should be shown
                
            end
            
        end
                
        % Blank screen
        Screen(window1, 'FillRect', backgroundColor);
        Screen('Flip', prefs.w1);
        
        % Save results to file
        fprintf(outputfile, '%d\t %d\t %d\t %d\t %2.2f\t %s\t %s\t %f\t %s\n',...
            prefs.subID, b, condition(b), trial, startTime-tStartAll, file, resp, rt, imageFolder);
        
        % Clear textures
        Screen(imageDisplay,'Close');
        
    end
    
    if b == nBlocks
        
        % Show fixation cross
        fixationDuration = 20; % Length of fixation in seconds
        drawCross(prefs.w1,W,H);
        tFixation = Screen('Flip', prefs.w1);
        fprintf(outputfile, '======= Beginning of final fixation at %2.2f ======\n', tFixation-tStartAll);
        
        % Blank screen
        Screen(window1, 'FillRect', backgroundColor);
        Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
        fprintf(outputfile, '======= End at %2.2f ======\n', GetSecs-tStartAll);
        
    end
    
end
toc
save(fullfile(saveDir, ['mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '.mat']))
ShowCursor;
% ListenChar(0);

% Backup cloud storage to local device.
copyfile(fullfile(saveDir, ['mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '.mat']), fullfile(localDir, 'data'));
copyfile(fullfile(saveDir, ['mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '.txt']), fullfile(localDir, 'data'));

% Start screen
Screen('FillRect', prefs.w1, prefs.backColor);
PresentCenteredText(prefs.w1,'All done!', 60, prefs.foreColor, prefs.w1Size);
Screen('Flip',prefs.w1);
% Wait for RA to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
fclose(outputfile);
Screen(window1,'Close');
close all
sca;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw a fixation cross (overlapping horizontal and vertical bar)
function drawCross(window,W,H)
barLength = 16; % in pixels
barWidth = 2; % in pixels
barColor = 0.5; % number from 0 (black) to 1 (white)
Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end