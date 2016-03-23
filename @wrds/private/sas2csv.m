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

% SAS command%
sascmd = getSasCmd(libdataname, libref, dtname);

% UNIX command
cmd = sprintf(['touch "~/tmp/cmd.sas";',...                     % Create
               'printf ''%s'' > ~/tmp/cmd.sas;',...             % Write sas command
               'qsas ~/tmp/cmd.sas -log ~/tmp/cmd.log;'],...    % Execute sas
      sascmd);

wrds.forwardCmd(cmd);

% Transfer the data
cleanup = onCleanup(@() wrds.cmd('rm ~/tmp/dataset.zip',false));
wrds.getFile('~/tmp/dataset.zip', outfile);
end

function str = getSasCmd(libdataname, libref, dtname)
nl  = sprintf('\n');
rawstr = [...
'* Pipe into .zip;' nl...
'filename writer zip "~/tmp/dataset.zip" member="%s.csv";' nl...
'' nl...
'* Taken from https://communities.sas.com/message/185633#185633;' nl...
'* Read dataset variable names;' nl...
'proc sql noprint;' nl...
'   select ''"''||trim(name)||''"''' nl...
'   into :names' nl...
'   separated by "'',''"' nl...
'   from dictionary.columns' nl...
'   where libname eq "%s" and memname eq "%s";' nl...
'quit;' nl...
'* Write data;' nl...
'data _null_;' nl...
' set %s;' nl...
' file writer dsd dlm='','' lrecl=1000000;' nl...
' if _n_ eq 1 then put &names.;' nl...
' put (_all_) (+0);' nl...
'run;'];

str = sprintf(rawstr, libdataname, libref, dtname, libdataname);

str = regexprep(str,'\*[^\n\r]*[\n\r]*','');      % strip comments
str = regexprep(str,'[ \t]*',' ');                % multiple spaces to one
str = regexprep(str,'[\n\r]*','\\n');             % newlines to literal \n
str = regexprep(str,'''','\\047');                % single quote ' to octal representation \047
end