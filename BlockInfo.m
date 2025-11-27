function b = BlockInfo(prefs)
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
    if strcmp(conditinoStruct_curRun(1).condition, 'loc_dots')
        prefs.colors.back = prefs.colors.gray;
        prefs.colors.fore = prefs.colors.black;
        
        trials_per_MainBlock  = 10; 
        lengthMainBlocks_breakdown = [2, 0.2];  % [vid, isi]
        lengthMainBlocks = sum(lengthMainBlocks_breakdown) * trials_per_MainBlock;  % in sec
        % [wb] How many main blocks of each condition
        condition(1) = 3;
        condition(2) = 3;
        condition(3) = 3;
        condition(4) = 4;
        numBlocksTotal = sum(condition);
        
        b.condNames{1}  = 'coh'; 
        b.condNames{2}  = 'mat'; 
        b.condNames{3}  = 'scram';
        b.condNames{4}  = 'blank';
        
        blankBlocksIdx   = [1, 5, 9, 13];
        
    elseif strcmp(conditinoStruct_curRun(1).condition, 'cloth_drape')
        trials_per_MainBlock  = 7; 
        lengthMainBlocks_breakdown = [0.5, 2, 0.7];  % [vid, isi]
        lengthMainBlocks = sum(lengthMainBlocks_breakdown) * trials_per_MainBlock;  % in sec
        % [wb] How many main blocks of each condition
        condition(1) = 4;
        condition(2) = 4;
        condition(3) = 5;
        numBlocksTotal = sum(condition);
        
        b.condNames{1}  = 'nocloth'; 
        b.condNames{2}  = 'cloth';
        b.condNames{3}  = 'blank';
        
        blankBlocksIdx   = [1, 4, 7, 10, 13];
    end
        
    %% ==== [wb] Create blocks seq ====================
    b.conds = zeros(1, numBlocksTotal)+length(condition);
    nonBlankBlock = [];
    for i = 1:length(condition)-1
      nonBlankBlock(end+1:end+condition(i)) = repmat(i, 1, condition(i));
    end
    nonBlankBlock = Shuffle(nonBlankBlock);

    restBlocks = b.conds;
    restBlocks(blankBlocksIdx) = 0;
    non_blankBlocksIdx = find(restBlocks);
    b.conds(non_blankBlocksIdx) = Shuffle(nonBlankBlock);

    % [wb] Creation durations and onsets of these blocks
    b.durs = zeros(1, numBlocksTotal) + lengthMainBlocks;
    b.onsets = [0 cumsum(b.durs)];

    %% ==== [wb] Fill in the events ====================
    b.trials = struct();
    stim_counter = [1, 1, 1];
    for i=1:length(b.conds)
        cur_cond = b.conds(i);
        b.trials(i).blockName   = b.condNames{cur_cond};
        b.trials(i).blockIdx    = cur_cond;
        switch cur_cond
            case {1, 2, 3} 
                b.trials(i).conds       = repmat({'mov', 'txt'}, 1, trials_per_MainBlock); %'txt' is fixation
                cur_trial_dur           = repmat(lengthMainBlocks_breakdown, 1, trials_per_MainBlock);
                b.trials(i).durs        = cur_trial_dur;
                b.trials(i).onsets      = [0 cumsum(cur_trial_dur)];
                cur_stim_start          = trials_per_MainBlock*2*(stim_counter(cur_cond)-1)+1;
                cur_stim_end            = trials_per_MainBlock*2*stim_counter(cur_cond);
                b.trials(i).stim        = {conditinoStruct_curRun.stim{cur_cond}{cur_stim_start:cur_stim_end}};
                b.trials(i).corRes1     = repmat(prefs.null_num, 1, trials_per_MainBlock);
                stim_counter(cur_cond)  = stim_counter(cur_cond) + 1;
            case 4
                b.trials(i).conds       = {'txt'}; %'txt' is fixation
                cur_trial_dur           = lengthMainBlocks;
                b.trials(i).durs        = cur_trial_dur;
                b.trials(i).onsets      = [0 cumsum(cur_trial_dur)];
                b.trials(i).stim        = {prefs.null_val};
                b.trials(i).corRes1     = prefs.null_num;
            otherwise
                error ('Wrong block num: %s!', num2str(b.conds(i)));
        end
    end

    %% ==== [wb] Other info ============================
    b.run     = num2str(run_num);
    b.durs    = sum([b.trials(:).durs]);
    len_in_sec = b.durs+(prefs.begin_wait+prefs.end_wait)/prefs.tr_in_sec;
    fprintf('\nTotal length of Run %s = %f sec.\n', b.run, len_in_sec);
    fprintf('\nTotal length of Run %s = %f min.\n', b.run, len_in_sec/60.0);
end