%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DrawCenteredText(win, text, color, xoff, yoff)
%
% Draw a string of text, centered in window win, offset by xoff/yoff:
%
    if nargin < 3
        color = [];
    end;
    if nargin < 4
        xoff = 0;
    end;
    if nargin < 5
        yoff = -30;
    end;

    bbox = Screen('TextBounds', win, text);
    bbox = CenterRect(bbox, Screen('Rect', win));
    x=bbox(RectLeft);
    y=bbox(RectTop);
    Screen('DrawText', win, text, x+xoff, y+yoff, color);