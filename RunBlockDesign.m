function  T = RunBlockDesign(prefs, win, T, vid_param,kb_pointer, tr_counter, ScanStartTime, ScanStartTimeSkippedBegin)
    % ====== [wb] Run block ===========
    % The actual experiment runs within this loop: 
    try
        disp('Run test...');
        curr_block = 1; 
        all_block_info = prefs.b;
        event_counter = 1;

        while curr_block <= length(all_block_info.conds)
            disp(['Block ' num2str(curr_block)]);  
            trials_info = all_block_info.trials(curr_block);
            for curr_trial = 1:length(trials_info.conds)
                % Initialize for event
                curr_start = GetSecs;
                if (strcmp(trials_info.conds(curr_trial), 'txt') == 1),
                    Screen('FillRect', win.ptr, prefs.colors.back);
                    DrawCross(win.ptr, win.centerX, win.centerY);
                    T.RealOnset(event_counter) = Screen('Flip', win.ptr);

                    Screen('FillRect', win.ptr, prefs.colors.back);
                    T.RealOffset(event_counter) = Screen('Flip', win.ptr, ...
                        T.RealOnset(event_counter)+trials_info.durs(curr_trial)-win.slack);

                elseif (strcmp(trials_info.conds(curr_trial), 'mov') == 1),
                    mov_f = char(trials_info.stim(curr_trial));
                    [mov, mov_dur, fps, imgw, imgh] = Screen('OpenMovie', win.ptr, mov_f);
                    Screen('PlayMovie', mov, 1, 1, 0);
                    T.RealOffset(event_counter) = GetSecs;
                    while (GetSecs < T.RealOffset(event_counter)+trials_info.durs(curr_trial))
                        
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
                        if (mov_texture>0)
                            vbl = Screen('Flip', win.ptr, 0, 1);
                            if isnan(T.RealOnset(event_counter))
                                T.RealOnset(event_counter) = vbl;
                            end
                        end
                    end
                    T.RealOffset(event_counter) = vbl;
                    Screen('FillRect', win.ptr, prefs.colors.back);
                    T.RealOffset(event_counter) = Screen('Flip', win.ptr); %blank the screen at end of movie
                    Screen('PlayMovie', mov, 0); % Stop playback
                    Screen('CloseMovie', mov); % Close movie
                end
                event_counter = event_counter + 1;
            end
            curr_block = curr_block + 1; 
        end

        %% Save data
        T.RealDur          = T.RealOffset -T.RealOnset;
        T.Onset_ScanStart  = T.RealOnset -ScanStartTimeSkippedBegin;
        now_date = datestr(now,'mm-dd-yyyy_HH_MM_SS');
        f_save = fullfile(prefs.dirs.subjDir, ...
            ['res_', prefs.subj, '_run_', num2str(prefs.runNum), '_', now_date, '.mat']);
        save(f_save, 'T', 'ScanStartTime', 'ScanStartTimeSkippedBegin', 'prefs');
        fprintf('\nSaved %s = %f sec.\n', f_save);
        
        %%
        EndBlankPage(win.ptr, prefs, kb_pointer, tr_counter);
        ShowCursor;
        KbQueueRelease(kb_pointer);
        KbReleaseWait(kb_pointer);
        Screen('CloseAll');
        ShowCursor;
        
    catch e
        %% Save data
        T.RealDur = T.RealOffset -T.RealOnset;
        T.Onset_ScanStart  = T.RealOnset -ScanStartTimeSkippedBegin;
        now_date = datestr(now,'mm-dd-yyyy_HH_MM_SS');
        f_save = fullfile(prefs.dirs.subjDir, ...
            ['res_', prefs.subj, '_run_', num2str(prefs.runNum), '_', now_date, '.mat']);
        save(f_save, 'T', 'ScanStartTime', 'ScanStartTimeSkippedBegin', 'prefs');
        fprintf('\nSaved %s = %f sec.\n', f_save);
        %%
        Screen('CloseAll');
        ShowCursor;
        commandwindow;
        disp('[Initialize] ERROR! terminating...');
        rethrow(e);
        %sca;
end
