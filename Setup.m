function p = Setup()
    % Setup global params for the experiment
    % if nargin == 0, screen_res = []; end
    p = struct();
    
    %% == Dirs & Path ==
    p.dirs                   = struct();
    p.dirs.curDir            = pwd;
    p.dirs.rootDir           = p.dirs.curDir;
    p.dirs.utilDir           = fullfile(p.dirs.curDir, 'utils');
    p.dirs.exptDir           = fullfile(p.dirs.rootDir, 'exp');
    p.dirs.stimDir           = fullfile(p.dirs.exptDir, 'stimuli');
    p.dirs.loc_tower_dir     = fullfile(p.dirs.stimDir, 'loc_tower');
    p.dirs.dataDir           = fullfile(p.dirs.exptDir, 'res');
    p.dirs.runOrderDirName   = 'run_order';
   
    % ----------------------
    addpath(p.dirs.utilDir, p.dirs.loc_tower_dir);
    % addpath(genpath(p.dirs.utilDir)); savepath;
    
    %%
    p.tr_in_sec              = 0.8;            %
    p.begin_wait             = 10;             % [wb] skip first n-1 trs, cause tr starts at 1
    p.end_wait               = 10;             % [wb] 20
    p.null_val               = '';
    p.null_num               = -1;
    p.RANDSeed               = ClockRandSeed;
    
    %% == colors ==
    p.colors                 = struct();
    p.colors.gray            = GrayIndex(max(Screen('Screens')));
    p.colors.black           = [0 0 0];
    p.colors.red             = [255 0 0];
    p.colors.white           = [255 255 255];
    p.colors.fore            = p.colors.white;
    p.colors.back            = p.colors.black;  %[128, 128, 128]
   
    %% == probe ==
    p.probe                  = struct();
    p.probe.lastT            = 0.5;
    % cloth
    p.probe.clothDiam        = 12;
    %p.probe.clothColor      = p.colors.gray;
    p.probe.clothColor       = p.colors.fore;
    p.probe.clothStartT      = 5;
    % liquid
    p.probe.liquidDiam       = 15;
    p.probe.liquidColor      = [255, 0, 0];
    p.probe.liquidStartT     = 3.5;
    %%
    p.instructionTextSize    = 20;
    p.textTextSize           = 30;
    
    %% == Keys ==
    KbName('UnifyKeyNames');
    p.keys                  = struct();
    p.keys.trigger          = [KbName('5%')];
	p.keys.yes              = [KbName('1!')];
    p.keys.no               = [KbName('2@')];
    p.keys.quit             = [KbName('q')];
    p.keys.next             = [KbName('n')];
    
    %% == expCond ==
    p.expCond = struct();
    p.expCond.cond_name = {'cloth_ctl', 'liquid_ctl', 'loc_tower', 'loc_dots', 'cloth_drape'};
    p.expCond.cond_Dir = {};
    for i = 1:length(p.expCond.cond_name)
        p.expCond.cond_Dir= {p.expCond.cond_Dir{:}, fullfile(p.dirs.stimDir, p.expCond.cond_name{i})};
    end
    
    p.expCond.runOrder = {'cloth_ctl', 'liquid_ctl', 'cloth_ctl', 'liquid_ctl', ...
                          'cloth_ctl', 'liquid_ctl', 'cloth_ctl', 'liquid_ctl', 'liquid_ctl', ...
                          'loc_dots',  'loc_dots', 'loc_tower', 'loc_tower', ...
                          'cloth_drape', 'cloth_drape'};

   %% == Save ==
    saveDir = fullfile(pwd);
    save(fullfile(saveDir, ['Setup_',computer,'.mat']), 'p');


    
    
%% == Get monitor params ===============================%
%     Screen('Preference', 'SkipSyncTests', 1);
%     screenNumber           = max(Screen('Screens'));
%     [w, wRect]             = Screen('OpenWindow', screenNumber, [0 0 0], screen_res);
%     [X,Y]                  = RectCenter(wRect);
%     
%     p.monitor              = struct();
%     p.monitor.screenNumber = screenNumber;
%     p.monitor.gray         = gray;
%     p.monitor.res          = wRect;
%     p.monitor.height       = wRect(4);
%     p.monitor.width        = wRect(3);
%     p.monitor.centerX      = X;
%     p.monitor.centerY      = Y;
%
%     Screen('CloseAll');
