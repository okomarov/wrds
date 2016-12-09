function getAllDatasets(wrds, libname, outfolder, checksize, startfrom)
% GETALLDATASETS Download all data sets of a WRDS library as zipped CSV
%   GETALLDATASETS(CONN, LIBNAME, [OUTFOLDER], [CHECKSIZE])
%       Where CONN should be a valid WRDS connection and
%       LIBNAME should be a string with the SAS library,
%       e.g. 'CRSPA'.
%
%       Specify where to save the downloaded datasets in OUTFOLDER.
%       It defaults to fullfile(data, LIBNAME, datasetname.zip).
%
%       NOTE: an entire library can take up several GB on disk.
%             With CHECKSIZE set to true, first the size of library
%             is assessed and afterwards the user is asked
%             whether to proceed.
%
% Examples:
%   w = wrds('myusername');
%   w.getAllDatasets('crspa')
%
% See also: GETDATASET, GETDATASETINFO, GETFILE, WRDS, UNZIP, CSVREAD, READTABLE

COMPRESSION_FACTOR = 8;

if nargin < 3 || isempty(outfolder)
    outfolder = fullfile('data', upper(libname));
end
if nargin < 4 || isempty(checksize)
    checksize = false;
end
if nargin < 5 || isempty(startfrom)
    startfrom = 1;
end

if ~exist(outfolder,'dir')
    mkdir(outfolder)
end

dtnames = wrds.getDatasetNames(libname);

if isempty(dtnames)
    return
end

N = numel(dtnames);
if checksize
    fsizes = getAllDatasetFileSize(wrds, libname, 'gb');
    fsizes = cumsum(fsizes);

    % Confirm bulk download
    msg    = sprintf(['The estimated compressed size of the library is %.2f GB.\n',...
                      'Do you want to proceed?'], fsizes(end)/COMPRESSION_FACTOR);
    answer = questdlg(msg, 'Bulk download','Yes');
    if any(strcmpi(answer, {'No','Cancel'}))
        return
    end
end

% Switch verbosity off
verbosity      = wrds.isVerbose;
wrds.isVerbose = false;

h    = waitbar(0,'Retrieving datasets...');
pause(0.1)
msgh = getfield(getappdata(h,'TMWWaitbar_handles'),'axesTitle');
set(msgh,'Interpreter','none');

cleanup = onCleanup(@()myCleanup(wrds,verbosity,h));

for ii = startfrom:N
    % Update waitbar text
    libdtname = [libname, '.', dtnames{ii}];
    msg       = sprintf('Retrieving dataset ''%s''.',upper(libdtname));
    set(msgh,'String',msg);
    drawnow

    outfile = fullfile(outfolder, [dtnames{ii} '.zip']);
    getDataset(wrds, libdtname,outfile);

    % Update progress
    if checksize
        progress = fsizes(ii)/fsizes(end);
    else
        progress = ii/N;
    end
    waitbar(progress, h)
end
waitbar(1, h, 'Completed.')
end

function myCleanup(wrds,verbosity,hwait)
wrds.isVerbose = verbosity;
close(hwait)
end
