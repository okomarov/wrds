function getDataset(wrds, libdataname, outfile)
% GETDATASET Download WRDS data set as zipped CSV
%   GETDATASET(CONN, LIBDATANAME, [OUTFILE])
%       Where CONN should be a valid WRDS connection and
%       LIBDATANAME should be a string with the SAS library and
%       dataset in the format <libref>.<data set>,
%       e.g. 'CRSPA.MSI'.
%
%       Specify where to save the downloaded dataset in OUTFILE.
%       It defaults to fullfile(cd,  data, '<libref>.<data set>.zip').
%
% See also: GETDATASETINFO, GETFILE, WRDS, UNZIP, CSVREAD, READTABLE
if nargin < 3, outfile = [libdataname '.zip']; end
sas2csv(wrds, libdataname, outfile);
end