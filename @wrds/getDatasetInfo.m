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
    sascmd = sprintf(['FILENAME out "~/tmp/cmd.lst";',...
                      'PROC PRINTTO print=out;',...
                      'RUN;',...
                      'PROC DATASETS LIBRARY=%s NOLIST;',...
                      'CONTENTS DATA=%s;',...
                      'RUN;'],...
                     libref, dtname);

    % UNIX command
    cmd    = sprintf(['touch ~/tmp/cmd.sas;',...                    % Create file
                   'printf ''%s'' > ~/tmp/cmd.sas;',...          % Write sas command
                   'qsas ~/tmp/cmd.sas -log ~/tmp/cmd.log;'],... % Execute sas
                  sascmd);
    result = wrds.forwardCmd(cmd);

    oldState       = wrds.isVerbose;
    wrds.isVerbose = false;

    switch dtname
        case '_ALL_'
            fname        = sprintf('CONTENTS_%s',libref);
            cmd          = sprintf('cd ~/tmp; mv cmd.lst %s.txt; zip -m %s.zip %s.txt;', fname, fname, fname);
            result       = wrds.forwardCmd(cmd);
            fname        = sprintf('~/tmp/%s.zip',fname);
            [wrds, info] = wrds.getFile(fname);
            cleanup      = onCleanup(@() wrds.forwardCmd(sprintf('rm %s;',fname)));
        otherwise
            result = wrds.forwardCmd('cat ~/tmp/cmd.lst');
            info   = char(result);
    end

    wrds.Datasetinfo.(libref).(matlab.lang.makeValidName(dtname)) = info;

    wrds.isVerbose = oldState;
end
end
