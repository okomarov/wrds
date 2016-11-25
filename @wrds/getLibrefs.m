function librefs = getLibrefs(wrds,force)
% GETLIBDATANAMES Retrieve all SAS library names
%
%    Retrieves all cached librefs or from the server (FORCE = true)
%
% See also: WRDS, SAS2CSV
if nargin < 2 || isempty(force)
    force = false;
end
librefs = wrds.Librefs;

if force || isempty(librefs) || iscell(librefs) && isempty(librefs{1})
    if wrds.isVerbose, fprintf('Retrieving SAS library names (libref).\n'), end

    cleanup = onCleanup(wrds.cmdCleanup());

    % Build command
    sascmd = 'libname _all_ list;';
    cmd    = sprintf(['touch "~/tmp/cmd.sas";',...                     % Create file
                      'printf ''%s'' > ~/tmp/cmd.sas;',...             % Write sas command
                      'qsas ~/tmp/cmd.sas -log ~/tmp/cmd.log;',...     % Execute sas
                      'grep ''NOTE: Libref='' ~/tmp/cmd.log | ',...    % Parse log for librefs
                      'sed ''s/^NOTE: Libref= *//'' | ',...
                      'sed ''s/ *//g'';'],...
             sascmd);

    result = wrds.forwardCmd(cmd);

    % Store in the object
    librefs      = sort(result);
    wrds.Librefs = librefs;
end
end