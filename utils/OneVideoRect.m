function video_para = TwoVideoRect(win, video_w, video_h)
%% Position of the two video stimuli: video_width, video_height, rect1, rect2
    if nargin < 3, video_h = 540; end
    if nargin < 2, video_w = 540; end
    
    resize_video=[];
    default_resize_video=1.0;

    while (isempty(resize_video))
          if (isempty(resize_video))
%                 resize_video = input(sprintf('[OneVideoRect] Resize video by (default [%s]): \n', ...
%                     num2str(default_resize_video)));
%                 
%                 if (isempty(resize_video))
%                     resize_video = default_resize_video;
%                 end 
                resize_video = default_resize_video;
          end

          % Get the size of the rescaled video that suits the screen 
          video_width= resize_video * video_w;
          video_height = resize_video * video_h;

          if (video_width)> win.width
              warning('Video is too wide for the current sceen, change the <resize_video> to smaller number!!\n');
              resize_video=[];
              default_resize_video = default_resize_video - 0.05;
          end

          if video_height > win.height
             warning ('Video is too high for the current sceen, change the <resize_video> to smaller number!!\n');
             resize_video=[];
             default_resize_video = default_resize_video - 0.05;
          end
    end


    rect1 = [win.centerX-video_width/2, ...
             win.centerY-video_height/2, ...
             win.centerX+video_width/2,...
             win.centerY+video_height/2];
    
    video_para.video_height  = video_height;
    video_para.video_width   = video_width;
    video_para.rect          = rect1;
    video_para.resize        = resize_video;
    video_para.raw_height    = video_w;
    video_para.raw_width     = video_h;
    video_para.win           = win;
    
