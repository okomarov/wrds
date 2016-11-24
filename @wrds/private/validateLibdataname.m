function [libref, dtname] = validateLibdataname(wrds,libdataname)
% VALIDATELIBDATANAME Validates and splits libdatanames
%
%   A valid LIBDATANAME should be a string with the SAS library 
%   and dataset in the format <libref>.<data set>, e.g. 'CRSPA.MSI'.
%
%   A LIBDATANAME without a dataset, will default the DTNAME to '_all_'.
%
% See also: 

% Library and datasetname
tmp    = regexp(libdataname, '\.','split');
nparts = numel(tmp);

if nparts < 2 || isempty(tmp{2})
    dtname = '_ALL_';
elseif nparts > 2
    error('wrds:validateLibdataname','Invalid LIBDATANAME.')
else
    dtname = upper(tmp{2});
end

libref = tmp{1};

try
    allLib = wrds.getLibrefs();
    idx    = strcmpi(libref, allLib);
    libref = allLib{idx};
catch
    error('wrds:validateLibdataname','Unrecognised library ''%s''.', libref);
end
end
