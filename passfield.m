classdef passfield < hgsetget
    
    properties
        BackgroundColor = [0.941176 0.941176 0.941176]
        Callback
        CData
        EchoChar = char(9679);
        Enable = 'on'
        Extent = [0 0 4 4]
        FontSize = 8
        FontUnits = 'points'
        ForegroundColor = [0 0 0]
        HorizontalAlignment = 'center'
        KeyPressFcn
        Position = [20 20 60 20]
        Style = 'password'
        TooltipString
        Units = 'pixels'
        Value = 0
        BeingDeleted = 'off'
        ButtonDownFcn
        CreateFcn
        DeleteFcn
        BusyAction = 'queue'
        HandleVisibility = 'on'
        HitTest = 'on'
        Interruptible = 'on'
        Parent
        Selected = 'off'
        Tag
        UIContextMenu
        UserData
        Visible = 'on'
    end
    
    properties (Access = private, Hidden = true)
        jpeer
        hobj
    end
    methods
        function obj = passfield(varargin)
            % PASSFIELD Create a password field 
            
            % Create java peer
            obj.jpeer = handle(javaObjectEDT('javax.swing.JPasswordField'), 'CallbackProperties');
            
            % Set default properties
            obj.jpeer.setBackground(java.awt.Color(0.941176,0.941176,0.941176));
            
            % Embed into the graphic container
            [~, obj.hobj] = javacomponent(obj.jpeer);
        end
        
% =========================================================================
% SET 
% =========================================================================
        function set.BackgroundColor(obj, val)
            % Update java peer
            peer     = get(obj, 'jpeer');
            newColor = java.awt.Color(val);
            peer.setBackground(newColor);
            % Update property
            obj.BackgroundColor = val;
        end
        
        function set.EchoChar(obj, val)
            if ~isscalar(val) || ~isstrprop(val,'print')
                error('passfield:printEchoChar','The ''EchoChar'' should a graphic character.')
            end
            % Update java peer
            peer = get(obj, 'jpeer');
            peer.setEchoChar(val);
            % Update property
            obj.EchoChar = val;
        end
        
        function set.FontSize(obj, val)
            % Update java peer
            peer    = get(obj, 'jpeer');
            newFont = peer.getFont.deriveFont(val);
            peer.setFont(newFont);
            % Update property
            obj.FontSize = val;
        end
        
        function set.ForegroundColor(obj, val)
            % Update java peer
            peer     = get(obj, 'jpeer');
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
            peer                   = get(obj, 'jpeer');
            newHorizontalAlignment = javax.swing.JTextField.(upper(val));
            peer.setHorizontalAlignment(newHorizontalAlignment);
            % Update property
            obj.HorizontalAlignment = val;
        end
        
    end
    
    methods (Access = private)
        
        
    end
end