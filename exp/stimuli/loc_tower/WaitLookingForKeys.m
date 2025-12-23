%--------------------------------------------------------------------------
function [key1, key2, rt1, rt2, tr_counter] = WaitLookingForKeys(prefs, win, for_resp, kb_pointer, tr_counter, start, timeOut)
%    if nargin < 6, start = GetSecs(); end
%    if nargin < 7, timeOut = -1; end
    
   % Initialize variables
   key1    = -1; 
   key2    = -1;
   rt1     = -1; 
   rt2     = -1;
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
       first_res_registered = 0;
       second_res_registered = 0;
       while (GetSecs < timeOut)
           [pressed, firstPress] = KbQueueCheck(kb_pointer);
           if pressed
               rt = GetSecs - start;
               if find(firstPress) == prefs.keys.trigger
                   tr_counter = tr_counter + 1;
               elseif find(firstPress) == prefs.keys.yes
                   if first_res_registered && (~second_res_registered)
                       rt2 = rt;
                       key2 = prefs.keys.yes;
                       Screen('FillRect', win, prefs.colors.back);
                       Screen('Flip', win);
                       second_res_registered = 1;
                   else
                       rt1 = rt;
                       key1 = prefs.keys.yes;
                       first_res_registered = 1;
                       DrawCenteredText(win, 'Was it in the center?', prefs.colors.fore, 0, 0);
                       start = Screen('Flip', win);
                   end
               elseif find(firstPress) == prefs.keys.no
                   if first_res_registered && (~second_res_registered)
                       rt2 = rt;
                       key2 = prefs.keys.no;
                       Screen('FillRect', win, prefs.colors.back);
                       Screen('Flip', win);
                       second_res_registered = 1;
                   else
                       rt1 = rt;
                       key1 = prefs.keys.no;
                       first_res_registered = 1;
                       Screen('FillRect', win, prefs.colors.back);
                       start = Screen('Flip', win);
                   end
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