function sas2csv(wrds, libdataname, outfile)
% SAS2CSV Download SAS data set as zipped CSV
%
%   SAS2CSV(CONN, LIBDATANAME) Where CONN should be a valid WRDS connection
%                              and LIBDATANAME should be a string with the 
%                              SAS library and dataset in the format
%                              <libref>.<data set>, e.g. 'CRSPA.MSI'.
%
%   SAS2CSV(..., OUTFILE)
%
% See also: WRDS, UNZIP, CSVREAD, READTABLE

if wrds.isVerbose, fprintf('Retrieving ''%s''.\n', libdataname), end

cleanup = onCleanup(wrds.cmdCleanup());

% Library and datasetname
tmp    = regexp(libdataname, '\.','split');
libref = tmp{1};
dtname = upper(tmp{2});

% Sanitize input
try
    allLib = wrds.getLibrefs;
    idx    = strcmpi(libref, allLib);
    libref = allLib{idx};
catch ME
end

% Sas command
str = getSasCmd();

% Create .zip temp name and 8char uuid for the fileref
uuid   = ['f', strrep(char(java.util.UUID.randomUUID),'-','_')];
tmpzip = sprintf('~/tmp/%s.zip',uuid);

% Fill in dataset and temp file names
sascmd = sprintf(str, tmpzip, libdataname, libref, dtname, libdataname);
sascmd = regexprep(sascmd,'\*[^\n\r]*[\n\r]*','');      % strip comments
sascmd = regexprep(sascmd,'[ \t]*',' ');                % multiple spaces to one
sascmd = regexprep(sascmd,'[\n\r]*','\\n');             % newlines to literal \n
sascmd = regexprep(sascmd,'''','\\047');                % single quote ' to octal representation \047

% Build command
% mkdir -p tmp
cmd = sprintf(['rm tmp/sas2csv.sas;'...                     % Delete
    'touch "~/tmp/sas2csv.sas";',...                        % Create
    'printf ''%s'' > ~/tmp/sas2csv.sas;',...                % Write sas command
    'sas ~/tmp/sas2csv.sas -log ~/tmp/report.log;',...      % Execute sas
    ],sascmd);

wrds.forwardCmd(cmd);

% Transfer the data
cleanup = onCleanup(@() wrds.cmd('rm ~/tmp/dataset.zip',false));
wrds.getFile('~/tmp/dataset.zip', outfile);
end

function str = getSasCmd()
nl  = sprintf('\n');
str = [...
'* Pipe into .zip;' nl...
'filename writer zip "%s" member="%s.csv";' nl...
'' nl...
'* Taken from https://communities.sas.com/message/185633#185633;' nl...
'* Read dataset variable names;' nl...
'proc sql noprint;' nl...
' select ''"''||trim(name)||''"''' nl...
' into :names' nl...
' separated by "'',''"' nl...
' from dictionary.columns' nl...
' where libname eq "%s" and memname eq "%s";' nl...
'quit;' nl...
'* Write data;' nl...
'data _null_;' nl...
' set %s;' nl...
' file writer dsd dlm='','' lrecl=1000000;' nl...
' if _n_ eq 1 then put &names.;' nl...
' put (_all_) (+0);' nl...
'run;'];
end