function [tr_counter, ScanEndTime] = EndWait(win, prefs, kb_pointer, tr_counter)
    pressed = 0;
    tr_ending_counter = tr_counter + prefs.end_wait;

    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);
    while (tr_counter < tr_ending_counter) && (~pressed)
        [pressed, firstPress] = KbQueueCheck(kb_pointer);
        
        DrawCenteredText(win, ['The experiment will end in ' ...,
            num2str(tr_ending_counter-tr_counter) '.'], prefs.foreColor, 0, 0);
        Screen('Flip', win);
        
        if pressed
            if find(firstPress) == prefs.keys.trigger
                tr_counter = tr_counter+1;
                KbQueueFlush(kb_pointer);
            end
            pressed = 0;
        end
    end

    % Blank screen and return time
    Screen('FillRect', win, prefs.backColor);
    ScanEndTime = Screen('Flip', win);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);  
end
