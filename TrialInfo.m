function b = TrialInfo(prefs)
% _________________________________________________________________________
% Generate block information + trial information for each run.
% 
% HISTORY
% 02/24/22   wbi  wrote itconditinoStruct_curRun = load(curRunCondFile);
%
% _________________________________________________________________________
    run_num                = prefs.runNum;
    curRunCondFile         = prefs.dirs.curRunCondFile;
    conditinoStruct_curRun = load(curRunCondFile);
    conditinoStruct_curRun = conditinoStruct_curRun.conditionStruct;
    b                      = struct(); 
    b.condition            = conditinoStruct_curRun(1).condition;

    %% ===== [wb] Create orders ======================================
    if strcmp(conditinoStruct_curRun(1).condition, 'cloth_ctl')
        FIXATION_LEN        = 1.0;
        MOVIE_LEN           = 6.7;
        RESP_LEN            = 0;
        JITTERED_ISI        = [2, 3, 4, 5];
        PROBE_DIAM          = prefs.probe.clothDiam;
        PROBE_COLOR         = prefs.probe.clothColor;
        PROBE_START_T       = prefs.probe.clothStartT;
        PROBE_LAST_T        = prefs.probe.lastT;
    
        
    %% ==== [wb] Params ====================
    %WB% event-related design
    run_trial_num       = length(conditinoStruct_curRun);
    probe_num           = floor(run_trial_num * 0.5);
    center_probe_num    = floor(probe_num/2);
    noncenter_probe_num = probe_num - center_probe_num;
    stim_repeats        = run_trial_num/length(JITTERED_ISI);

    if stim_repeats == floor(stim_repeats)
        jittered_ISI = repmat(JITTERED_ISI, 1, run_trial_num/length(JITTERED_ISI));
        jittered_ISI = jittered_ISI(randperm(length(jittered_ISI)));
    else
        error('[run_trial_num]%f is not divisible by [JITTERED_ISI]%f', ...
            run_trial_num, length(JITTERED_ISI));
    end

    %% ==== [wb] Fill in the events ====================
    %WB% 0: no probe; 1: center_probe_num; 2: noncenter_probe_num
    non_probe_idx       = 0;
    center_probe_idx    = 1;
    noncenter_probe_idx = 2;
    corRes2_ls = [zeros(1, run_trial_num-probe_num), ...
                  zeros(1, center_probe_num)+center_probe_idx, ...
                  zeros(1, noncenter_probe_num)+noncenter_probe_idx];
    corRes2_ls = corRes2_ls(randperm(length(corRes2_ls)));

    b.trials = struct();
    for i = 1: run_trial_num
        b.trials(i).text        = {prefs.null_val, prefs.null_val, prefs.null_val, prefs.null_val};
        b.trials(i).conds       = {'txt', 'mov', 'isi', 'resp'};
        trials_len              = [FIXATION_LEN, MOVIE_LEN, jittered_ISI(i), RESP_LEN];
        b.trials(i).durs        = trials_len;
        b.trials(i).onsets      = [0 cumsum(trials_len)];
        b.trials(i).durs_sum    = b.trials(i).onsets(end);
        b.trials(i).stim        = conditinoStruct_curRun(i).stim;

        % corRes2
        if corRes2_ls(i) == non_probe_idx,
            b.trials(i).corRes2 = prefs.null_num; 
            b.trials(i).corRes1 = prefs.keys.no;
        elseif corRes2_ls(i) == center_probe_idx,
            b.trials(i).corRes2 = prefs.keys.yes;
            b.trials(i).corRes1 = prefs.keys.yes;
        elseif corRes2_ls(i) == noncenter_probe_idx,
            b.trials(i).corRes2 = prefs.keys.no;
            b.trials(i).corRes1 = prefs.keys.yes;
        else
            error('\n[Error] corRes2_ls(%d)=%d does not belong to [%d, %d, %d]\n', ...
                i, corRes2_ls(i), non_probe_idx, center_probe_idx, noncenter_probe_idx);
        end

        % corRes1
%             stiff_idx = 5;
%             yes_val = {'2.0'};
%             no_val = {'0.0078125'}; %WB% this stiff = no resp
%             tmp = strsplit(b.trials(i).stim, '/');
%             tmp = tmp(end);
%             tmp = strrep(tmp,'.mov',''); 
%             tmp = strsplit(tmp{1}, '_');
%             tmp_val = tmp(stiff_idx);
%             if any(strcmp(no_val, tmp_val)) && ~any(strcmp(yes_val, tmp_val))
%                 b.trials(i).corRes1 = prefs.keys.no;
%             elseif ~any(strcmp(no_val, tmp_val)) && any(strcmp(yes_val, tmp_val))
%                 b.trials(i).corRes1 = prefs.keys.yes;
%             else
%                 error('\n[Error]tmp_val[%s] does not equal to yes_val[%s] nor no_val[%s]\n', ...
%                     tmp_val{:}, yes_val{:}, no_val{:});
%             end

    end

    %% [wb] Generate b.probe
    b.probe                     = struct();
    b.probe.last_t              = PROBE_LAST_T;
    b.probe.non_probe_idx       = non_probe_idx;
    b.probe.center_probe_idx    = center_probe_idx;
    b.probe.noncenter_probe_idx = noncenter_probe_idx;
    b.probe.probe_ls            = corRes2_ls;
    b.probe.probe_diam          = PROBE_DIAM;
    b.probe.probe_color         = PROBE_COLOR;
    
    b.probe.probe_rect  = repmat(prefs.null_num, length(b.trials), 2);
    b.probe.probe_onset = repmat(prefs.null_num, length(b.trials), 2);
    for i = 1: length(b.trials)
        if (b.trials(i).corRes2 ~= prefs.null_num)
             b.probe.probe_rect(i, :) = [2, 2];  %WB% Dummy value, , will fill in in Initialize 
             onset_time = RandomVal(PROBE_START_T, MOVIE_LEN-PROBE_LAST_T);
             b.probe.probe_onset(i, :) = [onset_time, onset_time+PROBE_LAST_T];
        end
    end

    %% ==== [wb] Other info ============================
    b.run     = num2str(run_num);
    b.durs    = sum([b.trials(:).durs]);
    len_in_sec = b.durs+(prefs.begin_wait+prefs.end_wait)/prefs.tr_in_sec;
    fprintf('\nTotal length of Run %s = %f sec.\n', b.run, len_in_sec);
    fprintf('\nTotal length of Run %s = %f min.\n', b.run, len_in_sec/60.0);
end