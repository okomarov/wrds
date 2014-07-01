classdef passfield < hgsetget
    
    properties
        BackgroundColor
        BeingDeleted = 'off'
        BusyAction = 'queue'
        ButtonDownFcn
        Callback
        CreateFcn
        DeleteFcn
        EchoChar = char(9679);
        Enable = 'on'
        FontSize = 8
        ForegroundColor = [0 0 0]
        HandleVisibility = 'on'
        HitTest = 'on'
        HorizontalAlignment = 'center'
        Interruptible = 'on'
        KeyPressFcn
        Parent
        Password
        Position
        Selected = 'off'
        Style = 'password'
        Tag
        TooltipString
        UIContextMenu
        Units = 'pixels'
        UserData
        Value = 0
        Visible = 'on'

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
            hdoc    = handle(obj.hjpeer.getDocument);
            lstfun  = @(hdoc,evt) obj.updatePassword();
            hlst(1) = handle.listener(hdoc,'insertUpdate',lstfun);
            hlst(2) = handle.listener(hdoc,'removeUpdate',lstfun);
            setappdata(obj.hjpeer,'PasswordListener',hlst);
            
            % Embed into the graphic container
            [~, obj.hgcont] = javacomponent(obj.hjpeer);

            % Update default properties
%             get(0,'DefaultUicontrolBackgroundcolor');
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
            peer.KeyPressedCallback = @(src,event) obj.KeyPressFcnBridge(src,event,fcn);
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
        
        function set.Visible(obj,val)
            % Update hg container 
            container         = get(obj,'hgcont');
            container.Visible = val;
            % Update property
            obj.Visible = val;
        end
    end
    
    methods (Access = private)
        function updatePassword(obj)
            % Listener's callback to updat the Password property from the Java peer
            pass         = obj.hjpeer.getPassword;
            obj.Password = reshape(pass,1,numel(pass));
        end
        
        function KeyPressFcnBridge(obj, src, jevent, fcn)
            % Bridge Java event into Matlab one
            % TODO: create a proper private event.EventData and add event to this object
            hjevent = handle(jevent,'callbackproperties');
            mevent = struct('Character', ...
                            'Modifier' , ...
                            'Key'      , ...
                            'Source'   , ...
                            'EventName', 'KeyPressed');
            hgfeval(fcn, obj, mevent)
        end
            
    end
end