function vid_param = GetVidRect(prefs, win, T)
    tmp_vid = T.Stim;
    tmp_vid = tmp_vid(~any(cellfun('isempty',tmp_vid),2),:);
    tmp_vid = char(tmp_vid(1));
    [tmp_vid_ptr, dur, fps, imgw, imgh] = Screen('OpenMovie', win.ptr, tmp_vid);
    
    vid_param_file = fullfile(prefs.dirs.rootDir, ['OneVidParam_', ...
        num2str(imgw), '_', num2str(imgh), '_', ...
        num2str(win.rect(1)), '_', num2str(win.rect(2)), '_', ...
        num2str(win.rect(3)), '_', num2str(win.rect(4)), '.mat']);
    try
        vid_param = load(vid_param_file);
        vid_param = vid_param.vid_param;
    catch
        vid_param = OneVideoRect(win, imgw, imgh);
        vid_param.fps = fps;
        vid_param.dur = dur;
        vid_param.name = tmp_vid;
        save(vid_param_file, 'vid_param');
    end

    Screen('CloseMovie', tmp_vid_ptr);
    Screen('Flip', win.ptr);
end
