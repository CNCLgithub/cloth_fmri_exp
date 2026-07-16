function [tr_counter, ScanStartTimeSkippedBegin, tr_log] = BeginWait(win, prefs, kb_pointer, tr_counter, tr_log)
    pressed = 0;
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);
    while (tr_counter < prefs.begin_wait) && (~pressed)
        [pressed, firstPress] = KbQueueCheck(kb_pointer);
        
        DrawCenteredText(win, ['The experiment will begin in ' ...,
            num2str(prefs.begin_wait-tr_counter) '.'], prefs.colors.fore, 0, 0);
        Screen('Flip', win);
        
        if pressed
            if find(firstPress) == prefs.keys.trigger
                tr_counter = tr_counter+1;
                tr_log = [tr_log, [tr_counter, GetSecs]];
                KbQueueFlush(kb_pointer);
            end
            pressed = 0;
        end
    end

    % Blank screen and return time
    Screen('FillRect', win, prefs.colors.back);
    ScanStartTimeSkippedBegin = Screen('Flip', win);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);  
end


%     pressed = 0;
%     KbReleaseWait;
%     while (tr_counter < prefs.begin_wait) && (~pressed)
%         DrawCenteredText(win, ['The next video will begin in ' ...,
%             num2str(prefs.begin_wait-tr_counter) ' seconds.'], prefs.colors.fore, ...
%             30, 30);
%         Screen('Flip', win);
%         
%         % Wait for trigger
%         [keyIsDown, secs, keyCode] = KbCheck;
%         if keyIsDown
%             if any(keyCode(prefs.keys.trigger))
%                 tr_counter = tr_counter + 1;
%                 ScanStartTimeSkippedBegin = secs;
%                 pressed = 0;
%             end
%             KbReleaseWait;
%         end
%     end
%     updated_tr_counter = tr_counter;