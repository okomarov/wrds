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
    unit = 'MB';
end
[pow, unit] = getConversionPower(unit);

% Get dataset info
info = wrds.getDatasetInfo(libdataname);
info = reshape(info',1,[]);

% Get size in units
tkns     = regexpi(info,'(?<=File Size[^\d]*)(\d+)(\w{1,2})','tokens','once');
num      = str2double(tkns{1});
filesize = num/1024^(pow-getConversionPower(tkns{2}));

if nargout == 0
    nf = java.text.DecimalFormat;
    sprintf('%s %s',nf.format(filesize),unit)
else
    fsize = filesize;
end
end

function [pow,unit] = getConversionPower(unit)
% From 0 to 3
validUnit = {'B','KB','MB','GB'};
pos       = find(strncmpi(unit,validUnit,numel(unit)));
if isempty(pos)
    error('wrds:getDatasetFileSize','Invalid UNIT.')
end
unit = validUnit{pos};
pow  = pos-1;
end
