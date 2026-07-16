function T = CreateDataTable(prefs, design)
  if nargin < 2
    switch prefs.expCond.runOrder{prefs.runNum}
        case {'cloth_ctl'}
            design = 'trial';
        case {'loc_tower'}
            design = 'block';
        otherwise
            error("Wrong run name: %s!", prefs.expCond.runOrder{prefs.runNum})
    end
  end

    %% [wb] Create output file
    if strcmp(design, 'trial')==1
        T_designed_onset       = [];
        T_designed_offset      = [];
        T_trial_idx            = [];
        T_event_name           = {};
        T_crt1                 = {};
        T_stim                 = {};
        onsets_sumcnt          = 0;

        for i = 1: length(prefs.b.trials)
            cur_onsets         = prefs.b.trials(i).onsets + onsets_sumcnt;
            cur_offsets        = cur_onsets(2:end);
            cur_onsets         = cur_onsets(1:end-1);
            cur_trialnum       = length(cur_onsets);
            tmp_stim           = {prefs.null_val, prefs.b.trials(i).stim, prefs.null_val};
            T_stim             = {T_stim{:}, tmp_stim{:}};
            tmp_crt1           = {prefs.b.trials(i).corRes1, prefs.null_num, prefs.null_num};
            T_crt1             = {T_crt1{:}, tmp_crt1{:}};
            T_event_name       = {T_event_name{:}, prefs.b.trials(i).conds{:}};
            T_trial_idx        = [T_trial_idx, repmat(i, 1, cur_trialnum)];
            T_designed_onset   = [T_designed_onset, cur_onsets];
            T_designed_offset  = [T_designed_offset, cur_offsets];
            onsets_sumcnt      = onsets_sumcnt + prefs.b.trials(i).onsets(end);
        end
        T = cell2table(repmat({string(prefs.b.run) nan nan nan nan nan ...
            nan nan nan nan nan nan nan}, ...
            length(T_designed_onset), 1), 'VariableNames', ...
            {'Run', 'Trial', 'Event_Name', 'BTN1', 'CRT1', 'RT1', ...
            'RealOnset', 'RealOffset', 'DesignOnset', 'DesignOffset', 'DesignDur', 'TR', 'Stim'});
        T.Trial            = T_trial_idx';
        T.Event_Name       = T_event_name';
        T.CRT1             = T_crt1';
        T.DesignOnset      = T_designed_onset';
        T.DesignOffset     = T_designed_offset';
        T.DesignDur        = T.DesignOffset-T.DesignOnset;
        T.Stim             = T_stim';
        
    elseif strcmp(design, 'block')==1
        T_designed_onset       = [];
        T_designed_offset      = [];
        T_block_idx            = [];
        T_block_cnt            = [];
        T_block_name           = {};
        T_trial_idx            = [];
        T_event_name           = {};
        T_crt1                 = {};
        T_stim                 = {};
        onsets_sumcnt          = 0;
        block_idx_counter      = 1;
        for i = 1: length(prefs.b.trials)
            cur_onsets         = prefs.b.trials(i).onsets + onsets_sumcnt;
            cur_offsets        = cur_onsets(2:end);
            cur_onsets         = cur_onsets(1:end-1);
            cur_trialnum       = length(cur_onsets);
            T_designed_onset   = [T_designed_onset, cur_onsets];
            T_designed_offset  = [T_designed_offset, cur_offsets];
            T_block_idx        = [T_block_idx, repmat(prefs.b.trials(i).blockIdx, 1, cur_trialnum)];
            T_block_cnt        = [T_block_cnt, repmat(block_idx_counter, 1, cur_trialnum)];
            cur_block_name     = repmat({prefs.b.trials(i).blockName}, 1, cur_trialnum);
            T_block_name       = {T_block_name{:}, cur_block_name{:}};
            if cur_trialnum > 1,
                tmp_trial_idx = repmat([1:cur_trialnum/2],2,1);
            elseif cur_trialnum == 1,
                tmp_trial_idx = [1];
            end
            T_trial_idx        = [T_trial_idx, tmp_trial_idx(:)'];
            T_event_name       = {T_event_name{:}, prefs.b.trials(i).conds{:}};
            T_stim             = {T_stim{:}, prefs.b.trials(i).stim{:}};        
            onsets_sumcnt      = onsets_sumcnt + prefs.b.trials(i).onsets(end);
            block_idx_counter  = block_idx_counter + 1;
        end

        T = cell2table(repmat({string(prefs.b.run) nan nan nan nan nan nan nan nan ...
            nan nan nan nan nan nan nan}, ...
            length(T_designed_onset), 1), 'VariableNames', ...
            {'Run', 'Block', 'Block_Name', 'Block_idx', 'Trial', 'Event_Name', 'BTN1', 'CRT1', 'RT1', ...
            'RealOnset', 'RealOffset', 'DesignOnset', 'DesignOffset', 'DesignDur', 'TR', 'Stim'});

        T.Block            = T_block_cnt';
        T.Block_Name       = T_block_name';
        T.Block_idx        = T_block_idx';
        T.Trial            = T_trial_idx';
        T.Event_Name       = T_event_name';
        T.DesignOnset      = T_designed_onset';
        T.DesignOffset     = T_designed_offset';
        T.DesignDur        = T.DesignOffset-T.DesignOnset;
        T.Stim             = T_stim';
    else
        error('Invalid design=%s', design)
    end  
end