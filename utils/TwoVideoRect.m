function video_para = TwoVideoRect(win, video_w, video_h, distance_mid)
%% Position of the two video stimuli: video_width, video_height, rect1, rect2
    if nargin < 4, distance_mid = 50; end  % [wb] smaller = closer
    if nargin < 3, video_h = 540; end
    if nargin < 2, video_w = 540; end
    
    resize_video=[];
    default_resize_video=0.5;

    while (isempty(resize_video))
          if (isempty(resize_video))
                resize_video = input(sprintf('[TwoVideoRect] Resize video by (default [%s]): \n', ...
                    num2str(default_resize_video)));
                
                if (isempty(resize_video))
                    resize_video = default_resize_video;
                end 
          end

          % Get the size of the rescaled video that suits the screen 
          video_width= resize_video * video_w;
          video_height = resize_video * video_h;
          
          % Set up interval between the two video stimuli: intervalBetweenVideos
          if (win.width-20-2*video_width)<=0
              intervalBetweenVideos = distance_mid;
          elseif (win.width-20-2*video_width)>0
              intervalBetweenVideos = min(distance_mid,(win.width-20-2*video_width));
          end

          if (video_width*2+intervalBetweenVideos)> win.width
              warning('Video is too wide for the current sceen, change the <resize_video> to smaller number!!\n');
              resize_video=[];
          end

          if video_height > win.height
             warning ('Video is too high for the current sceen, change the <resize_video> to smaller number!!\n');
             resize_video=[];
          end
    end


    rect1 = [win.centerX-intervalBetweenVideos/2-video_width, ...
             win.centerY-video_height/2, ...
             win.centerX-intervalBetweenVideos/2,...
             win.centerY+video_height/2];
    rect2 = [win.centerX+intervalBetweenVideos/2, ...
             win.centerY-video_height/2, ...
             win.centerX+intervalBetweenVideos/2+video_width, ...
             win.centerY+video_height/2];
    
    video_para.video_height  = video_height;
    video_para.video_width   = video_width;
    video_para.rect_l        = rect1;
    video_para.rect_r        = rect2;
    video_para.distance_mid  = distance_mid;
    video_para.resize        = resize_video;
    video_para.raw_height    = video_w;
    video_para.raw_width     = video_h;
    video_para.win           = win;
    
