function output = fillRow(output, i, expr, nonZeros, channels, stateList, timeData, letters, timeLong, posLong, rowLong, filenames)
        out = regExAnalyzer2(expr, nonZeros, letters, timeData, timeLong, posLong, rowLong, filenames); %function which does the searching
        [~,output(i).interpretation] = parseTransition(expr, channels, stateList);
        try
            [output(i).statesSummary,~] = parseTransition(expr, channels, stateList);
        catch
        end
        output(i).count = out.numEvents;
        output(i).meanLength = mean(out.timeLengths);
        output(i).eventList = out.eventList;
        output(i).timeLengths = out.timeLengths; %how long was each event

        if ~isfield(out,'filenames') %if name data exists
            out.filenames = out.timeLengths.*0;
        end

        if out.numEvents>0 %create a detailed table and store it in its own field
            
        output(i).table = table(output(i).eventList,output(i).timeLengths,...
            out.timeList,out.timeDiff,out.begin,out.last,out.filenames,'VariableNames',...
            {'Events','Total_Duration','Time_Points','Delta_t','Time_first','Time_last','File'});
            try 
                output(i).excel = cell2mat(out.timeDiff);
            catch
            end
        end
        %the next line uses lookaround to search for the all 'gaps' which
        %are periods of ground state immediately preceded and followed by
        %the type of event which we are currently looking at.
        expr2 = ['(?<=(' output(i).expr{:}(2:end-1) '))_  _(?=' output(i).expr{:}(2:end-1) ')'];
        out = regExAnalyzer2(expr2, nonZeros, letters, timeData, timeLong, posLong, rowLong, filenames); %again, get information about any gaps
        output(i).count_Gaps = out.numEvents;
        output(i).meanLength_Gaps = mean(out.timeLengths);
        output(i).timeLengths_Gaps = out.timeLengths;

        if ~isfield(out,'filenames')
            out.filenames = out.timeLengths.*0;
        end

        if out.numEvents>0
            output(i).table_Gaps = table(output(i).timeLengths_Gaps,...
                out.timeList,out.timeDiff,out.begin,out.last,out.filenames,'VariableNames',...
                {'Total_Duration','Time_Points','Delta_t','Time_first','Time_last','File'});
        end
end