function info = getDatasetInfo(wrds, libdataname, force)
% GETDATASETNAMES Retrieve dataset names within a library
%
%   INFO = GETDATASETINFO(WRDS, LIBDATANAME) LIBDATANAME should be a
%                              string with the SAS library and dataset in
%                              the format <libref>.<data set>,
%                              e.g. 'CRSPA.MSI'.
%
%   NOTE: if only libref is supplied, or _ALL_ datasets, the info will
%         be downloaded as a zipped file.
%
% See also: WRDS, GETLIBREFS, GETDATASETNAME
if nargin < 3 || isempty(force)
    force = false;
end

[libref, dtname] = wrds.validateLibdataname(libdataname);

try
    if force
        error('Force-forward request to wrds.');
    end
    info = wrds.Datasetinfo.(libref).(matlab.lang.makeValidName(dtname));
catch
    if wrds.isVerbose, fprintf('Retrieving dataset info for ''%s''.\n', libdataname), end

    cleanup = onCleanup(wrds.cmdCleanup());

    % SAS command
    if strcmp(dtname, '_ALL_')
        fname   = sprintf('~/tmp/CONTENTS_%s.zip', libref);
        printto = sprintf(['FILENAME out zip "%s" member="%s.txt";',...
                           'PROC PRINTTO print=out new;',...
                           'RUN;'], fname, libref);
    else
        fname   = [];
        printto = ['FILENAME out "~/tmp/cmd.lst";',...
                   'PROC PRINTTO print=out;',...
                   'RUN;'];
    end
    sascmd = [printto,...
              sprintf(['PROC DATASETS LIBRARY=%s NOLIST;',...
                       'CONTENTS DATA=%s;',...
                       'RUN;'], libref, dtname)];

    % UNIX command
    cmd    = sprintf(['touch ~/tmp/cmd.sas;',...                    % Create file
                      'printf ''%s'' > ~/tmp/cmd.sas;',...          % Write sas command
                      'qsas ~/tmp/cmd.sas -log ~/tmp/cmd.log;'],... % Execute sas
                      sascmd);
    result = wrds.forwardCmd(cmd);

    oldState       = wrds.isVerbose;
    cleanup        = onCleanup(@()myCleanup(wrds,fname,oldState));
    wrds.isVerbose = false;

    if strcmp(dtname, '_ALL_')
        [wrds, info] = wrds.getFile(fname);
        info = fullfile(info, sprintf('CONTENTS_%s.zip', libref));
    else
        result = wrds.forwardCmd('cat ~/tmp/cmd.lst');
        info   = char(result);
    end

    wrds.Datasetinfo.(libref).(matlab.lang.makeValidName(dtname)) = info;
end
end

function myCleanup(wrds,fname,vstate)
if ~isempty(fname)
    wrds.forwardCmd(sprintf('rm %s;',fname));
end
wrds.isVerbose = vstate;
end