sca;
clear all; 
close all; 
clc;
RANDSeed = ClockRandSeed;

%% ======================= Load  ==================================%
try
  f = ['Setup_',computer,'.mat'];
  prefs = load(f);
  warning('Using pre-generated [%s]\n', f); 
  prefs = prefs.p;
catch
  prefs = Setup(); 
end
%% ======================= Paths ==================================%
defaultSbj = 'wbi';
theSbj = input(sprintf('Enter subject name [%s]: ', defaultSbj), 's');
if (isempty(theSbj)), theSbj = defaultSbj; end

sbjDir = fullfile(prefs.dirs.dataDir, theSbj);
if (~exist(sbjDir, 'dir')), mkdir(sbjDir); end

runDir = fullfile(sbjDir, prefs.dirs.runOrderDirName);
if (~exist(runDir, 'dir')), mkdir(runDir); end
FileExistError(fullfile(runDir, '*.mat'));

%% =============== cloth_ctl: event ==================================%
for cloth_ctl = 1
    condition = 'cloth_ctl';
    run_index = find(strcmp(prefs.expCond.runOrder, condition));
    if isempty(run_index), error('Invalid condition=%s', condition); end
    run_num = length(run_index);
    stim_num = 8;
    stim_repeat = 10;
    stim_trials_each_run = 20;
    
    fprintf('\n-----------------------------------\n');
    fprintf('condition         : %s\n', condition);
    fprintf('num of runs       : %d\n', run_num);
    fprintf('stim num          : %d\n', stim_num);
    fprintf('each stim repeats : %d\n', stim_repeat);
    fprintf('stim in each run  : %d\n', stim_trials_each_run);
    fprintf('-----------------------------------\n');

    %---------------- stim -------------------------------
    cur_scene = {'wind', 'drape', 'rotate', 'ball'};
    stiff_mass = {'0.5'}; stiff_l_stiff = {'0.0078125'}; sitff_h_stiff = {'2.0'};

    stiff_l_ls = {};
    for i = 1:length(cur_scene)
        for j = 1: length(stiff_mass)
            for k = 1: length(stiff_l_stiff)
                stiff_l_ls{i} = [cur_scene{i}, '_mass_', stiff_mass{j}, '_bs_', stiff_l_stiff{k}, '.mov'];
            end
        end
    end
    
    stiff_h_ls = {};
    for i = 1:length(cur_scene)
        for j = 1: length(stiff_mass)
            for k = 1: length(sitff_h_stiff)
                stiff_h_ls{i} = [cur_scene{i}, '_mass_', stiff_mass{j}, '_bs_', sitff_h_stiff{k}, '.mov'];
            end
        end
    end
    cur_stim_ls = [stiff_l_ls, stiff_h_ls];
    cur_stim_ls = repmat(cur_stim_ls, 1, stim_repeat);

    cur_stim_ls_rand = [];
    nTrials = length(cur_stim_ls);
    randomorder = randperm(nTrials);  
    for kk = 1:nTrials
        cur_stim_ls_rand{kk} = cur_stim_ls{randomorder(kk)};
    end
    %---------------- save for each run -------------------
    cur_run = 1;
    i_cur_run = 1;
    conditionStruct = struct();

    for i = 1: length(cur_stim_ls_rand)
        if i_cur_run > stim_trials_each_run
            newTestFileName = fullfile(runDir, ['run_',num2str(run_index(cur_run)), '.mat']);
            %FileExistError(newTestFileName);
            save(newTestFileName, 'conditionStruct');
            fprintf('--Saving [%s]: %s\n',theSbj, newTestFileName);
            conditionStruct = struct();
            i_cur_run = 1;
            cur_run = cur_run +1;
        end
        conditionStruct(i_cur_run).run       = run_index(cur_run);
        conditionStruct(i_cur_run).condition = condition;
        conditionStruct(i_cur_run).stim      = fullfile(prefs.dirs.stimDir, condition, cur_stim_ls_rand{i});
        i_cur_run = i_cur_run + 1;
    end

    newTestFileName = fullfile(runDir, ['run_',num2str(run_index(cur_run)), '.mat']);
    %FileExistError(newTestFileName);
    save(newTestFileName, 'conditionStruct');
    fprintf('--Saving [%s]: %s\n',theSbj, newTestFileName);

    % ---- saving for data analsysis --- %
    clothDataFileName = fullfile(runDir, [condition, '_data.mat']);
    save(clothDataFileName, 'cur_stim_ls_rand', 'randomorder', 'cur_stim_ls');
    fprintf('--Saving [%s]: %s\n',theSbj, clothDataFileName);
end

%% =============== liquid_ctl: event
for liquid_ctl = 1
    condition = 'liquid_ctl';
    run_index = find(strcmp(prefs.expCond.runOrder, condition));
    if isempty(run_index), error('Invalid condition=%s', condition); end
    run_num = length(run_index);
    stim_num = 10;
    stim_repeat = 10;
    stim_trials_each_run = 20;

    fprintf('\n-----------------------------------\n');
    fprintf('condition         : %s\n', condition);
    fprintf('num of runs       : %d\n', run_num);
    fprintf('stim num          : %d\n', stim_num);
    fprintf('each stim repeats : %d\n', stim_repeat);
    fprintf('stim in each run  : %d\n', stim_trials_each_run);
    fprintf('-----------------------------------\n');
    
    %---------------- stim  -------------------------------
    cur_scene = {'box', 'boxwithahole', 'motor', 'obstacle', 'wall'};
    liquid_l = {'1'}; liquid_h = {'1016'};

    liquid_l_ls = {}; 
    for i = 1:length(cur_scene)
        for j = 1:length(liquid_l)
                liquid_l_ls{i} = [cur_scene{i}, liquid_l{j}, '.mov'];
        end
    end
    
    liquid_h_ls = {};
    for i = 1:length(cur_scene)
        for j = 1:length(liquid_h)
            liquid_h_ls{i} = [cur_scene{i}, liquid_h{j}, '.mov'];
        end
    end
 
    cur_stim_ls = [liquid_l_ls, liquid_h_ls];
    cur_stim_ls = repmat(cur_stim_ls, 1, stim_repeat);

    cur_stim_ls_rand = [];
    nTrials = length(cur_stim_ls);
    randomorder=randperm(nTrials);  
    for kk = 1:nTrials
        cur_stim_ls_rand{kk} = cur_stim_ls{randomorder(kk)};
    end
    
    %---------------- save for each run -------------------
    cur_run = 1;
    i_cur_run = 1;
    conditionStruct = struct();

    for i = 1: length(cur_stim_ls_rand)
        if i_cur_run > stim_trials_each_run
            newTestFileName = fullfile(runDir, ['run_',num2str(run_index(cur_run)), '.mat']);
            %FileExistError(newTestFileName);
            save(newTestFileName, 'conditionStruct');
            fprintf('--Saving [%s]: %s\n',theSbj, newTestFileName);
            conditionStruct = struct();
            i_cur_run = 1;
            cur_run = cur_run +1;
        end
        conditionStruct(i_cur_run).run = run_index(cur_run);
        conditionStruct(i_cur_run).condition = condition;
        conditionStruct(i_cur_run).stim = fullfile(prefs.dirs.stimDir, condition, cur_stim_ls_rand{i});
        i_cur_run = i_cur_run + 1;
    end

    newTestFileName = fullfile(runDir, ['run_',num2str(run_index(cur_run)), '.mat']);
    %FileExistError(newTestFileName);
    save(newTestFileName, 'conditionStruct');
    fprintf('--Saving [%s]: %s\n',theSbj, newTestFileName);

    % ---- saving for data analsysis --- %
    clothDataFileName = fullfile(runDir, [condition, '_data.mat']);
    save(clothDataFileName, 'cur_stim_ls_rand', 'randomorder', 'cur_stim_ls');
    fprintf('--Saving [%s]: %s\n',theSbj, clothDataFileName);
end

%% =============== loc_dots: block
for loc_dots= 1
    condition = 'loc_dots';
    run_index = find(strcmp(prefs.expCond.runOrder, condition));
    if isempty(run_index), error('Invalid condition=%s', condition); end
    run_num = length(run_index);
    block_name = {'coh', 'mat', 'scram'};
    stim_in_each_block = 10;
    block_repeat_each_run = 3;
    
    fprintf('\n-----------------------------------\n');
    fprintf('condition             : %s\n', condition);
    fprintf('num of runs           : %d\n', run_num);
    fprintf('stim_in_each_block    : %d\n', stim_in_each_block);
    fprintf('block_repeat_each_run : %d\n', block_repeat_each_run);
    fprintf('-----------------------------------\n');
    
    %---------------- stim -------------------------------
    % [TODO] -- hard coding 
    cur_scene = {'cloth', 'cloth_rot', 'pokeWobble', 'pokeWobble_rot',...
    'ripples', 'stretchBounce', 'stretchDough_rot', 'stretchHighWobble'...
    'stretchWobble', 'waves'};
    
    cur_coh_ls = {};
    cur_mat_ls = {};
    cur_scram_ls = {};
    nTrials = stim_in_each_block;

    stim_counter = 1;
    for i = 1: block_repeat_each_run
        for j = 1:length(cur_scene)
            cur_coh_ls{stim_counter} = fullfile(prefs.dirs.stimDir, condition, [cur_scene{j}, '_coh.mp4']);
            cur_mat_ls{stim_counter} = fullfile(prefs.dirs.stimDir, condition, [cur_scene{j}, '_mat.mp4']);
            cur_scram_ls{stim_counter} = fullfile(prefs.dirs.stimDir, condition, [cur_scene{j}, '_scram.mp4']);
            stim_counter = stim_counter + 1;
        end
    end

    %---------------- save for each run -------------------
    for cur_run = 1: run_num
        conditionStruct = struct();

        % Block randomization
        randomorder_coh = [];
        randomorder_mat = [];
        randomorder_scram = [];
        for i = 1: block_repeat_each_run
            randomorder_coh = [randomorder_coh, randperm(nTrials)+nTrials*(i-1)];
            randomorder_mat = [randomorder_coh, randperm(nTrials)+nTrials*(i-1)];
            randomorder_scram = [randomorder_coh, randperm(nTrials)+nTrials*(i-1)];
        end

        cur_coh_ls_rand = {};
        cur_mat_ls_rand = {};
        cur_scram_ls_rand = {};
        kk_counter = 1;
        for kk = 1:2:length(randomorder_coh)*2
            cur_coh_ls_rand{kk}   = cur_coh_ls{randomorder_coh(kk_counter)};
            cur_mat_ls_rand{kk}   = cur_mat_ls{randomorder_mat(kk_counter)};
            cur_scram_ls_rand{kk} = cur_scram_ls{randomorder_scram(kk_counter)};
            cur_coh_ls_rand{kk+1} = '';
            cur_mat_ls_rand{kk+1} = '';
            cur_scram_ls_rand{kk+1} = '';
            kk_counter = kk_counter +1;
        end
        
        conditionStruct.run = run_index(cur_run);
        conditionStruct.condition = condition;
        conditionStruct.block_name = block_name;
        conditionStruct.stim = {cur_coh_ls_rand, cur_mat_ls_rand, cur_scram_ls_rand};

        newTestFileName = fullfile(runDir, ['run_',num2str(run_index(cur_run)), '.mat']);
        % FileExistError(newTestFileName);
        save(newTestFileName, 'conditionStruct');
        fprintf('--Saving [%s]: %s\n',theSbj, newTestFileName);

        % ---- saving for data analsysis --- %
        DataFileName = fullfile(runDir, [condition, '_', num2str(run_index(cur_run)), '_data.mat']);
        save(DataFileName, 'cur_coh_ls_rand', 'cur_mat_ls_rand', ...
            'cur_scram_ls_rand', 'randomorder_coh','randomorder_mat', ...
            'randomorder_scram', 'cur_coh_ls');
        fprintf('--Saving [%s]: %s\n',theSbj, DataFileName);
    end
end

%% ====================== cloth_drape: block =================================%
for cloth_drape = 1
    condition             = 'cloth_drape';
    run_index             = find(strcmp(prefs.expCond.runOrder, condition));
    run_num               = length(run_index);
    block_name            = {'nocloth', 'cloth', 'blank'};
    stim_in_each_block    = 9;
    block_repeat_each_run = 4;
    
    fprintf('\n-----------------------------------\n');
    fprintf('condition             : %s\n', condition);
    fprintf('num of runs           : %d\n', run_num);
    fprintf('stim_in_each_block    : %d\n', stim_in_each_block);
    fprintf('block_repeat_each_run : %d\n', block_repeat_each_run);
    fprintf('-----------------------------------\n');
    
    cur_scene = {'airplane', 'car', 'chair'};
    
    cloth_ls = {};
    non_cloth_ls = {};
    stim_counter = 1;
    for i = 1:length(cur_scene)
        for j = 1:4
            cloth_ls{stim_counter} = fullfile(prefs.dirs.stimDir, condition, [cur_scene{i}, '_cloth_', num2str(j), '.png']);
            non_cloth_ls{stim_counter} = fullfile(prefs.dirs.stimDir, condition, [cur_scene{i}, '_nocloth_', num2str(j), '.png']);
            stim_counter = stim_counter + 1;
        end
    end
    
%     for cur_run = 1: run_num
%         conditionStruct = struct();
% 
%         % Block randomization
%         randomorder_coh = [];
%         randomorder_mat = [];
%         randomorder_scram = [];
%         for i = 1: block_repeat_each_run
%             randomorder_coh = [randomorder_coh, randperm(nTrials)+nTrials*(i-1)];
%             randomorder_mat = [randomorder_coh, randperm(nTrials)+nTrials*(i-1)];
%             randomorder_scram = [randomorder_coh, randperm(nTrials)+nTrials*(i-1)];
%         end
% 
%         cur_coh_ls_rand = {};
%         cur_mat_ls_rand = {};
%         cur_scram_ls_rand = {};
%         kk_counter = 1;
%         for kk = 1:2:length(randomorder_coh)*2
%             cur_coh_ls_rand{kk}   = cur_coh_ls{randomorder_coh(kk_counter)};
%             cur_mat_ls_rand{kk}   = cur_mat_ls{randomorder_mat(kk_counter)};
%             cur_scram_ls_rand{kk} = cur_scram_ls{randomorder_scram(kk_counter)};
%             cur_coh_ls_rand{kk+1} = '';
%             cur_mat_ls_rand{kk+1} = '';
%             cur_scram_ls_rand{kk+1} = '';
%             kk_counter = kk_counter +1;
%         end
%         
%         conditionStruct.run = run_index(cur_run);
%         conditionStruct.condition = condition;
%         conditionStruct.block_name = block_name;
%         conditionStruct.stim = {cur_coh_ls_rand, cur_mat_ls_rand, cur_scram_ls_rand};
% 
%         newTestFileName = fullfile(runDir, ['run_',num2str(run_index(cur_run)), '.mat']);
%         % FileExistError(newTestFileName);
%         save(newTestFileName, 'conditionStruct');
%         fprintf('--Saving [%s]: %s\n',theSbj, newTestFileName);
% 
%         % ---- saving for data analsysis --- %
%         DataFileName = fullfile(runDir, [condition, '_', num2str(run_index(cur_run)), '_data.mat']);
%         save(DataFileName, 'cur_coh_ls_rand', 'cur_mat_ls_rand', ...
%             'cur_scram_ls_rand', 'randomorder_coh','randomorder_mat', ...
%             'randomorder_scram', 'cur_coh_ls');
%         fprintf('--Saving [%s]: %s\n',theSbj, DataFileName);
%     end
end
