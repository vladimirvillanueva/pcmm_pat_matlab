function ax = plot_var(TT,variableName1,ylabel_comp,ylimits,variableName2,variableName3)
%% Function that plot variables from a timetable based on variablename.
    
    if nargin < 1 || isempty(TT)
            error(['No timetable selected. ' ...
                'Please provide a valid timetable.']);
    end
    % Find index of a variable (e.g., 'Humidity')
    index1 = find(strcmp(TT.Properties.VariableNames, ...
        string(variableName1)));
   
    hold on
    % Variable 1
    plot(TT.Time,TT{:,index1},'-k',"DisplayName", ...
        TT.Properties.VariableDescriptions{:,index1}(end-2:end));

    if nargin < 3
        ylabel(TT.Properties.VariableDescriptions{:,index1})
    end
    
     if isempty(ylimits)
        mean_pv = mean(TT{:,index1});
        std_pv  = std(TT{:,index1});
        upper_ylim = mean_pv  + 3*std_pv;
        bottom_ylim = mean_pv - 3*std_pv;
        % Avoid negative values
        if bottom_ylim  < 0
            bottom_ylim = 0;
        end
        ylim([bottom_ylim upper_ylim]);
     else
         ylim(ylimits);
     end
    % Variable 2
    if nargin > 4
    index2 = find(strcmp(TT.Properties.VariableNames, ...
        string(variableName2)));
    plot(TT.Time,TT{:,index2},'-r',"DisplayName", ...
        TT.Properties.VariableDescriptions{:,index2}(end-2:end));
    end
    % Variable 3
    if nargin > 5
    index3 = find(strcmp(TT.Properties.VariableNames, ...
        string(variableName3)));
    plot(TT.Time,TT{:,index3},'-m',"DisplayName", ...
        TT.Properties.VariableDescriptions{:,index3}(end-2:end));
    end
    ylabel(ylabel_comp);
    legend("Location","southeastoutside");    
    hold off
    ax = gca;
end
