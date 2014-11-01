function sas2csv(wrds, libdataname, outfile)
% addpath .\external\ssh2\
% wrds = ssh2_config('wrds.wharton.upenn.edu','olegkoma',
% Import sas command
fid = fopen('sas2csv.sas');
str = fread(fid,'*char')';
fclose(fid);

% Create temp name 
tmpfile = sprintf('~/tmp/f%s.csv',strrep(char(java.util.UUID.randomUUID),'-','_'));
% Fill in dataset and temp file names
tmp = regexp(libdataname, '\.','split');
sascmd = sprintf(str, tmp{:}, libdataname, tmpfile);

% Replace
sascmd = regexprep(sascmd,'\*[^\n\r]*[\n\r]*','');      % strip comments
sascmd = regexprep(sascmd,'[ \t]*',' ');                % multiple spaces to one
sascmd = regexprep(sascmd,'[\n\r]*','\\n');             % newlines to literal \n
sascmd = regexprep(sascmd,'''','\\047');                % single quote ' to octal representation \047

% Build command
% mkdir -p tmp
cmd = sprintf(['rm tmp/sas2csv.sas;'...                 % Delete 
               'touch "tmp/sas2csv.sas";',...           % Create
               'printf ''%s'' > tmp/sas2csv.sas;',...   % Write sas command
               'sas tmp/sas2csv.sas'],sascmd);          % Execute sas

% Execute through ssh
ssh2_command(wrds,cmd,1)
% printf "@ -\n@=text.csv\n" | zipnote -w myfile.zip
end