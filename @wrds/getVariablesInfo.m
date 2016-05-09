function out = getVariablesInfo(wrds, libdataname)
% GETVARIABLESINFO Retrieve format and description of dataset variables
%
%   GETVARIABLESINFO(WRDS, LIBDATANAME)
%       LIBDATANAME should be a string with the SAS library and
%       dataset in the format <libref>.<data set>, e.g. 'CRSPA.MSI'.
%
%   OUT = ...
%       Table with:
%
%       Pos | Variable | Type | Len | Format | Informat | Label | FormatTextscan
%
% Examples:
%   w = wrds('myusername');
%   w.getVariablesInfo('crspa.mse')
%
% See also: GETDATASETINFO

% Extract Variables and Atributes section from dataset info
info   = wrds.getDatasetInfo(libdataname);
info   = cellstr(info);
from   = find(~cellfun('isempty',regexp(info,'Variables and Attributes'))) + 1;
to     = find(~cellfun('isempty',regexp(info,'Indexes and Attributes')))   - 1;
info   = info(from:to);
info   = info(~cellfun('isempty',info));
vnames = info{1};
info   = char(info(2:end));

% Split into cell array by fixed widths
field_from    = regexp(vnames,' [^ ]','start')+1;
field_from(1) = 1;
field_widths  = [field_from(2:end), size(info,2)+1] - field_from;
nrows         = size(info,1);
out           = mat2cell(info, ones(nrows,1), field_widths);
out           = deblank(out);

% Sew together lengthy descriptions
lastDesc = 1;
ikeep    = true(nrows,1);
for r = 2:nrows
    if isempty(out{r,1})
        ikeep(r)          = false;
        out{lastDesc,end} = [out{lastDesc,end} ' ' out{r,end}];
        continue
    end
    lastDesc = r;
end
out   = out(ikeep,:);
nrows = size(out,1);

% Reorder according to position
Pos        = str2double(out(:,1));
out(Pos,:) = out;
Len        = str2double(out(:,4));

% Get suggested textscan format
FormatTextscan = getTextscanFormat(out(:,3),Len,out(:,5));

vnames = strsplit(vnames,' ');
vnames = strrep(vnames,'#','Pos');
vnames = vnames(~cellfun('isempty',vnames));

out = table((1:nrows)',char(out(:,2)),char(out(:,3)), Len,...
             char(out(:,5)),char(out(:,6)), out(:,7),...
             FormatTextscan, 'VariableNames',[vnames, 'FormatTextscan']);
end

function cellfmt = getTextscanFormat(sastype, saslen, sasformat)
nrows   = numel(sastype);
cellfmt = cell(nrows,1);
for r = 1:nrows
    if strcmp(sastype{r},'Char')
        cellfmt{r} = sprintf('%%%dc',saslen(r));
    else
        part = strsplit(sasformat{r},'.');

        if isempty(sasformat{r}) || ~isempty(part{2})
            cellfmt{r} = '%f';
        else

            switch part{1}
                case {'1','2'}
                    cellfmt{r} = '%u8';
                case {'3','4'}
                    cellfmt{r} = '%u16';
                case {'5','6','7','8','9','YYMMDDN8'}
                    cellfmt{r} = '%u32';
                otherwise
                    cellfmt{r} = '%u64';
            end
        end
    end
end
end
