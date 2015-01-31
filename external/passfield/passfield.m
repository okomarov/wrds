classdef passfield < hgsetget
% PASSFIELD Create a password field
%
%   PASSFIELD(Name, Value) Supports Name/Value pair syntax as in
%                          uicontrol(). 
%                          Valid names of properties are:
%                           * 'EchoChar'  -  character masking the password
%                           * 'Password'  -  password in plain text
%                           * Some <a href="matlab: doc uicontrol-properties">uicontrol properties</a>
%  
% Warning: 
%   This code heavily relies on undocumented and unsupported Matlab functionality.
%   Use at your own risk!
%
% Additional features:
%   - <a href="matlab: web('https://github.com/okomarov/passfield/issues','-browser')">Submit/check issues on Github</a>
%   - <a href="matlab: web('http://undocumentedmatlab.com/','-browser')">Undocumented Matlab</a>
% 
% See also: PASSDLG, UICONTROL, JAVACOMPONENT

% Author: Oleg Komarov (oleg.komarov@hotmail.it) 
% Tested on R2014a Win7 64bit
% 2014 Jul 07 - created
% 2014 Sep 21 - added FontName property
            
    properties
        BackgroundColor                                     % Background color as short/long name or RGB triplet
        BorderColor = [171,173,179]                         % Border color as short/long name or RGB triplet
%         BusyAction = 'queue'
%         ButtonDownFcn
        Callback                                            % Perform on action    
        EchoChar = char(9679);                              % Character displayed in the field
%         Enable = 'on'
        FontName                                            % Font name for displaying string (affects size)
        FontSize                                            % Font size for displaying string
        ForegroundColor                                     % Text color as short/long name or RGB triplet
%         HandleVisibility = 'on'
%         HitTest = 'on'
        HorizontalAlignment = 'left'                        % Alignment for password string
        IsMasked = true;                                    % Password is masked with EchoChar
%         Interruptible = 'on'
        KeyPressFcn                                         % Key press callback function
        Password@char                                       % Password string in plain text
        Position                                            % Size and location of the password field
%         Selected = 'off'
        Tag@char                                            % Identifier
        TooltipString@char                                  % Tooltip text
        UIContextMenu@matlab.ui.container.ContextMenu       % Context menu associated with the field
        Units = 'pixels'                                    % Units of measurement
        UserData                                            % Data associated with the field
        Visible = 'on'                                      % Visibility of the field
    end
    
    properties(Hidden,SetAccess=private)
        Parent
    end
    
    properties(SetAccess=private)
        BeingDeleted = 'off'                                % Indicator that MATLAB is deleting the field
    end
    
    properties (Constant)
        Style = 'password'                                  % Style of the uicontrol
    end
    
    properties (Access = private,Hidden)
        hjpeer
        hgcont
        jFontSize
    end
    
    methods
        function obj = passfield(varargin)
            % Constructor
           
            % Create java peer
            obj.hjpeer = handle(javaObjectEDT('javax.swing.JPasswordField'), 'CallbackProperties');
            
            % Get parent
            pos = find(~cellfun('isempty',strfind(varargin(1:2:end), 'Parent')));
            if isempty(pos)
                parent = gcf;
            else
                parent = varargin{pos+1};
            end
            
            % Embed into the graphic container
            [~, obj.hgcont] = javacomponent(obj.hjpeer,[],parent);
            obj.hgcont      = handle(obj.hgcont); 
            
            % Destructor listener (hjcont -> obj)
            addlistener(obj.hgcont,'ObjectBeingDestroyed',@(src,evt) obj.delete);
            
            % Password listener (hjpeer -> obj)
            hdoc    = handle(obj.hjpeer.getDocument);
            lstfun  = @(hdoc,evt) obj.updatePassword();
            hlst(1) = handle.listener(hdoc,'insertUpdate',lstfun);
            hlst(2) = handle.listener(hdoc,'removeUpdate',lstfun);
            setappdata(obj.hjpeer,'PasswordListener',hlst);
            
            % Retrieve default properties
            default  = {'BackgroundColor','FontSize','FontName','ForegroundColor'};
            idx      = ismember(default,varargin(1:2:end));
            nameval  = [default(~idx); get(0, strcat('DefaultUicontrol', default(~idx)))];
            varargin = [varargin, nameval(:)'];
            
            % Set name/value pairs
            for ii = 1:2:numel(varargin)
                set(obj,varargin{ii}, varargin{ii+1});
            end
        end
        
        % Top to bottom delete
        function delete(obj)
            obj.BeingDeleted = 'on';
            if ishghandle(obj.hgcont) 
               delete(obj.hgcont)
            end
            delete@hgsetget(obj)
        end
            
        % Hide password
        function hide(obj)
            if ~obj.IsMasked
               obj.EchoChar = obj.EchoChar;
               obj.IsMasked = true;
            end
        end 
        
        % Show password
        function show(obj)
            if obj.IsMasked
                val = char(0);
                % Update java peer only
                peer = get(obj, 'hjpeer');
                peer.setEchoChar(val);
                obj.IsMasked = false; 
            end
        end 
        
        % =========================================================================
        % GET
        % =========================================================================
        
        % Explicit get.Password from java peer or obj.Password is executed
        % BEFORE the listener updates obj.Password
        function val = get.Password(obj)
            val = reshape(obj.hjpeer.getPassword, 1, numel(obj.hjpeer.getPassword));
        end
        
        % =========================================================================
        % SET
        % =========================================================================
        function set.BackgroundColor(obj, val)
            if ischar(val), val = cname2rgb(val); end
            % Update java peer
            peer     = get(obj, 'hjpeer');
            newColor = java.awt.Color(val(1),val(2),val(3));
            peer.setBackground(newColor);
            % Update property
            obj.BackgroundColor = val;
        end
        
        function set.BorderColor(obj, val)
            if ischar(val), val = cname2rgb(val); end
            % Update java peer
            peer      = get(obj, 'hjpeer');
            newColor  = java.awt.Color(val(1),val(2),val(3));
            newBorder = javax.swing.BorderFactory.createLineBorder(newColor);
            peer.setBorder(newBorder);
            % Update property
            obj.BorderColor = val;
        end
        
        function set.Callback(obj,fcn)
            % Update java peer
            peer                         = get(obj, 'hjpeer');
            peer.ActionPerformedCallback = @(src,event) obj.callbackBridge(src,event,fcn);
            % Update property
            obj.Callback = fcn;
        end
        
        function set.EchoChar(obj, val)
            if ~isscalar(val) || ~isstrprop(val,'print')
                error('passfield:printEchoChar','The ''EchoChar'' should a graphic character.')
            end
            % Update java peer
            peer = get(obj, 'hjpeer');
            peer.setEchoChar(val);
            % Update property
            obj.EchoChar = val;
        end
        
        function set.FontName(obj, val)
            fontsize = get(obj, 'jFontSize');
            % Update java peer
            peer    = get(obj, 'hjpeer');
            newFont = java.awt.Font(val, 0, fontsize);
            peer.setFont(newFont);
            % Update property
            obj.FontName = val;
        end
        
        function set.FontSize(obj, val)
            % Set jFontSize
            fontsize = com.mathworks.mwswing.FontSize.createFromPointSize(val).getJavaSize;
            set(obj,'jFontSize',fontsize);
            % Update java peer
            peer    = get(obj, 'hjpeer');
            newFont = peer.getFont.deriveFont(fontsize);
            peer.setFont(newFont);
            % Update property
            obj.FontSize = val;
        end
        
        function set.ForegroundColor(obj, val)
            if ischar(val), val = cname2rgb(val); end
            % Update java peer
            peer     = get(obj, 'hjpeer');
            newColor = java.awt.Color(val(1),val(2),val(3));
            peer.setForeground(newColor);
            % Update property
            obj.ForegroundColor = val;
        end
        
        function set.HorizontalAlignment(obj, val)
            accepted = {'left','center','right'};
            idx      = strncmpi(val, accepted, numel(val));
            val      = accepted{idx};
            % Update java peer
            peer                   = get(obj, 'hjpeer');
            newHorizontalAlignment = javax.swing.JTextField.(upper(val));
            peer.setHorizontalAlignment(newHorizontalAlignment);
            % Update property
            obj.HorizontalAlignment = val;
        end
        
        function set.KeyPressFcn(obj,fcn)
            % Update java peer
            peer                    = get(obj, 'hjpeer');
            peer.KeyPressedCallback = @(src,event) obj.callbackBridge(src,event,fcn);
            % Update property
            obj.KeyPressFcn = fcn;
        end
        
        function set.Position(obj,val)
            % Update hg container
            container          = get(obj,'hgcont');
            container.Position = val;
            % Update property
            obj.Position = val;
        end
        
        function set.TooltipString(obj,val)
            % Update java peer
            peer = get(obj, 'hjpeer');
            peer.setToolTipText(val);
            % Update property
            obj.TooltipString = val;
        end
        
        function set.UIContextMenu(obj,val)
            % Update property
            obj.UIContextMenu = val;
            % Update java peer
            peer = get(obj, 'hjpeer');
            peer.MouseClickedCallback = @(src,evt) obj.showUIContextMenu(src,evt);
        end
        
        function set.Visible(obj,val)
            % Update hg container
            container         = get(obj,'hgcont');
            container.Visible = val;
            % Update property
            obj.Visible = val;
        end
    end

% =========================================================================
% PRIVATE
% =========================================================================
    methods (Access = private)
        
        function callbackBridge(obj, src, jevent, fcn)
            % Java 2 matlab event conversion
            switch char(jevent.getClass.getName)
                case 'java.awt.event.KeyEvent'
                    mevent = obj.j2m_KeyEvent(jevent);
                case 'java.awt.event.ActionEvent'
                    % TO DO: Action event bridge
                    mevent = jevent;
                otherwise
                    mevent = jevent;
            end
            % Execute function associated with the callback
            hgfeval(fcn, obj, mevent)
        end

        function mevent = j2m_KeyEvent(obj,jevent)
            % TODO: create a proper private event.EventData and add event to this object
            key = lower(char(jevent.getKeyText(jevent.getExtendedKeyCode)));
            modifiers = lower(char(jevent.getModifiersExText(jevent.getModifiersEx)));
            if isempty(modifiers),
                modifiers = cell(1,0);
            else
                modifiers = regexp(modifiers,'+','split');
            end
            if jevent.isActionKey
                keychar = '';
            else
                keychar = char(jevent.getKeyChar);
            end
            mevent = struct('Character', keychar,...
                            'Modifier' , {modifiers},...
                            'Key'      , key,...
                            'Source'   , obj,...
                            'EventName', 'KeyPress');
        end
        
        function showUIContextMenu(obj, src, evt)
            if evt.getButton == 3
                obj.UIContextMenu.Visible = 'on';
            end
        end
        
        function updatePassword(obj)
            % Listener's callback to updat the Password property from the Java peer
            obj.Password = obj.hjpeer.getPassword;
        end
        
    end
    
    % Hide superclass methods
    methods (Hidden)
        function ge(~),  end
        function gt(~),  end
        function le(~),  end
        function lt(~),  end
    end
end