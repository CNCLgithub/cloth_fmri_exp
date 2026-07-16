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
    
    %%
    p.tr_in_sec              = 0.8;            
    p.begin_wait             = 10;             
    p.end_wait               = 10;             
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
    p.colors.back            = p.colors.black;
   
    %% == probe ==
    p.probe                  = struct();
    p.probe.lastT            = 0.5;
    % cloth
    p.probe.clothDiam        = 12;
    p.probe.clothColor       = p.colors.fore;
    p.probe.clothStartT      = 5;
    %%
    p.instructionTextSize    = 20;
    p.textTextSize           = 30;
    
    %% == Keys ==
    KbName('UnifyKeyNames');
    p.keys.trigger          = [KbName('5%')];
	p.keys.yes              = [KbName('1!')];
    p.keys.no               = [KbName('2@')];
    p.keys.quit             = [KbName('q')];
    p.keys.next             = [KbName('n')];
    
    %% == expCond ==
    p.expCond = struct();
    p.expCond.cond_name = {'cloth_ctl', 'loc_tower'};
    p.expCond.cond_Dir = {};
    for i = 1:length(p.expCond.cond_name)
        p.expCond.cond_Dir= {p.expCond.cond_Dir{:}, fullfile(p.dirs.stimDir, p.expCond.cond_name{i})};
    end
    
    p.expCond.runOrder = {'cloth_ctl', 'loc_tower', 'cloth_ctl', 'cloth_ctl', 'cloth_ctl', 'loc_tower'};

   %% == Save ==
    saveDir = fullfile(pwd);
    save(fullfile(saveDir, ['Setup_',computer,'.mat']), 'p');