function DispInstruction(win, ins_file, prefs)
    fd = fopen(ins_file);
    
    Intro = '';
    tl = fgets(fd);
    lcount = 0;
    while lcount < 48
        Intro = [Intro tl]; 
        tl = fgets(fd);
        lcount = lcount + 1;
    end

    fclose(fd);
    Intro = [Intro char(10)];
    % Get rid of '% ' symbols at the start of each line:
    Intro = strrep(Intro, '% ', '');
    Intro = strrep(Intro, '%', '');
  
    Screen ('TextSize', win.ptr, prefs.instructionTextSize);
    wRect = win.rect;
    % Define test start postion (x,y)=(0.0078*wRect(3),0.0250*wRect(4))
    DrawFormattedText(win.ptr, Intro, 0.0078*wRect(3), 0.0450*wRect(4));
    Screen('Flip', win.ptr);

    % Press to move on
%     WaitLookingForKeys_Kbcheck(prefs.keys.next, prefs.keys.quit);
%     fprintf('Instruction looking time: %.4f\n', rt);
end