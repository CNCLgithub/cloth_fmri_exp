function win = OpenScreen(prefs)
    Screen('Preference', 'SkipSyncTests', 2);
    win = struct();
    win.screenNumber = max(Screen('Screens'));
    win.res = prefs.res;
    [win.ptr, win.rect] = Screen('OpenWindow', win.screenNumber, ...
                                 prefs.colors.back, win.res);
    HideCursor;
    [win.centerX, win.centerY] = RectCenter(win.rect);
    [win.height, win.width]    = Screen('WindowSize', win.ptr);

    %[wb] slack time
    win.slack = Screen('GetFlipInterval', win.ptr)/2;   % [TODO] need check this, devide by 4?
    
    %[wb] priority
    win.priorityLevel = MaxPriority(win.ptr);
    Priority(win.priorityLevel);

	Screen('FillRect', win.ptr, prefs.colors.back);
	Screen('Flip', win.ptr);
end