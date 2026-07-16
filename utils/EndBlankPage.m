function EndBlankPage(win, prefs, kb_pointer, tr_counter)
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);
    
    startT = GetSecs;
    while ( GetSecs < startT+10 )
        [pressed, firstPress] = KbQueueCheck(kb_pointer);
%         Screen('FillRect', win, prefs.colors.back);
        DrawCenteredText(win, ['END'], prefs.colors.fore, 0, 0);
        Screen('Flip', win);
        
        if pressed
            if find(firstPress) == prefs.keys.trigger
                tr_counter = tr_counter+1;
                KbQueueFlush(kb_pointer);
                startT = GetSecs;
            end
            pressed = 0;
        end
    end

    % Blank screen and return time
    Screen('FillRect', win, prefs.colors.back);
    ScanEndTime = Screen('Flip', win);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);  
end