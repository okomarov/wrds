function fsize = getDatasetFileSize(wrds, libdataname, unit)
% GETDATASETFILESIZE Retrieve dataset's uncompressed size in megabytes
%
%   GETDATASETFILESIZE(WRDS, LIBDATANAME, [UNIT])
%       LIBDATANAME should be a string with the SAS library and
%       dataset in the format <libref>.<data set>, e.g. 'CRSPA.MSI'.
%       UNIT can be any of 'k', 'kb', 'mb' (default) or 'gb'.
%
%   FSIZE = ...
%       File size of the uncompressed dataset in the specified UNIT.
%       If the output is not assigned to the workspace, it will print
%       the size to the command window.
%
% Examples:
%   w = wrds('myusername');
%   w.getDatasetFileSize('crspa.dsf','gb')
%   ans =
%   13.25 GB
%
% See also: GETDATASETINFO


if nargin < 3
    pow  = 1;
    unit = 'MB';
else
    [pow, unit] = getConversionPower(unit);
end

% Get dataset info
info = wrds.getDatasetInfo(libdataname);
info = reshape(info',1,[]);

% Get size in units
bytes    = regexpi(info,'(?<=File Size[^\d]*)\d+','match','once');
bytes    = str2double(bytes);
filesize = bytes/1024^pow;

if nargout == 0
    nf = java.text.DecimalFormat;
    sprintf('%s %s',nf.format(bytes/1024^pow),unit)
else
    fsize = filesize;
end
end

function [pow,unit] = getConversionPower(unit)
validUnit = {'B','KB','MB','GB'};
pos       = find(strncmpi(unit,validUnit,numel(unit)));
if isempty(pos)
    error('wrds:getDatasetFileSize','Invalid UNIT.')
end
unit = validUnit{pos};
pow  = pos-1;
end
