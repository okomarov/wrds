classdef wrds < handle
    properties
        Dir
    end
    properties
        ssh2obj
    end
    methods
        function obj = wrds(host, username, pass, port)
            if nargin < 1 || isempty(host), host = 'wrds.wharton.upenn.edu';    end
            if nargin < 4 || isempty(port), port = 22;                          end
            
            %
            obj.ssh2obj = ssh2_config(host, username, pass, port);
            obj.Dir = regexprep(fileparts(mfilename('fullpath')),'\@wrds','');
        end
        
        
        
    end
end

