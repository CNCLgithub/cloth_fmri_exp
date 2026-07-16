function [T, tr_log] = RunEventDesign(prefs, win, T, vid_param, kb_pointer, tr_counter, ScanStartTime, ScanStartTimeSkippedBegin, tr_log)
    %clear all;
    %load('data.mat'); 

    trial_key_response = nan(length(prefs.b.trials), 1);
    trial_key_rt = nan(length(prefs.b.trials), 1);

    try
        disp('Run event design test...');
        trials_info = prefs.b.trials;
        event_counter = 1;
        total_ans = 1;
        correct_ans = 0;

        for curr_trial = 1: length(prefs.b.trials)
            disp(['Trial ' num2str(curr_trial)]);
            curr_trial_info = trials_info(curr_trial);
            trial_start = GetSecs;

            %% 'Fixation'
            Screen('FillRect', win.ptr, prefs.colors.back);
            DrawCross(win.ptr, win.centerX, win.centerY, ...
                prefs.b.fix.fix_rect(curr_trial,1), ...
                prefs.b.fix.fix_rect(curr_trial,2));
            T.RealOnset(event_counter) = Screen('Flip', win.ptr);

            %% 'Resp'
            curTrialCorrect = 0;
            [T.BTN1(event_counter), T.RT1(event_counter), tr_counter, tr_log] = WaitLookingForKeys(prefs, win.ptr, 1, kb_pointer, tr_counter, ...
                T.RealOnset(event_counter), ...
                T.RealOnset(event_counter)+trials_info(curr_trial).durs(1)-win.slack, ...
                tr_log);

            trial_key_response(curr_trial) = T.BTN1(event_counter);
            trial_key_rt(curr_trial) = T.RT1(event_counter);

            if prefs.b.fix.fix_rect(curr_trial,1) > prefs.b.fix.fix_rect(curr_trial,2)
                if T.BTN1(event_counter) == prefs.keys.yes,
                    correct_ans = correct_ans + 1;
                    curTrialCorrect = 1;
                end
            elseif prefs.b.fix.fix_rect(curr_trial,1) < prefs.b.fix.fix_rect(curr_trial,2)
                if T.BTN1(event_counter) == prefs.keys.no,
                    correct_ans = correct_ans + 1;
                    curTrialCorrect = 1;
                end
            end   
            fprintf("\n Trial:[%d], curTrialCorrect= [%d], TotalCorrect = [%d] , ACC = [%f] \n", curr_trial, curTrialCorrect, correct_ans, correct_ans*1.0/total_ans);
            total_ans = total_ans + 1;
            % T.TR(event_counter) = tr_counter;
            T.RealOffset(event_counter) = Screen('Flip', win.ptr);  
            event_counter = event_counter + 1;
            
            
            
            %% 'Movie'
            mov_f = char(trials_info(curr_trial).stim);
            [mov, mov_dur, fps, imgw, imgh] = Screen('OpenMovie', win.ptr, mov_f);  %WB%: append '4' to avoid drop of frames
            Screen('PlayMovie', mov, 1, 0, 0);
            while (GetSecs < T.RealOffset(event_counter-1) + trials_info(curr_trial).durs(2))
                [pressed, firstPress] = KbQueueCheck(kb_pointer);
                if pressed
                    if find(firstPress) == prefs.keys.quit
                        sca;
                        KbQueueRelease(kb_pointer);
                        KbReleaseWait(kb_pointer);
                        error('User quit');
                    elseif find(firstPress) == prefs.keys.trigger
                       tr_counter = tr_counter + 1;
                       tr_log = [tr_log, [tr_counter, GetSecs]];
                    end
                    pressed = 0;
                    KbQueueFlush(kb_pointer);
                end
                
                mov_texture = Screen('GetMovieImage', win.ptr, mov);
                % Valid texture returned? A negative value means end of movie reached:
                if mov_texture>0
                    Screen('DrawTexture', win.ptr, mov_texture, [], vid_param.rect);
                    Screen('Close', mov_texture); 
                end

                if (mov_texture>0)
                    vbl = Screen('Flip', win.ptr, 0, 1);
                    if isnan(T.RealOnset(event_counter))
                        T.RealOnset(event_counter) = vbl;
                    end
                end
                
                if mov_texture <= 0
                    break;
                end
            end
            
            Screen('FillRect', win.ptr, prefs.colors.back);
            T.RealOffset(event_counter) = Screen('Flip', win.ptr); %blank the screen at end of movie
            Screen('PlayMovie', mov, 0); % Stop playback
            Screen('CloseMovie', mov); % Close movie

            event_counter = event_counter + 1;

            %% 'ISI'
            Screen('FillRect', win.ptr, prefs.colors.back);
            T.RealOnset(event_counter) = Screen('Flip', win.ptr);

            Screen('FillRect', win.ptr, prefs.colors.back);
            T.RealOffset(event_counter) = Screen('Flip', win.ptr, T.RealOnset(event_counter)+trials_info(curr_trial).durs(3)-win.slack);
            event_counter = event_counter + 1;

        end

        %% Save data
        T.RealDur = T.RealOffset -T.RealOnset;
        T.Onset_ScanStart  = T.RealOnset -ScanStartTimeSkippedBegin;
        now_date = datestr(now,'mm-dd-yyyy_HH_MM_SS');
        f_save = fullfile(prefs.dirs.subjDir, ...
            ['res_', prefs.subj, '_run_', num2str(prefs.runNum), '_', now_date, '.mat']);

        save(f_save, 'T', 'trial_key_response', 'trial_key_rt', ...
            'ScanStartTime', 'ScanStartTimeSkippedBegin', 'prefs', 'tr_log');

        fprintf('\nSaved %s = %f sec.\n', f_save);
        
        EndBlankPage(win.ptr, prefs, kb_pointer, tr_counter);
        Screen('CloseAll');
        ShowCursor;
        KbQueueRelease(kb_pointer);
        KbReleaseWait(kb_pointer);
    catch e
        KbQueueRelease(kb_pointer);
        KbReleaseWait(kb_pointer); 
        
        %% Save data
        T.RealDur = T.RealOffset -T.RealOnset;
        T.Onset_ScanStart  = T.RealOnset -ScanStartTimeSkippedBegin;
        now_date = datestr(now,'mm-dd-yyyy_HH_MM_SS');
        f_save = fullfile(prefs.dirs.subjDir, ...
            ['res_', prefs.subj, '_run_', num2str(prefs.runNum), '_', now_date, '.mat']);

        save(f_save, 'T', 'trial_key_response', 'trial_key_rt', ...
            'ScanStartTime', 'ScanStartTimeSkippedBegin', 'prefs', 'tr_log');

        fprintf('\nSaved %s = %f sec.\n', f_save);
           
        Screen('CloseAll');
        ShowCursor;
        commandwindow;
        disp('[Initialize] ERROR! terminating...');
        rethrow(e);
        %sca;
end