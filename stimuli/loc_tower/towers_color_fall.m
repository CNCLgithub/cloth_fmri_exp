function [] = towers_color_fall(prefs, kb_pointer, screen_res)

% each run contains 23 blocks:
% 3 baseline (blank black screen)
% 10 physics
% 10 color
% color task: more blue or yellow blocks?
% physics task: fall to the red or green side?
% responses taken during ISI
% 2 movies per block; 18 s per block; total 414 s; 6:54 minutes
% 207 volumes with a 2s TR

%%
subj_ID     = prefs.subj;
run_num = -1;
if prefs.runNum == 4
    run_num = 1;
elseif prefs.runNum == 7
    run_num = 2;
end
keys        = prefs.keys;
begin_wait  = prefs.begin_wait;
foreColor   = [255 255 255];
mov_size    = min(screen_res(3), screen_res(4));
mov_rect    = [0 0 mov_size mov_size];
text_size   = 35;

rng('default');
curDir = prefs.dirs.loc_tower_dir;
stim_dir = fullfile(curDir, 'new_towers_movies');
save_path = fullfile(curDir, 'results/');
if (~exist(save_path, 'dir')), mkdir(save_path); end


%% create trial list
for flag=1
    %
    if run_num == 1
        movie_list = {'19c' '21c' '12c' '45b' '48b' '47b' '51b' '8a'  '9a'  '33b'...
            '15c' '26b' '24a' '41c' '5a'  '17b' '36a' '29c' '27a' '31a'};
    elseif run_num == 2
        movie_list = {'40c' '11c' '13c' '16b' '18c' '10b' '14a' '20c' '2b' '37a'...
            '22c' '3a'  '6a'  '25a' '23b' '32c' '42b' '28b' '7c' '34b'};
    else
        error('Invalid run number (must be 1 or 2)');
    end
    
    % 0 = baseline, 1 = physics, 2 = color
    block_order = [0 1 2 1 1 2 2 1 2 1 2 0 2 1 2 1 2 2 1 1 2 1 0;
        0 2 1 2 2 1 1 2 1 2 1 0 1 2 1 2 1 1 2 2 1 2 0];

    physics_list = Shuffle(movie_list);
    color_list = Shuffle(movie_list);
    physics_list_counter = 1;
    color_list_counter = 1;
    movie_filenames = {};

    %handle duplicate filename
    if exist([save_path  subj_ID '_newtowers_blockorder' num2str(run_num) '.txt'],'file')
        overwrite = input('A file is already saved with this name. Overwrite? (y/n): ','s');
        if overwrite == 'y' %do nothing
        else %anything besides 'y', input new name
            subj_ID = input('Enter a new run identifier: ','s');
        end
    end

    save_file = fopen([save_path subj_ID '_newtowers_blockorder' num2str(run_num) '.txt'],'w');
end

%% set up experiment
for falg = 1
    Screen('Preference', 'SkipSyncTests', 1);
    AssertOpenGL;
    KbReleaseWait; % Wait until user releases keys on keyboard
    screenNumber   = max(Screen('Screens'));
    black          = BlackIndex(screenNumber);
    backColor      = black;
    [w, screenRect]=Screen('OpenWindow',screenNumber, backColor, screen_res);
    movie_rect     = CenterRect(mov_rect,screenRect); %scanner projector is 1024 x 768
    Screen(w, 'TextSize', text_size);

    % load cue images and make textures
    cue_image = imread(fullfile(stim_dir,'physics_cue.png'));
    cue_tex(1) = Screen('MakeTexture', w, cue_image);
    cue_image = imread(fullfile(stim_dir,'color_cue.png'));
    cue_tex(2) = Screen('MakeTexture', w, cue_image);

    %% start experiment
    priorityLevel = MaxPriority(w);
    Priority(priorityLevel);

    %display run ready message
    Screen(w,'DrawText','Ready...',250,250,250);
    Screen('Flip', w);
end


%% wait for trigger
while 1
    [~, ~, keyCode] = KbCheck(-1);
    if  keyCode(KbName('5%'))
        break
    end
end

%% ==================== Wait triggers ====================================%

for waitForTrigger = 1
    pressed = 0;
    DrawCenteredText(w, 'Waiting for scanner...', foreColor);
    Screen('Flip', w);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);  
    fprintf('After flushing kbqueue...\n');
    while ~pressed % Wait for the first pulse
        [pressed,firstPress] = KbQueueCheck(kb_pointer);
        if pressed
            if find(firstPress) == keys.trigger
                fprintf('\nDetected pulse \n')
                tr_counter = 1;
                KbQueueFlush(kb_pointer);
                break;
            end
            pressed = 0;
        end
    end
    Screen('FillRect', w, backColor);
    ScanStartTime = Screen('Flip', w);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer); 
end


for beginWait = 1
    pressed = 0;
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);
    while (tr_counter < begin_wait) && (~pressed)
        [pressed, firstPress] = KbQueueCheck(kb_pointer);
        
        DrawCenteredText(w, ['The experiment will begin in ' ...,
            num2str(begin_wait-tr_counter) '.'], foreColor, 0, 0);
        Screen('Flip', w);
        
        if pressed
            if find(firstPress) == keys.trigger
                tr_counter = tr_counter+1;
                KbQueueFlush(kb_pointer);
            end
            pressed = 0;
        end
    end

    % Blank screen and return time
    Screen('FillRect', w, backColor);
    ScanStartTimeSkippedBegin = Screen('Flip', w);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);  
end

run_start_time = ScanStartTimeSkippedBegin;
save([save_path subj_ID '_newtowers_blockorder' num2str(run_num) '.mat']);
%%
for block_num = 1:size(block_order,2)
    disp(['Block ' num2str(block_num)]);  
    
    block_type = block_order(run_num,block_num);
    disp(['Block ' num2str(block_num) '; Block type ' num2str(block_type)]);  
    
    switch block_type
        
        case 0 %baseline - no movie presentation
            
        case 1 %physics judgment
            movie_filenames{1} = [physics_list{physics_list_counter} '.mov'];
            movie_filenames{2} = [physics_list{physics_list_counter+1} '.mov'];
            physics_list_counter = physics_list_counter + 2;
            task = 'physics';
        case 2 %color judgment
            movie_filenames{1} = [color_list{color_list_counter} '.mov'];
            movie_filenames{2} = [color_list{color_list_counter+1} '.mov'];
            color_list_counter = color_list_counter + 2;
            task = 'color';
    end
    
    
    if block_order(run_num,block_num) > 0 %if not a baseline block
        
        for movie_num = 1:2
%             DrawCenteredText(w, cue_tex{block_type}, [0,0,0], 0, 0);
            Screen('DrawTexture', w, cue_tex(block_type), [], movie_rect);
            Screen('Flip', w);
            % fprintf(save_file,'%4.3f\t%i\t%s\t%s\t',run_start_time + 18*(block_num-1) + 9*(movie_num-1) + 1,block_num,movie_filenames{movie_num},task); %record movie name to save file
            fprintf(save_file,'%4.3f\t%i\t%i\t%i\t%s\t%s',18*(block_num-1) + 9*(movie_num-1),block_type,9,block_num,task,movie_filenames{movie_num}); %record to save file
        
            response = 0; %will contain the subject's response
            movie = Screen('OpenMovie', w, fullfile(stim_dir, movie_filenames{movie_num})); % Open movie file
            Screen('PlayMovie', movie, 1); % Start playback engine
            
            while GetSecs < (run_start_time + 18*(block_num-1) + 9*(movie_num-1) + 1);end %wait for movie start time
            
            while 1 %Playback loop
                
                tex = Screen('GetMovieImage', w, movie); % Wait for next movie frame, retrieve texture handle to it
                
                % Valid texture returned? A negative value means end of movie reached
                if tex<=0% We're done, break out of loop
                    break;
                end;
                
                Screen('DrawTexture', w, tex, [], movie_rect); % Draw the new texture immediately to screen
                Screen('Flip', w);
                Screen('Close', tex); % Release texture
                
            end;
            
            Screen('Flip', w); %blank the screen at end of movie
            Screen('PlayMovie', movie, 0); % Stop playback
            Screen('CloseMovie', movie); % Close movie
            
            while GetSecs < (run_start_time + 18*(block_num-1) + 9*movie_num) %pause until end of trial
%                 [~, ~, keyCode] = KbCheck(-1);
%                 if  sum(keyCode) && ~(keyCode(KbName('=+')) || keyCode(KbName('+')))
%                     response = find(keyCode,1);
%                 end
%                 
                [pressed, firstPress] = KbQueueCheck(kb_pointer);
                if pressed
                    if find(firstPress) == keys.trigger
                        tr_counter = tr_counter + 1;
                    elseif find(firstPress) == keys.quit
                        KbQueueFlush(kb_pointer);
                        KbEventFlush(kb_pointer);
                        sca;
                        error('User quit');
                    elseif find(firstPress) == keys.yes
                        response = keys.yes;
                    elseif find(firstPress) == keys.no
                        response = keys.no;
                    end
                    pressed = 0;
                    KbQueueFlush(kb_pointer);
                end 
            end
            
            fprintf(save_file,'%i\n',response); %record response to save file
            
        end %end two movies
        
    else %baseline block
        
        fprintf(save_file,'%4.3f\t%i\t%i\t%i\t%s\n',18*block_num - 18,block_type,18,block_num,'Baseline'); %record to save file
        
        while GetSecs < (run_start_time + 18*block_num) %wait for end of baseline period
            
            [pressed, firstPress] = KbQueueCheck(kb_pointer);
            if pressed
                if find(firstPress) == keys.trigger
                    tr_counter = tr_counter + 1;
                elseif find(firstPress) == keys.quit
                    KbQueueFlush(kb_pointer);
                    KbEventFlush(kb_pointer);
                    sca;
                    error('User quit');
                end
                pressed = 0;
                KbQueueFlush(kb_pointer);
            end 
            
        end
        
    end %end block
    
    %Abort if escape is pressed
end

%end of run - clean up
disp('total run time:')
disp(GetSecs - run_start_time)
fclose(save_file);



Priority(0);
Screen('CloseAll');
FlushEvents;
KbQueueFlush(kb_pointer);
KbEventFlush(kb_pointer);
% end %end main function
