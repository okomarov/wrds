function wrds_install()
% WRDS_INSTALL Install the WRDS API

% Add path of this folder
p = fileparts(mfilename('fullpath'));
addpath(p)

% Add path to ssh2
addpath(fullfile(p,'external','ssh2'))
passfield_path = fullfile(p,'external','passfield');

if isempty(dir(fullfile(passfield_path,'*.m')))
    try
        fname = unzip('https://github.com/okomarov/passfield/archive/master.zip',tempdir());
        copyfile(fileparts(fname{1}), passfield_path)
    catch
        warning(['could not install the passfield() dependency.\n\n', ...
                 'For manual installation:\n',...
                 '\t1) download the .zip file from <a href="https://github.com/okomarov/passfield/">github.com/okomarov/passfield</a>;\n',...
                 '\t2) unpack and copy the content of the folder into ''%s'';\n',...
                 '\t3) run addpath(''%s'').\n'],passfield_path,passfield_path)
    end
end
addpath(passfield_path)

% Make data path
if ~exist(fullfile(p,'data'),'dir')
    mkdir(fullfile(p,'data'))
end
end