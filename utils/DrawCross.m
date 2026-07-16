function DrawCross(win, W, H, WL, HL)
%%
% W: w center
% H: h center
% WL: width len
% HL: height len
%%
    barWidth = 2; % in pixels
    barColor = [255, 255, 255]; % number from 0 (black) to 1 (white) 
    if nargin < 4
        barLength = 28; % in pixels
        Screen('FillRect', win, barColor,[ W-barLength/2 H-barWidth/2 W+barLength/2 H+barWidth/2]);
        Screen('FillRect', win, barColor ,[ W-barWidth/2 H-barLength/2 W+barWidth/2 H+barLength/2]);
    else
        % horizontal line
        Screen('FillRect', win, barColor,[ W-WL/2 H-barWidth/2 W+WL/2 H+barWidth/2]);
        % vertical line
        Screen('FillRect', win, barColor ,[ W-barWidth/2 H-HL/2 W+barWidth/2 H+HL/2]);
    end
end