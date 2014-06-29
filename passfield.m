classdef passfield < hgsetget
    
    properties
        BackgroundColor = [0.941176 0.941176 0.941176]
        Callback
        CData
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
        
        function set.BackgroundColor(obj, val)
            obj.BackgroundColor = val;
            % Update java peer
            peer     = get(obj, 'jpeer');
            newColor = java.awt.Color(val);
            peer.setBackground(newColor);
        end
        
        function set.FontSize(obj, val)
            obj.FontSize = val;
            % Update java peer
            peer    = get(obj, 'jpeer');
            newFont = peer.getFont.deriveFont(val);
            peer.setFont(newFont);
        end
        
        function set.ForegroundColor(obj, val)
            obj.ForegroundColor = val;
            % Update java peer
            peer     = get(obj, 'jpeer');
            newColor = java.awt.Color(val(1),val(2),val(3));
            peer.setForeground(newColor);
        end
        
        function set.HorizontalAlignment(obj, val)
            accepted = {'left','center','right'};
            idx      = strncmpi(val, accepted, numel(val));
            val      = accepted{idx};
            obj.HorizontalAlignment = val;
            % Update java peer
            peer                   = get(obj, 'jpeer');
            newHorizontalAlignment = javax.swing.JTextField.(upper(val));
            peer.setHorizontalAlignment(newHorizontalAlignment);
        end
        
    end
    
    methods (Access = private)
        
        
    end
end