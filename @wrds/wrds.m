classdef wrds < handle
    % WRDS Connect to Wharton Reasearch Data Services 
    %
    %   High level Matlab API that interacts with the WRDS Unix server 
    %   and the SAS data sets through SSH2.
    %   
    %   Requirements:
    %       - An account with WRDS of the type that admits SSH connections. 
    %         See <a href="http://wrds-web.wharton.upenn.edu/wrds/support/Additional%20Support/Account%20Types.cfm">account types</a> for details.
    %       - <a href="matlab: disp(['Java enabled: ' isempty(javachk('jvm'))+'0'])">Java enabled</a>
    %
    %   Syntax:
    %       WRDS(USERNAME, PASS) Supply USERNAME and PASS as strings. 
    %
    %       WRDS(..., HOST, PORT) Optionally, provide HOST and/or PORT 
    %                             which are respectively defaulted to 
    %                             'wrds.wharton.upenn.edu' and 22. 
    %   
    %
    %       W = WRDS(...) Connection to the server
    %
    %
    %   Examples:
    %       w = username('olegkoma','forgiveMeIfIDontTellYou');
    %       w.cmd('echo "Hello World!"')
    %   
    % See also: SSH2
    
    
    properties
        Verbose@logical = false;            % Toggle verbosity
    end
    properties %(Access=private)
        SSH2conn                            % SSH2 connection
        Fullpath                            % Full path to wrds folder
    end
    
    methods
        function obj = wrds(username, pass, host, port)
            % WRDS Constructor
             
            % Only check jvm, other errors delegated
            error(javachk('jvm'))
            
            % Defaults initialization
            if nargin < 3 || isempty(host), host = 'wrds.wharton.upenn.edu';    end
            if nargin < 4 || isempty(port), port = 22;                          end
            
            % Establish ssh2 connection
            obj.SSH2conn = ssh2_config(host, username, pass, port);
            
            % Record where the wrds path is
            obj.Fullpath = regexprep(fileparts(mfilename('fullpath')),'\@wrds','');
        end
        
        function obj = cmd(obj, cmdstr)
            % CMD Execute command on UNIX shell
            
            if obj.Verbose, fprintf('Executing command.\n'), end
            obj.SSH2conn = ssh2_command(obj.SSH2conn,cmdstr,obj.Verbose);
        end
           
        function obj = SCPget(obj, remotefile, outfile)
            % SCPget Download file from remote host
            
            if nargin < 3 || isempty(outfile)
                outfile = fullfile(obj.Fullpath,'data\');
            end
            
            % Process paths
            [rpath, rfname, rext] = fileparts(remotefile);
            [lpath, lfname, lext] = fileparts(outfile);
            if isempty(lpath)
                lpath = fullfile(obj.Fullpath,'data\');
            end
            if isempty(lfname)
                lfname = rfname;
                lext   = rext;
            end
                        
            if obj.Verbose, fprintf('Downloading file.\n'), end
            
            % Download file
            obj.SSH2conn = scp_get(obj.SSH2conn, [rfname, rext], lpath, rpath);
            
            % Rename
            if ~strcmp(lfname, rfname)
                movefile(fullfile(lpath, [rfname, rext]), fullfile(lpath, [lfname, lext]))
            end
        end
        
        function obj = close(obj)
            if obj.Verbose, fprintf('Closing connection.\n'), end
            obj.SSH2conn = ssh2_close(obj.SSH2conn);
        end
        function delete(obj)
            close(obj);
        end
    end
end