function T = RunEventDesign(prefs, win, T, vid_param, kb_pointer, tr_counter, ScanStartTime, ScanStartTimeSkippedBegin)
    %clear all;
    %load('data.mat'); 
    try
        disp('Run event design test...');
        trials_info = prefs.b.trials;
        event_counter = 1;

        for curr_trial = 1: length(prefs.b.trials)
            disp(['Trial ' num2str(curr_trial)]);
            curr_trial_info = trials_info(curr_trial);
            trial_start = GetSecs;

            %% 'Fixation'
            Screen('FillRect', win.ptr, prefs.colors.back);
            DrawCross(win.ptr, win.centerX, win.centerY);
            T.RealOnset(event_counter) = Screen('Flip', win.ptr);
            event_counter = event_counter + 1;

            %% 'Movie'
            mov_f = char(trials_info(curr_trial).stim);
            [mov, mov_dur, fps, imgw, imgh] = Screen('OpenMovie', win.ptr, mov_f);
            Screen('PlayMovie', mov, 1, 0, 0);
            while GetSecs < (T.RealOnset(event_counter-1) + trials_info(curr_trial).durs(1)); end
            T.RealOffset(event_counter-1) = GetSecs;            
            while (GetSecs < T.RealOffset(event_counter-1) + trials_info(curr_trial).durs(2))
                
                [pressed, firstPress] = KbQueueCheck(kb_pointer);
                if pressed
                    if find(firstPress) == prefs.keys.quit
                        sca;
                        KbQueueRelease(kb_pointer);
                        KbReleaseWait(kb_pointer);
                        error('User quit');
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
                
%                 % Show probe
%                 if (GetSecs > T.RealOffset(event_counter-1) + prefs.b.probe.probe_onset(curr_trial,1)) && ...
%                         (GetSecs < T.RealOffset(event_counter-1) + prefs.b.probe.probe_onset(curr_trial,2))
%                     Screen('FillOval', win.ptr, prefs.b.probe.probe_color, ...
%                         [prefs.b.probe.probe_rect(curr_trial,1), ...
%                          prefs.b.probe.probe_rect(curr_trial,2), ...
%                          prefs.b.probe.probe_rect(curr_trial,1)+prefs.b.probe.probe_diam,...
%                          prefs.b.probe.probe_rect(curr_trial,2)+prefs.b.probe.probe_diam]);
%                 end

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
            T.RealOffset(event_counter) = Screen('Flip', win.ptr, ...
                T.RealOnset(event_counter)+trials_info(curr_trial).durs(3)-win.slack);
            event_counter = event_counter + 1;

            %% 'Resp'
            event_counter = event_counter + 1;
        end

        %% Save data
        T.RealDur = T.RealOffset -T.RealOnset;
        T.Onset_ScanStart  = T.RealOnset -ScanStartTimeSkippedBegin;
        now_date = datestr(now,'mm-dd-yyyy_HH_MM_SS');
        f_save = fullfile(prefs.dirs.subjDir, ...
            ['res_', prefs.subj, '_run_', num2str(prefs.runNum), '_', now_date, '.mat']);
        save(f_save, 'T', 'ScanStartTime', 'ScanStartTimeSkippedBegin', 'prefs');
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
        save(f_save, 'T', 'ScanStartTime', 'ScanStartTimeSkippedBegin', 'prefs');
        fprintf('\nSaved %s = %f sec.\n', f_save);
           
        Screen('CloseAll');
        ShowCursor;
        commandwindow;
        disp('[Initialize] ERROR! terminating...');
        rethrow(e);
        %sca;
end


