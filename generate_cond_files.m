sca;
clear all; 
close all; 
clc;
% addpath './utils'
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
                stiff_l_ls{i} = [cur_scene{i}, '_mass_', stiff_mass{j}, '_bs_', stiff_l_stiff{k}, '.mp4'];
            end
        end
    end
    
    stiff_h_ls = {};
    for i = 1:length(cur_scene)
        for j = 1: length(stiff_mass)
            for k = 1: length(sitff_h_stiff)
                stiff_h_ls{i} = [cur_scene{i}, '_mass_', stiff_mass{j}, '_bs_', sitff_h_stiff{k}, '.mp4'];
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
