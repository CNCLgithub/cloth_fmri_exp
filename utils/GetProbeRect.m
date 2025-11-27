function probe_rect = GetProbeRect(prefs, win, vid_param, frm_ratio)
    if nargin < 3, frm_ratio = 0.5; end  %WB% Larger is wider frame
    
    %% [wb] Get probe rect
    %WB% Get probe showing areas
    probe_radius = prefs.b.probe.probe_diam/2;
    frm_h = (win.centerY-vid_param.rect(2))*frm_ratio;
    frm_w = (win.centerX-vid_param.rect(1))*frm_ratio;
    
    upper_frm.x = [vid_param.rect(1)+probe_radius, vid_param.rect(3)-probe_radius];
    upper_frm.y = [vid_param.rect(2)+probe_radius, vid_param.rect(2)+frm_h-probe_radius];
    lower_frm.x = [vid_param.rect(1)+probe_radius, vid_param.rect(3)-probe_radius];
    lower_frm.y = [vid_param.rect(4)-frm_h+probe_radius, vid_param.rect(4)-probe_radius];
    left_frm.x  = [vid_param.rect(1)+probe_radius, vid_param.rect(1)+frm_w-probe_radius];
    left_frm.y  = [vid_param.rect(2)+probe_radius, vid_param.rect(4)-probe_radius];
    right_frm.x = [vid_param.rect(3)-frm_w+probe_radius, vid_param.rect(3)-probe_radius];
    right_frm.y = [vid_param.rect(2)+probe_radius, vid_param.rect(4)-probe_radius];
    
    probe_showing_frame = [upper_frm, lower_frm, left_frm, right_frm];
    len_probe_frame = length(probe_showing_frame);
    
    %WB% Get probe rect
    noncenter_probe_num = sum(prefs.b.probe.probe_ls == prefs.b.probe.noncenter_probe_idx);
    noncenter_probe_frame = repmat(probe_showing_frame, 1, ceil(noncenter_probe_num/len_probe_frame));
    noncenter_probe_frame = noncenter_probe_frame(randperm(length(noncenter_probe_frame)));
    noncenter_probe_counter = 1;
    probe_rect = repmat(prefs.null_num, length(prefs.b.trials), 2);
    for i = 1: length(prefs.b.probe.probe_ls)
        if prefs.b.probe.probe_ls(i) == prefs.b.probe.center_probe_idx
            probe_rect(i,:) = [win.centerX, win.centerY];
        elseif prefs.b.probe.probe_ls(i) == prefs.b.probe.noncenter_probe_idx
            tmp_x = noncenter_probe_frame(noncenter_probe_counter).x;
            tmp_y = noncenter_probe_frame(noncenter_probe_counter).y;
            probe_rect(i,:) = [RandomVal(tmp_x(1), tmp_x(2)), RandomVal(tmp_y(1), tmp_y(2))];
            noncenter_probe_counter = noncenter_probe_counter + 1;
        end
    end
end