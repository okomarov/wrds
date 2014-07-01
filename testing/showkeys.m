function showkeys
   figure('NumberTitle','off','Menubar','none',...
       'Name',...
       'Press keys to put callback data in Command Window',...
       'Position',[560 728 560 200])
   uicontrol('style','edit','KeyPressFcn',@dispdata)

        function dispdata(src,callbackdata)
            disp(callbackdata)
        end
end