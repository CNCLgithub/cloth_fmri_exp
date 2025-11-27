sca;
Screen('Preference', 'SkipSyncTests', 1);
Screen('CloseAll');
clear all;
clc;

%% ======================= Path & Inputs =================================%
dirs                   = struct();
dirs.curDir            = pwd;
dirs.utilDir           = fullfile(dirs.curDir, 'utils');
% ----------
cd(dirs.utilDir);
if ~strfind(path, pwd), addpath(genpath(pwd)); savepath; end
cd(dirs.curDir);
% -------------------------------------------------- %
dirs.rootDir           = dirs.curDir;
dirs.exptDir           = fullfile(dirs.rootDir, 'exp');
dirs.stimDir           = fullfile(dirs.exptDir, 'stimuli');
dirs.dataDir           = fullfile(dirs.exptDir, 'res');
dirs.subjDir           = '';
dirs.curRunCondFile    = '';
% ------------------------------