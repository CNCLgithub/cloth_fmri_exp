%--------------------------------------------------------------------------
function [key1, rt1, tr_counter, tr_log] = WaitLookingForKeys(prefs, win, for_resp, kb_pointer, tr_counter, start, timeOut, tr_log)
%    if nargin < 6, start = GetSecs(); end
%    if nargin < 7, timeOut = -1; end
    
   % Initialize variables
   key1    = -1; 
   rt1     = -1; 
   pressed = 0;
   KbQueueFlush(kb_pointer);
   KbEventFlush(kb_pointer);

   if ~for_resp
       %WB% [trigger, quit]
       while (GetSecs < timeOut)
           [pressed, firstPress] = KbQueueCheck(kb_pointer);
           if pressed
               if find(firstPress) == prefs.keys.trigger
                   tr_counter = tr_counter + 1;
                   tr_log = [tr_log, [tr_counter, GetSecs]];
               elseif find(firstPress) == prefs.keys.quit
                   sca;
                   error('User quit');
               end
               pressed = 0;
               KbQueueFlush(kb_pointer);
           end
       end
   else
       %WB% [trigger, quit, yes, no]
       while (GetSecs < timeOut)
           [pressed, firstPress] = KbQueueCheck(kb_pointer);
           if pressed
               rt = GetSecs - start;
               if find(firstPress) == prefs.keys.trigger
                   tr_counter = tr_counter + 1;
                   tr_log = [tr_log, [tr_counter, GetSecs]];
               elseif find(firstPress) == prefs.keys.yes
                   rt1 = rt;
                   key1 = prefs.keys.yes;
                   Screen('FillRect', win, prefs.colors.back);
                   start = Screen('Flip', win);
               elseif find(firstPress) == prefs.keys.no
                   rt1 = rt;
                   key1 = prefs.keys.no;
                   Screen('FillRect', win, prefs.colors.back);
                   start = Screen('Flip', win);
               elseif find(firstPress) == prefs.keys.quit
                   sca;
                   error('User quit');
               end
               pressed = 0;
               KbQueueFlush(kb_pointer);
           end
       end
   end
   KbQueueFlush(kb_pointer);
   KbEventFlush(kb_pointer);
end