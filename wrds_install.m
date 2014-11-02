% Add path of this folder
p = fileparts(mfilename('fullpath'));
addpath(p)

% Unzip ssh2
unzip(fullfile(p,'external','ssh2.zip'), fullfile(p,'external'))
addpath(fullfile(p,'external','ssh2'))

% Save path
savepath

% Make data path
mkdir(fullfile(p,'data'))