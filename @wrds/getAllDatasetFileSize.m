function fsize = getAllDatasetFileSize(wrds, libname, unit)
% GETALLDATASETFILESIZE Retrieve the uncompressed size of all datasets in a library
%
%   GETALLDATASETFILESIZE(WRDS, LIBNAME, [UNIT])
%       LIBNAME should be a string with the SAS library, e.g. 'CRSPA.MSI'.
%       UNIT can be any of 'k', 'kb', 'mb' (default) or 'gb'.
%
%   FSIZE = ...
%       File size of the uncompressed datasets in the specified UNIT.
%
% Examples:
%   w = wrds('myusername');
%   w.getDatasetFileSize('crspa','gb')
%
% See also: GETDATASETFILESIZE, GETDATASETINFO

dtnames = wrds.getDatasetNames(libname);

% Switch verbosity off
verbosity      = wrds.isVerbose;
wrds.isVerbose = false;

% Setup waitbar
h     = waitbar(0);
pause(0.1)
msgh  = getfield(getappdata(h,'TMWWaitbar_handles'),'axesTitle');
set(msgh,'Interpreter','none');

cleanup = onCleanup(@()myCleanup(wrds,verbosity,h));

N     = numel(dtnames);
fsize = NaN(N,1);
for ii = 1:N
    % Update waitbar text
    libdtname = [libname, '.', dtnames{ii}];
    msg       = sprintf('Retrieving size of ''%s''.',upper(libdtname));
    set(msgh,'String',msg);
    drawnow

    fsize(ii) = getDatasetFileSize(wrds,libdtname,unit);

    % Update progress
    waitbar(ii/N,h)
end
waitbar(1, h, 'Completed.')
end

function myCleanup(wrds,verbosity,hwait)
wrds.isVerbose = verbosity;
close(hwait)
end
