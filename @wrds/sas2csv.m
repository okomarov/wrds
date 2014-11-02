function sas2csv(wrds, libdataname, outfile)
if nargin < 3 || isempty(outfile)
    outfile = fullfile(wrds.Dir,'data',[libdataname, '.zip']); 
end
    
% Library and datasetname
tmp     = regexp(libdataname, '\.','split');
libname = tmp{1};
dtname  = tmp{2};

% Import sas command
fid = fopen(fullfile(wrds.Dir, 'sas','sas2csv.sas'));
str = fread(fid,'*char')';
fclose(fid);

% Create .zip temp name and 8char uuid for the fileref
fulluuid = ['f', strrep(char(java.util.UUID.randomUUID),'-','_')];
tmpzip   = sprintf('~/tmp/%s.zip',fulluuid);
uuid     = fulluuid(1:8);

% Fill in dataset and temp file names
sascmd = sprintf(str, uuid, tmpzip, libname, dtname, libdataname, uuid);
sascmd = regexprep(sascmd,'\*[^\n\r]*[\n\r]*','');      % strip comments
sascmd = regexprep(sascmd,'[ \t]*',' ');                % multiple spaces to one
sascmd = regexprep(sascmd,'[\n\r]*','\\n');             % newlines to literal \n
sascmd = regexprep(sascmd,'''','\\047');                % single quote ' to octal representation \047

% Build command
% mkdir -p tmp
cmd = sprintf(['rm tmp/sas2csv.sas;'...                     % Delete
    'touch "~/tmp/sas2csv.sas";',...                        % Create
    'printf ''%s'' > ~/tmp/sas2csv.sas;',...                % Write sas command
    'sas tmp/sas2csv.sas -log ~/tmp/report.log && ',...     % Execute sas
    'printf "@ -\\n@=%s.csv\\n" | zipnote -w %s',...        % Rename file in zip 
    ],sascmd, libdataname, tmpzip);

% Execute through ssh
wrds.ssh2obj = ssh2_command(wrds.ssh2obj,cmd,1);

% Transfer the data
localdir     = fileparts(outfile);
wrds.ssh2obj = scp_get(wrds.ssh2obj, tmpzip, localdir);

% Rename
movefile(fullfile(localdir, [fulluuid '.zip']), outfile)
end