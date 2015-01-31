function answer = passdlg(uitype, varargin)
% PASSDLG Create and open password dialog box
%   
%   PASSDLG(UITYPE) Supports several types of dialogs. It will 
%                   always produce one masked password field and
%                   can add the following optional components:
%                       - Username field
%                       - Password confirmation field
%                       - Show/hide password checkbox
%
%                   UITYPE can be a cell array combining 'UsernameField', 
%                   'ConfirmPass' and 'ShowHideCheckBox', or a char string
%                   with the initial letters 'u', 'c' and 's', e.g. 'cs'.
% 
%   PASSDLG(..., Name, Value) Supports Name/Value pairs of <a href="matlab: doc figure-properties">figure properties</a>.
%
%
%   ANSWER = ... 
%       Returns a structure with cellstring fields (by default {''})
%       .User
%       .Pass 
%              
%   NOTE: pressing the button Cancel, Esc or closing the figure will
%   return empty fields.
%
%   
% Examples:
%   % Simple password dialog
%   out = passdlg();
%
%   % Add username and password confirmation field
%   out = passdlg('uc');  % or passdlg({'UsernameField','ConfirmPass'})
%
% See also: PASSFIELD, INPUTDLG

% Author: Oleg Komarov (oleg.komarov@hotmail.it) 
% Tested on R2014a Win7 64bit
% 2014 Sep 21 - Created

if nargin < 1, uitype = ''; end

% Parse UI type
[hasUsernameField, hasConfirmPassword, hasShowCheckBox] = getUItype(uitype);
offset = (hasUsernameField + hasConfirmPassword)*40 + hasShowCheckBox*30 + ~hasShowCheckBox*10;

% Figure
fh = figure('DockControls'  , 'off',...
    'IntegerHandle' , 'off',...
    'InvertHardcopy', 'off',...
    'KeyPressFcn'   , @kpf_figure, ...
    'MenuBar'       , 'none',...
    'NumberTitle'   , 'off',...
    'Resize'        , 'on',...
    'UserData'      , 'Cancel',...
    'Visible'       , 'off',...
    'WindowStyle'   , 'modal',...
    'Name'          , 'Password',...
    'Position'      , [0, 0, 175 83.6 + offset]);

% Params for resize 
h.FigMinWidth     = 175;
h.FigHeight       = 83.6 + offset;
h.OkFromRight     = h.FigMinWidth - 59;
h.CancelFromRight = h.FigMinWidth - 117;

% Axes (for text labels)
ah = axes('Parent',fh,'Position',[0 0 1 1],'Visible','off');

% Get some default properties
defaults = getDefaults;

% Preallocate edit handles
h.edit = {};

% Username field and label
if hasUsernameField
    h.edit{end+1} = uicontrol(fh, ...
        defaults.EdInfo      , ...
        'Max'       ,1, ...
        'Position'  ,[5, 36.6 + offset, 165, 23]);
    h.labeluser = text('Parent',ah, ...
        defaults.TextInfo     , ...
        'Position'   ,[5 59.6 + offset], ...
        'String'     ,'Username'  , ...
        'Interpreter','none');
    offset = offset - 40;
end

% Password field
h.edit{end+1} = passfield('Parent',fh,...
    'Position'       , [5, 36.6 + offset, 165, 23],...
    'BackgroundColor', [1,1,1]);
% Password label
h.labelpass = text('Parent',ah,...
    defaults.TextInfo,...
    'Position'   ,[5 59.6 + offset],...
    'String'     , 'Password',...
    'Interpreter','none');

% Confirm password
if hasConfirmPassword
    offset = offset - 40;
    h.edit{end+1} = passfield('Parent',fh,...
        'Position'       , [5, 36.6 + offset, 165, 23],...
        'BackgroundColor', [1,1,1]);
    h.labelpassconf = text('Parent',ah,...
        defaults.TextInfo,...
        'Position'   ,[5 59.6 + offset],...
        'String'     , 'Confirm password',...
        'Interpreter','none');
end

% Show/hide password checkbox
if hasShowCheckBox
    offset = offset - 28;
    h.cbshow = uicontrol(fh, ...
        defaults.CbInfo,...
        'Position',[5, 36.6 + offset, 165, 23],...
        'String'  , 'Show password',...
        'Callback', {@clb_checkbox,h});
end

% OK button
h.button(1) = uicontrol(fh,...
    defaults.BtnInfo      , ...
    'Position'   ,[59, 5, 53, 26.6] , ...
    'KeyPressFcn',@kpf_button, ...
    'String'     ,'OK',...
    'UserData'   ,'OK',...
    'Callback'   ,@clb_button);

% Cancel button
h.button(2) = uicontrol(fh,...
    defaults.BtnInfo      , ...
    'Position'   ,[117 5 53 26.6],...
    'KeyPressFcn',@kpf_button,...
    'String'     ,'Cancel',...
    'UserData'   ,'Cancel',...
    'Callback'   ,@clb_button);

% fh.setDefaultButton(h.btnok);

% Add password check on confirmation field
if hasConfirmPassword
   set(h.edit{end}, 'KeyPressFcn', {@kpf_confirmpass,h})
end

% Add resize function
set(fh,'ResizeFcn', {@doResize, h});

% Make it visible and apply additional settings
movegui(fh,'center')
if nargin > 1
    set(fh, varargin{:});
end
set(fh,'Visible','on');
drawnow

% Go into uiwait/modal
if ishghandle(fh), uiwait(fh); end

% Parse outputs
if ishghandle(fh)
    [answer.User, answer.Pass] = deal({''});
    if strcmp(get(fh,'UserData'),'OK'),
        if hasUsernameField
            answer.User = get(h.edit{1},{'String'}); 
        end
        answer.Pass = get(h.edit{end},{'Password'});
    end
    delete(fh);
else
    [answer.User, answer.Pass] = deal({''});
end
drawnow
end

function kpf_figure(obj, evd)
switch(evd.Key)
    case {'return','space'}
        uiresume(gcbf);
    case {'escape'}
        delete(gcbf);
end
end

function kpf_button(obj, evd)
switch(evd.Key)
    case {'return'}
        if ~strcmp(get(obj,'UserData'),'Cancel')
            set(gcbf,'UserData','OK');
            uiresume(gcbf);
        else
            delete(gcbf)
        end
    case 'escape'
        delete(gcbf)
end
end

function kpf_confirmpass(obj,evd,varargin)
Data     = varargin{1};
passedit = Data.edit{end-1};
if numel(obj.Password) >= numel(passedit.Password) || all(obj.BorderColor == [0 1 0])
    if strcmp(obj.Password, passedit.Password)
        green                = [0 1 0];
        obj.BorderColor      = green;
        passedit.BorderColor = green;
        set(Data.button(1), 'Enable','on');
    else
        red                  = [1 0 0];
        obj.BorderColor      = red;
        passedit.BorderColor = red;
        set(Data.button(1), 'Enable','off');
    end
end
end

function clb_button(obj, evd) 
if ~strcmp(get(obj,'UserData'),'Cancel')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end
end

% Show/hide password
function clb_checkbox(obj,evd,varargin)
Data = varargin{1};
isChecked = get(obj,'Value');
for ii = 1:numel(Data.edit)
    editbox = Data.edit{ii};
    if isa(editbox,'passfield')
        if isChecked
            editbox.show;
        else
            editbox.hide;
        end
    end
end
end

% Horizontal resize
function doResize(fh, evd, varargin) 
Data      = varargin{1};
resetPos  = false;

FigPos    = get(fh,'Position');
FigWidth  = FigPos(3);
FigHeight = FigPos(4);

% Keep min width
widthDiff = Data.FigMinWidth - FigWidth;
if widthDiff >= 1
    FigWidth  = Data.FigMinWidth;
    FigPos(3) = Data.FigMinWidth;
    resetPos = true;
end

% Resize edit fields
for ii = 1:length(Data.edit)
    EditPos    = get(Data.edit{ii},'Position');
    EditPos(3) = FigWidth - 10;
    set(Data.edit{ii},'Position',EditPos);
end

% Reposition buttons
ButtonPos    = get(Data.button(1),'Position');
ButtonPos(1) = FigWidth - Data.OkFromRight;
set(Data.button(1),'Position',ButtonPos);
ButtonPos    = get(Data.button(2),'Position');
ButtonPos(1) = FigWidth - Data.CancelFromRight;
set(Data.button(2),'Position',ButtonPos);

% Keep height fixed
heightDiff = abs(FigHeight - Data.FigHeight);
if heightDiff >= 1
    FigPos(4) = Data.FigHeight;
    resetPos  = true;
end

if resetPos, set(fh,'Position',FigPos); end
end

% Parse arguments to main function
function [u, c, s] = getUItype(type)
ucs = false(1,3);
if iscellstr(type)
    validoptions = {'UsernameField','ConfirmPass','ShowHideCheckBox'};
    for ii = 1:numel(type)
        n = numel(type{ii});
        tmp = strncmpi(type{ii}, validoptions, n);
        if ~any(tmp)
            warning('passdlg:unrecognizeType','Unrecognized option ''%s''.',type{ii})
            continue
        end
        ucs = ucs | tmp;
        if all(ucs), break, end
    end
elseif ischar(type) && isrow(type)
    ucs = any(bsxfun(@eq, 'ucs',type'),1);
end
u = ucs(1);
c = ucs(2);
s = ucs(3);
end

% Retrieve hardcoded defaults
function s = getDefaults
s.FigColor = get(0,'DefaultFigureColor');
s.TextInfo = struct('Units','pixels',...
    'FontSize'             ,8,...
    'FontWeight'           ,'normal',...
    'HorizontalAlignment'  ,'left',...
    'HandleVisibility'     ,'callback',...
    'VerticalAlignment'    , 'bottom',...
    'BackgroundColor'      ,s.FigColor);
s.BtnInfo = struct('Units', 'pixels',...
    'FontSize'             ,8,...
    'FontWeight'           ,'normal',...
    'HorizontalAlignment'  ,'center',...
    'HandleVisibility'     ,'callback',...
    'Style'                ,'pushbutton',...
    'BackgroundColor'      , s.FigColor);
s.EdInfo = struct('Units', 'pixels',...
    'FontSize'             ,8,...
    'FontWeight'           ,'normal',...
    'HorizontalAlignment'  ,'left',...
    'HandleVisibility'     ,'callback',...
    'Style'                ,'edit',...
    'BackgroundColor'      ,[1,1,1]);
s.CbInfo = struct('Units', 'pixels',...
    'FontSize'             ,8,...
    'FontWeight'           ,'normal',...
    'HorizontalAlignment'  ,'left',...
    'HandleVisibility'     ,'callback',...
    'Style'                ,'checkbox',...
    'BackgroundColor'      , s.FigColor);
end