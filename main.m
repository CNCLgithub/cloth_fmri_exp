sca;
clear all; close all; clc;
Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference', 'ConserveVRAM', 64);
%% ==================== Params  ==========================================%
% [wb]: use extend display, check the resolution of the other display in "settings"
screen_res   = [0 0 1920 1080]; 
% screen_res   = [];
study_name     = 'SoftObjects';
tr_counte      = 0;
tr_timestamp   = [];
stop_exp       = false;
dummymode      = 1;

if isempty(screen_res)
    try
        % [wb]: Double check full screen.
        default = 'null';
        use_fullscr = default;
        while (strcmp(use_fullscr, 'y') ~= 1)
            use_fullscr = input(sprintf('\nUse full screen? \''y\'' to confirm, \''n\'' to quit. \n :'), 's');
            if (isempty(use_fullscr)), use_fullscr = default; end
            if (strcmp(use_fullscr, 'n') == 1), error('quit by user'); end
        end 
        
        [w, screen_res] = Screen('OpenWindow', max(Screen('Screens')), [0 0 0]);
        Screen('CloseAll');
    catch
        Screen('CloseAll');
    end
end


%% ==================== Inputs & Post-hoc prefs===========================%
prefs = Setup(); 

prefs.dummymode           = dummymode;
prefs.studyName           = study_name;
prefs.dirs.subjDir        = '';
prefs.dirs.curRunCondFile = '';
prefs.subj                = '';
prefs.runNum              = -1;
prefs.res                 = screen_res;

% -------------------------------------------------- %
%WB%  debugmode
defaultDebug = '0';
debugmode = input(sprintf('Debug mode, 1 to debug [%s]: ', num2str(defaultDebug)), 's');
if (isempty(debugmode)), debugmode= defaultDebug; end
debugmode = str2num(debugmode);

%WB% Ask for current subject: [theSbj, prefs.dirs.subjDir]
defaultSbj = 'wbi';
theSbj = input(sprintf('Enter subject name [%s]: ', defaultSbj), 's');
if (isempty(theSbj)), theSbj= defaultSbj; end
prefs.dirs.subjDir = fullfile(prefs.dirs.dataDir, theSbj);
prefs.subj = theSbj;

%WB% Ask for the run number: [runNumber]
defaultRun = '1';
prefs.runNum = input(sprintf('Enter run number [%s]: ', defaultRun),'s');
if(isempty(prefs.runNum)), prefs.runNum = defaultRun; end
prefs.runNum = str2num(prefs.runNum);

%WB% Load run-order: [prefs.dirs.curRunCondFile]
prefs.dirs.curRunCondFile = fullfile(prefs.dirs.subjDir, 'run_order', ...
                                     ['run_', num2str(prefs.runNum), '.mat']);
if isempty(dir(prefs.dirs.curRunCondFile))
    warning('\nCondition file not found: %s\n run generate_cond_files.m\n', ...
        prefs.dirs.curRunCondFile);
end

%WB% Display
disp(['==> Run ' num2str(prefs.runNum) ', ' prefs.expCond.runOrder{prefs.runNum}, ...
    ', ', prefs.subj]);  

%% ==================== Set keys =========================================%
KbName('UnifyKeyNames');
if ~debugmode
    DEVICENAME = 'Current Designs, Inc. 932';
    %DEVICENAME = 'Logitech G203 LIGHTSYNC Gaming Mouse Keyboard';
else
    if ismac
        DEVICENAME = 'Apple Internal Keyboard / Trackpad'; % if use macbook air
    else
        DEVICENAME = 'AT Translated Set 2 keyboard';
    end
end


[index, devName] = GetKeyboardIndices;
for device = 1:length(index)
    if strcmp(devName(device), DEVICENAME)
        kb_pointer = index(device);
        break;
    end
end

KeysofInterest = zeros(1, 256);
KeysofInterest([prefs.keys.trigger, ...
                prefs.keys.yes, ...
                prefs.keys.no, ...
                prefs.keys.quit, ...
                prefs.keys.next])=1;   
KbQueueCreate(kb_pointer, KeysofInterest);
KbQueueStart(kb_pointer); 

%% ==================== Initialize ===================================%
switch prefs.expCond.runOrder{prefs.runNum}
    case {'cloth_ctl'}
        design = 'trial';
    case {'loc_tower'}
        addpath(genpath(prefs.dirs.loc_tower_dir));
        towers_color_fall(prefs, kb_pointer, screen_res);
        rmpath(genpath(prefs.dirs.loc_tower_dir)); savepath;
        sca;
    otherwise
        error("Wrong run name: %s!", prefs.expCond.runOrder{prefs.runNum});
end
% --------------------------
if (strcmp(design, 'trial')==1)
    b = TrialInfo(prefs);
elseif (strcmp(design, 'block')==1)
    b = BlockInfo(prefs);
end
% --------------------------
prefs.b   = b;
win       = OpenScreen(prefs);
T         = CreateDataTable(prefs, design);
vid_param = GetVidRect(prefs, win, T);
tr_log    = [];
% --------------------------

% -------------------------- trigger ------------------------------------%
% ====== [wb] Waiting for TRs ======
% KbQueueStart(kb_pointer);
[tr_counter, ScanStartTime] = WaitForTrigger(win.ptr, prefs, kb_pointer, 'Waiting for scanner...');
tr_log = [tr_log, [tr_counter, ScanStartTime]];
[tr_counter, ScanStartTimeSkippedBegin, tr_log] = BeginWait(win.ptr, prefs, kb_pointer, tr_counter, tr_log);
save(['data.mat']);

%% ==================== Run experiment ===================================%
if (strcmp(design, 'trial')==1)
    [T, tr_log] = RunEventDesign(prefs, win, T, vid_param, kb_pointer, tr_counter, ScanStartTime, ScanStartTimeSkippedBegin, tr_log);
elseif (strcmp(design, 'block')==1)
    [T] = RunBlockDesign(prefs, win, T, vid_param, kb_pointer, tr_counter, ScanStartTime, ScanStartTimeSkippedBegin);
end

%% ==================== del & rm ===================================%
rmpath(genpath(prefs.dirs.utilDir)); savepath;
rmpath(genpath(prefs.dirs.loc_tower_dir)); savepath;

