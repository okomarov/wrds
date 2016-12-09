function dtnames = getDatasetNames(wrds, libref, force)
% GETDATASETNAMES Retrieve dataset names within a library
%
%    DTNAMES = GETDATASETNAMES(WRDS, LIBREF) It retrieves the data set parts
%                                    in <libref>.<data set>, e.g.
%                                    CRSPA.STOCKNAMES, etc...
%
% See also: WRDS, GETLIBREFS, SAS2CSV
if nargin < 3 || isempty(force)
    force = false;
end

[libref, dtname] = wrds.validateLibdataname(libref);

try
    if force
        error('Force-forward request to wrds.');
    end
    dtnames = wrds.Libdatasets.(libref);
catch
    if wrds.isVerbose, fprintf('Retrieving dataset names for ''%s''.\n', libref), end

    cleanup = onCleanup(wrds.cmdCleanup());

    % SAS command
    sascmd = sprintf(['FILENAME out "~/tmp/cmd.lst";',...
                      'PROC PRINTTO print=out;',...
                      'RUN;',...
                      'PROC SQL;',...
                      'SELECT DISTINCT memname',...
                      '   FROM dictionary.columns WHERE libname="%s";'],...
             libref);

    % UNIX command
    cmd = sprintf(['touch "~/tmp/cmd.sas";',...                         % Create file
                   'printf ''%s'' > ~/tmp/cmd.sas;',...                 % Write sas command
                   'qsas ~/tmp/cmd.sas -log ~/tmp/cmd.log;',...         % Execute sas
                   'grep ''^ *[A-Z_0-9]* *$'' ~/tmp/cmd.lst | ',...     % Parse .lst   
                   'sed ''s/ *//g'';'],...
          sascmd);

    result = wrds.forwardCmd(cmd);

    % Store in wrds
    dtnames = sort(result);
    if isempty(dtnames{1})
        dtnames = {};
    end
    wrds.Libdatasets.(libref) = dtnames;
end
if isempty(dtnames)
    warning('No remote access to datasets in ''%s''.',libref);
end
end