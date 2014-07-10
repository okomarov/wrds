classdef passfield < matlab.System % hgsetget
    
    properties
        BackgroundColor
        BeingDeleted = 'off'
        BusyAction = 'queue'
        ButtonDownFcn
        Callback
        EchoChar = char(9679);
        Enable = 'on'
        FontSize
        ForegroundColor
        %        HandleVisibility = 'on'
        HitTest = 'on'
        HorizontalAlignment = 'left'
        Interruptible = 'on'
        KeyPressFcn
        Parent@handle
        Password@string
        Position
        Selected = 'off'
        Tag@string
        TooltipString@string
        UIContextMenu@matlab.ui.container.ContextMenu
        Units = 'pixels'
        UserData
        Visible = 'on'
    end
    
    properties(SetAccess=private)
        BeingDeleted = 'off'
    end
    
    properties (Hidden,Transient)
        HorizontalAlignmentSet = matlab.system.StringSet({'left','center','right'});
    end
    
    
    properties (Constant)
        Style = 'password'
    end
    
    properties %(Access = private, Hidden = true)
        hjpeer
        hgcont
    end
    methods
        function obj = passfield(varargin)
            % PASSFIELD Create a password field
            
            % Create java peer
            obj.hjpeer = handle(javaObjectEDT('javax.swing.JPasswordField'), 'CallbackProperties');
            
            % LISTENERS
            % -------------------------------------------------------------
            % Password (hjpeer -> obj)
            % Propagate destructor of the container to the obj
            addlistener(obj.hgcont,'ObjectBeingDestroyed',@(src,evt) obj.delete);
            hdoc    = handle(obj.hjpeer.getDocument);
            lstfun  = @(hdoc,evt) obj.updatePassword();
            hlst(1) = handle.listener(hdoc,'insertUpdate',lstfun);
            hlst(2) = handle.listener(hdoc,'removeUpdate',lstfun);
            setappdata(obj.hjpeer,'PasswordListener',hlst);
            
            % Embed into the graphic container
            [~, obj.hgcont] = javacomponent(obj.hjpeer);
            
            % Update default properties
            %get(0,'DefaultUicontrolBackgroundcolor');
            %get(0,'DefaultUicontrolFontSize');
        end
        function delete(obj)
            obj.BeingDeleted = 'on';
            if ishghandle(obj.hgcont) 
               delete(obj.hgcont)
            end
            delete@matlab.System(obj)
        end
            
       
        
        % =========================================================================
        % SET
        % =========================================================================
        function set.BackgroundColor(obj, val)
            % Update java peer
            peer     = get(obj, 'hjpeer');
            newColor = java.awt.Color(val(1),val(2),val(3));
            peer.setBackground(newColor);
            % Update property
            obj.BackgroundColor = val;
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
        
        function set.FontSize(obj, val)
            % Update java peer
            peer    = get(obj, 'hjpeer');
            newFont = peer.getFont.deriveFont(val);
            peer.setFont(newFont);
            % Update property
            obj.FontSize = val;
        end
        
        function set.ForegroundColor(obj, val)
            % Update java peer
            peer     = get(obj, 'hjpeer');
            newColor = java.awt.Color(val(1),val(2),val(3));
            peer.setForeground(newColor);
            % Update property
            obj.ForegroundColor = val;
        end
        
        function set.HorizontalAlignment(obj, val)
            %             accepted = {'left','center','right'};
            %             idx      = strncmpi(val, accepted, numel(val));
            %             val      = accepted{idx};
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
    
    methods (Access = private)
        
        function callbackBridge(obj, src, jevent, fcn)
            % Java 2 matlab event conversion
            switch char(jevent.getClass.getName)
                case 'java.awt.event.KeyEvent'
                    mevent = obj.j2m_KeyEvent(jevent);
                case 'java.awt.event.ActionEvent'
                    % fill in
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
                            'Key'      , key,...
                            'Source'   , obj,...
                            'EventName', 'KeyPress');
            mevent.Modifier = modifiers; % Bug in matlab, need to add separatly if empty cell
        end
        
        function showUIContextMenu(obj, src, evt)
%         if ~ishghandle(val) || ~strcmpi(val.Type,'uicontextmenu')
%             error('passfield:printEchoChar','Not a context menu object.')
%         end
            if evt.getButton == 3
                obj.UIContextMenu.Visible = 'on';
            end
        end
        
        function updatePassword(obj)
            % Listener's callback to updat the Password property from the Java peer
            pass         = obj.hjpeer.getPassword;
            obj.Password = reshape(pass,1,numel(pass));
        end
        
    end
end