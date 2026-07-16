function b = TrialInfo(prefs)
% _________________________________________________________________________
    run_num                = prefs.runNum;
    curRunCondFile         = prefs.dirs.curRunCondFile;
    conditinoStruct_curRun = load(curRunCondFile);
    conditinoStruct_curRun = conditinoStruct_curRun.conditionStruct;
    b                      = struct(); 
    b.condition            = conditinoStruct_curRun(1).condition;

    %% ===== [wb] Create orders ======================================
    if strcmp(conditinoStruct_curRun(1).condition, 'cloth_ctl')
        FIXATION_LEN        = 1;
        FIXATION_LONG       = 150;
        FIXATION_SHORT      = 50;
        MOVIE_LEN           = 6.7;
        RESP_LEN            = 0;
        JITTERED_ISI        = [2, 3, 4, 5];
    end
        
    %% ==== [wb] Params ====================
    %WB% event-related design
    run_trial_num       = length(conditinoStruct_curRun);
    h_longer_fix_num    = floor(run_trial_num/2);
    v_longer_fix_num    = run_trial_num - h_longer_fix_num;
    stim_repeats        = run_trial_num/length(JITTERED_ISI);

    if stim_repeats == floor(stim_repeats)
        jittered_ISI = repmat(JITTERED_ISI, 1, run_trial_num/length(JITTERED_ISI));
        jittered_ISI = jittered_ISI(randperm(length(jittered_ISI)));
    else
        error('[run_trial_num]%f is not divisible by [JITTERED_ISI]%f', ...
            run_trial_num, length(JITTERED_ISI));
    end

    %% ==== [wb] Fill in the events ====================
    %WB%: 0: horizontal is longer; 1: vertical is longer
    h_longer_fix_idx = 0;
    v_longer_fix_idx = 1;
    corRes1_ls = [zeros(1, h_longer_fix_num), ...
                  zeros(1, v_longer_fix_num)+v_longer_fix_idx];
    corRes1_ls = corRes1_ls(randperm(length(corRes1_ls)));

    b.trials = struct();
    for i = 1: run_trial_num
        b.trials(i).text        = {prefs.null_val, prefs.null_val, prefs.null_val};
        b.trials(i).conds       = {'fix', 'mov', 'isi'};
        trials_len              = [FIXATION_LEN, MOVIE_LEN, jittered_ISI(i)];
        b.trials(i).durs        = trials_len;
        b.trials(i).onsets      = [0 cumsum(trials_len)];
        b.trials(i).durs_sum    = b.trials(i).onsets(end);
        b.trials(i).stim        = conditinoStruct_curRun(i).stim;

        % corRes2
        if corRes1_ls(i) == h_longer_fix_idx
            b.trials(i).corRes1 = prefs.keys.yes;
        elseif corRes1_ls(i) == v_longer_fix_idx
            b.trials(i).corRes1 = prefs.keys.no;
        else
            error('\n[Error] corRes1_ls(%d)=%d does not belong to [%d, %d]\n', ...
                i, corRes1_ls(i), h_longer_fix_idx, v_longer_fix_idx);
        end

    end

    %% [wb] Generate b.probe
    b.fix                       = struct();
    b.fix.h_longer_fix_idx      = h_longer_fix_idx;
    b.fix.v_longer_fix_idx      = v_longer_fix_idx;
    b.fix.fix_ls                = corRes1_ls;
    
    b.fix.fix_rect  = repmat(prefs.null_num, length(b.trials), 2);
    for i = 1: length(b.trials)
        if (b.trials(i).corRes1 ~= prefs.null_num)
            if (b.fix.fix_ls(i) == h_longer_fix_idx)
                b.fix.fix_rect(i, :) = [FIXATION_LONG, FIXATION_SHORT];
            elseif (b.fix.fix_ls(i) == v_longer_fix_idx)
                b.fix.fix_rect(i, :) = [FIXATION_SHORT, FIXATION_LONG];
            end
                
        end
    end

    %% ==== [wb] Other info ============================
    b.run     = num2str(run_num);
    b.durs    = sum([b.trials(:).durs]);
    len_in_sec = b.durs+(prefs.begin_wait+prefs.end_wait)/prefs.tr_in_sec;
    fprintf('\nTotal length of Run %s = %f sec.\n', b.run, len_in_sec);
    fprintf('\nTotal length of Run %s = %f min.\n', b.run, len_in_sec/60.0);
end