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
symbolduration = 1;
isi = [1.3 1.5 1.7]; % 1 seconds for TR = 1
drawduration = 4;
wei = [1.7 1.5 1.3];
epochduration = 8;

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
prefs.backcolor = [255 255 255];   % (0 0 0) is black, (255 255 255) is white, (220 220 220) is gainsboro (i.e., light gray)
prefs.forecolor = [0 0 0];
prefs.penWidth = 6; % You can increase the thickness of the pen-tip by increasing this number, but there's a limit to the thickness... around 10 maybe.
prefs.scale = 150;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Screen.
prefs.s1 = max(Screen('Screens')); % Choose the screen that is most likely not the controller screen.
prefs.s0 = min(Screen('Screens')); % Find primary screen.

%% Select window according to number of screens present. (Assumes that the desired device for display will have the highest screen number.)

% Choose dimension of window according to available screens. If only one
% screen available, them set the window to be a short portion of it b/c
% testing. If two screens are available, then set the window to be the
% % second screen b/c experiment.
%     [prefs.w1, prefs.w1Size] = PsychImaging('OpenWindow', prefs.s0, prefs.backcolor);
prefs.w1Size = [0 0 640 480]; %[0 0 1920 1200];
prefs.w1Width = prefs.w1Size(3); prefs.w1Height = prefs.w1Size(4);
prefs.xcenter = prefs.w1Width/2; prefs.ycenter = prefs.w1Height/2;
%     % Dimensions of stimulus presentation area.
prefs.rectForStim = [prefs.w1Width/2-prefs.scale/2 prefs.w1Height/2-prefs.scale/2 prefs.w1Width/2+prefs.scale/2 prefs.w1Height/2+prefs.scale/2];
% prefs.rectForStim = [prefs.w1Width/2-prefs.scale/2 prefs.w1Height/5-prefs.scale/2 prefs.w1Width/2+prefs.scale/2 prefs.w1Height/5+prefs.scale/2];

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

%% Select window according to number of screens present. (Assumes that the desired display device will have the highest screen number.)

% Choose dimension of window according to available screens. If only one
% screen is available, them set the window to be a short portion of it b/c
% testing. If two screens are available, then set the window to be the
% second screen b/c experiment.
whichScreen = prefs.s0; %0 is computer, 1 is tablet
[window1, ~] = Screen('Openwindow', whichScreen, prefs.backcolor, prefs.w1Size,[],2);
slack = Screen('GetFlipInterval', window1)/2;
prefs.w1 = window1;
W=prefs.w1Width; % screen width
H=prefs.w1Height; % screen height

Screen(prefs.w1,'FillRect',prefs.backcolor);
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

% Read in target symbols.
if prefs.group == 1
    tsymbol_dir = dir(fullfile(localDir, 'stimuli', 'symbols_all_group1/S*'));
elseif prefs.group == 2
    tsymbol_dir = dir(fullfile(localDir, 'stimuli', 'symbols_all_group2/S*'));
elseif prefs.group == 3
    tsymbol_dir = dir(fullfile(localDir, 'stimuli', 'symbols_all_group3/S*'));
end

% Remove the '.' and '..' files.
tsymbol_dir = tsymbol_dir(arrayfun(@(x) x.name(1), tsymbol_dir) ~= '.');

% Get the noise image files for the experiment
n_imageFolder = fullfile(localDir, 'stimuli/noise_masks/');
n_imgList = dir(fullfile(n_imageFolder, 'nm*.bmp'));

% Set up the output file
outputfile = fopen([saveDir '/mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '_' datestr(now,'mm-dd-yyyy_HH-MM') '.txt'],'a');
fprintf(outputfile, 'subID\t block\t condition\t trial\t trial onset\t imageFile\t response\t RT\t imageFolder\t drawduration\n');

% Start screen
Screen('FillRect', prefs.w1, prefs.backcolor);
PresentCenteredText(prefs.w1,'Ready?', 60, prefs.forecolor, prefs.w1Size);
Screen('Flip',prefs.w1);
% Wait for RA to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end

nTrials = 40;
nBlocks = 3;

count = 0;
for b = 1:nBlocks
    
    disp(['Block ', num2str(b)])
    count = count + 1;
    
    % Fixation block before and after every condition block.
    % Show fixation cross
    drawCross(prefs.w1,W,H);
    tFixation = Screen('Flip', prefs.w1);
    
    % Record.
    if b == 1
        tStartAll = tFixation;
        fprintf(outputfile, '======= Beginning of first fixation at %2.2f ======\n', tFixation-tStartAll);
        fixationDuration = 2;
    else
        fprintf(outputfile, '======= Beginning of fixation number %d at %2.2f ======\n', b, tFixation-tStartAll);
        fixationDuration = 12; % Length of fixation in seconds
    end
    
    % Blank screen
    Screen(window1, 'FillRect', prefs.backcolor);
    Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
    
    % Randomize the trial list
    randomizedTrials = randperm(nTrials);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Run experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    trial = 0;
    % Run experimental trials
    for t = randomizedTrials
        
        trial = trial + 1;
        idx = randi(3);
        
        % Load symbol image
        file = tsymbol_dir(t).name;
        img = imread(fullfile(imageFolder,file));
        imageDisplay = Screen('MakeTexture', prefs.w1, img);
        
        % Load noise image
        nimg = imread(fullfile(n_imgList(t).folder , n_imgList(t).name));
        nimageDisplay = Screen('MakeTexture', prefs.w1, nimg);
        
        % Screen priority
        Priority(MaxPriority(prefs.w1));
        Priority(2);
        
        %% Stimulation Time 1: typed symbol
        
        % Show the typed symbol
        Screen(prefs.w1, 'FillRect', prefs.backcolor);
        Screen('DrawTexture', prefs.w1, imageDisplay, [], prefs.rectForStim);
        startTime = Screen('Flip', prefs.w1); % Start of trial
        
        while ((GetSecs - startTime) < symbolduration)
            
            [keyIsDown,secs,keyCode] = KbCheck;
            pressedKeys = find(keyCode);
            
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                %                 clear all
                close all
                sca
                return;
            end
            
        end
        
        %% Stimulation Time 2:  noise for 2 seconds.
        
        % Replace symbol with noise after display is over.
        Screen(prefs.w1, 'FillRect', prefs.backcolor);
        Screen('DrawTexture', prefs.w1, nimageDisplay, [], prefs.rectForStim);
        endTime = Screen('Flip', prefs.w1); % End of trial
        
        while (GetSecs - startTime) < symbolduration + isi(idx)
            
            [keyIsDown,secs,keyCode] = KbCheck;
            pressedKeys = find(keyCode);
            
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                %                 clear all
                close all
                sca
                return;
            end
            
        end
        
        %% Stimulation Time 2: draw for 4 seconds.
        
        % Move mouse to projector
%         SetMouse((ceil(prefs.w1Width / 2) + prefs.w0Width), ceil(prefs.w1Height / 2))
        
        % Get and display drawing input.
        %         [prefs] = drawInk2_noboundarybox(prefs); %for wacom tablet
        
        prefs.lengthEvents = drawduration;
        [prefs] = drawInk2(prefs); %for wacom tablet
        
        % Append the sample from this round to the end of the sample struct.
        sample(count).subID = prefs.subID;
        sample(count).group = prefs.group;
        sample(count).day = prefs.day;
        sample(count).symbolname = file;
        sample(count).block = b;
        sample(count).trial = trial;
        
        % Save drawing duration.
        if max(prefs.time)-min(prefs.time) > 0.01
            
            sample(count).drawduration = max(prefs.time)-min(prefs.time);
            
        else
            sample(count).drawduration = NaN;
            
        end
        
        % Save dynamic stim for yoked participant.
        sample(count).dynamicStim = prefs.dynamicStim;
        
        % Save static stim.
        sample(count).staticStim = prefs.image;
        
        %% Stimulation Time 4: rest for jittered interval.
        drawCross(prefs.w1,W,H);
        Screen('Flip', prefs.w1);
        while (GetSecs - startTime) < epochduration
            
            [keyIsDown,secs,keyCode] = KbCheck;
            pressedKeys = find(keyCode);
            
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                %                 clear all
                close all
                sca
                return;
            end
            
        end
        
    end
    
    
    
    
    
    %
    %         % Blank screen
    %         Screen(window1, 'FillRect', prefs.backcolor);
    %         Screen('Flip', prefs.w1);
    %
    %         % Save results to file
    %         fprintf(outputfile, '%d\t %d\t %d\t %d\t %2.2f\t %s\t %s\t %f\t %s\n',...
    %             prefs.subID, b, trial, startTime-tStartAll, file, imageFolder);
    %
    %         % Clear textures
    %         Screen(imageDisplay,'Close');
    %
    %         %     end
    %
    
    
    
    % Final fixation
    if b == nBlocks
        
        % Show fixation cross
        fixationDuration = 20; % Length of fixation in seconds
        drawCross(prefs.w1,W,H);
        tFixation = Screen('Flip', prefs.w1);
        fprintf(outputfile, '======= Beginning of final fixation at %2.2f ======\n', tFixation-tStartAll);
        
        % Blank screen
        Screen(window1, 'FillRect', prefs.backcolor);
        Screen('Flip', prefs.w1, tFixation + fixationDuration - slack,0);
        fprintf(outputfile, '======= End at %2.2f ======\n', GetSecs-tStartAll);
        
    end
    
end

save(fullfile(saveDir, ['mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '.mat']))
ShowCursor;
% ListenChar(0);

% Backup cloud storage to local device.
copyfile(fullfile(saveDir, ['mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '.mat']), fullfile(localDir, 'data'));
copyfile(fullfile(saveDir, ['mri_sub' num2str(prefs.subID) '_session' num2str(prefs.day) '_run' num2str(prefs.run) '.txt']), fullfile(localDir, 'data'));

% Start screen
Screen('FillRect', prefs.w1, prefs.backcolor);
PresentCenteredText(prefs.w1,'All done!', 60, prefs.forecolor, prefs.w1Size);
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