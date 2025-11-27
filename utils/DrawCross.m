function DrawCross(win, W, H)
    barLength = 28; % in pixels
    barWidth = 2; % in pixels
    barColor = [255, 255, 255]; % number from 0 (black) to 1 (white) 
    Screen('FillRect', win, barColor,[ W-barLength/2 H-barWidth/2 W+barLength/2 H+barWidth/2]);
    Screen('FillRect', win, barColor ,[ W-barWidth/2 H-barLength/2 W+barWidth/2 H+barLength/2]);
end