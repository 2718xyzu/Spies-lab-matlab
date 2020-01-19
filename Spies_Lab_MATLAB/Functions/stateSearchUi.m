function [stateText] = stateSearchUi(channels,stateList)
    dropDownOpt = cell([1 channels]);
    dropDowns = cell([1 channels]);
    channel = 1;
    for i = 1:channels
        for j = 1:stateList(i)
            dropDownOpt{j} = num2str(j);
        end
    end

    btn = uicontrol('Style', 'pushbutton', 'String', 'Search',...
            'Position', [230 10 40 30],...
            'UserData', 1,'Callback', @buttonCallback); 
        
    dropdown = uicontrol('Style', 'popupmenu', 'String', dropDownOpt,  ...
            'Position', [10 10 80 30], 'Callback', @buttonCallback);
        
    textEdit = uicontrol('Style', 'edit', 'String', 'States', ...
            'Position', [90 10 120 30], 'Callback', @buttonCallback);
        
    textStatic = uicontrol('Style', 'text', 'String', ['Select the ' ...
            'channel you wish to search within, and enter a comma-' ...
            'separated list of the states transitioned between'], ...
            'Position', [10 45 200 40]);
        
        fig = gcf;
        uiwait(fig);
    function buttonCallback(hObject,data)
        if isprop(hObject, 'Style') && strcmpi(get(hObject, 'Style'),'pushbutton')
            stateSearch = zeros([1 channels]);
            for k = 1:channels
                stateSearch(k) = get(dropDowns{k},'Value');
            end
            disp(channel); disp(transitionList);
            close(gcf)
        end
        
    end
    
    
end