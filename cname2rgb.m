function rgb = cname2rgb(name)
% CNAME2RGB Maps a short or long color name to an RGB triplet 
%   
%   CNAME2RGB(NAME) Where names should be a string. Accepted 
%                   color names are listed in the <a href="matlab:doc
%                   colorspec">ColorSpec</a>.
%
%   RGB = ... Returns an RGB triplet
%
% Examples:
%   color = cname2rgb('r') % or equivalently cname2rgb('red')

% Author: Oleg Komarov (oleg.komarov@hotmail.it) 
% Tested on R2014a Win7 64bit
% 2014 Sep 22 - Created

if ~(ischar(name) && isrow(name))
    error('cname2rgb:stringName','NAME should be a string.')
end
rgbmap = {...
'y',	'yellow',   [1 1 0]
'm',	'magenta',  [1 0 1]
'c',	'cyan',     [0 1 1]
'r',	'red',      [1 0 0]
'g',	'green',    [0 1 0]
'b',	'blue',     [0 0 1]
'w',	'white',    [1 1 1]
'k',	'black',    [0 0 0]};
if numel(name) == 1
    idx = strcmpi(name, rgbmap(:,1));
else
    idx = strcmpi(name, rgbmap(:,2));
end
if any(idx)
    rgb = rgbmap{idx,3};
else
    error('cname2rgb:invalidName','Unrecognized NAME: ''%s''.',name)
end
end