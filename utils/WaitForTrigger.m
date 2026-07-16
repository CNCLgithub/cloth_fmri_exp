function [tr_counter, ScanStartTime] = WaitForTrigger(win, prefs, kb_pointer, title)
    %%
    if nargin < 3, title = 'Waiting for scanner...'; end
    %%
    pressed = 0;
    DrawCenteredText(win, title, prefs.colors.fore);
    Screen('Flip', win);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer);  
    fprintf('After flushing kbqueue...\n');
    while ~pressed % Wait for the first pulse
        [pressed,firstPress] = KbQueueCheck(kb_pointer);
        if pressed
            prefs.keys.trigger
            if find(firstPress) == prefs.keys.trigger
                fprintf('\nDetected pulse \n')
                tr_counter = 1;
                KbQueueFlush(kb_pointer);
                break;
            end
            pressed = 0;
        end
    end
    Screen('FillRect', win, prefs.colors.back);
    ScanStartTime = Screen('Flip', win);
    KbQueueFlush(kb_pointer);
    KbEventFlush(kb_pointer); 
end



%     
%     % Draw the title
%     DrawCenteredText(win, title, prefs.colors.fore);
%     Screen('Flip', win);
%     
%     % Wait for trigger
%     trigger_key = prefs.keys.trigger;
%     KbReleaseWait;
%     [keyIsDown, secs, keyCode] = KbCheck;
%     while ~any(keyCode(trigger_key))
%         [keyIsDown, secs, keyCode] = KbCheck;
%         ScanStartTime = secs;
%         KbReleaseWait;
%     end
%     fprintf('\n Detected pulse... \n');
%     
%     % Blank screen and return time
%     Screen('FillRect', win, prefs.colors.back);
%     Screen('Flip', win);