function figures_pcmm = plot_PAT_Trends(tt,eln_number,compound,config_table,figure_title,HPLC_data,campaign)
%% Plot Trends from PAT5 wet granulation by Vladimir Villanueva-Lopez
% tt Timetable
% eln_number
% compound
% config_table
if nargin < 1 || isempty(tt)
            error(['No timetable selected. ' ...
                'Please provide a valid timetable.']);
end
if nargin < 2 || isempty(eln_number)
            error(['No eLN number provided. ' ...
                'Please provide a valid eLN number.']);
end

if nargin < 3 || isempty(config_table)
            error(['No configuration file selected. ' ...
                'Please provide a valid configuration file.']);
end

% if ~isempty(HPLC_data)
%     istable(HPLC_data)
%              error(['HPLC data provided is not valid. ' ...
%                  'Please provide a valid Timetable.']);
% end
%% campaign
campaign = string(campaign);
%% Find Unique dates
campaigns_date = string(unique(datetime(year(tt.Time), month(tt.Time), day(tt.Time))));
%% Compound
if isempty(compound)
compound = [];
end 
%% eLN Number
if isempty(eln_number)
eln_number = [];
end 
%% ss_pred = API_granules_feeder_CMT_RTD_Comp_PV* 100/api_0
ss_pred = tt.x1430ME*100./tt.x1317ME; 
%% Create a title for the plots
if isempty(figure_title)
figure_title = string(eln_number) + " : "+ compound +" - " + "PCMM Campaign : " + campaign ...
    +" - Date: " + campaigns_date ;
end
figure_name_string = strjoin([campaign,campaigns_date],'_');

%% Store of the figures
figures_pcmm = gobjects(5,1);
%% Figure 1: Feeders 
feeders = config_table(categorical(config_table.Figure) =="Feeders",:);
figures_pcmm(1) = figure("Name",strjoin(["Feeders",figure_name_string],"_"));
f1_axes = gobjects(6,1);
tiledlayout(3,2)
% Feeders Data
for idx = 1:6
        f1_axes(idx) = nexttile;
    if mod(idx,2)==0  % even index
        ylimits = get(f1_axes(idx-1), 'YLim');
        plot_var(tt,feeders.Variable1Name(idx),...
        feeders.Label(idx),ylimits,feeders.Variable2Name(idx));  
    else % odd index
         plot_var(tt,feeders.Variable1Name(idx),...
         feeders.Label(idx),[],feeders.Variable2Name(idx));
    end
    if idx == 5 || idx == 6
        xlabel('Time (HH:MM)')
    end
end
sgtitle(figure_title)
linkaxes(f1_axes,'x')
xlim(f1_axes,"tight")
%% Figure 2: CMT2
CMT2 = config_table(categorical(config_table.Figure) =="CMT2",:);
figures_pcmm(2)= figure("Name",strjoin(["CMT2",figure_name_string],"_"));
f2_axes = gobjects(4,1);
tiledlayout(4,1)
for idx = 1:4
    f2_axes(idx) = nexttile;
    plot_var(tt,CMT2.Variable1Name(idx),CMT2.Label(idx),[], ...
        CMT2.Variable2Name(idx))
end
xlabel('Time (HH:MM)')
sgtitle(figure_title)
linkaxes(f2_axes,'x');xlim(f2_axes,"tight")
%% Figure 3: PAT5
PAT5 = config_table(categorical(config_table.Figure) =="PAT5",:);
figures_pcmm(3)  = figure("Name",strjoin(["PAT5",figure_name_string],"_"));
f3_axes = gobjects(5,1);
tiledlayout(5,1)
for idx = 1:5
    f3_axes(idx) = nexttile;
    if idx == 1
        % Plot CLS and Hybrid Soft-Sensor
        plot_var(tt,PAT5.Variable1Name(idx),PAT5.Label(idx),[80 120], ...
        PAT5.Variable2Name(idx))
        hold on
        % Plot Soft-Sensor
        plot(tt.Time,ss_pred,'-m')
        yline(108,'--r',"HandleVisibility","off")
        yline(92,'--r',"HandleVisibility","off")
        if ~isempty(HPLC_data)
            errorbar(HPLC_data.Time,HPLC_data.LC_Assay,HPLC_data.Std*3,'vertical','o','Color','b','MarkerFaceColor','c');
            legend({"Hybrid NIR-SS","CLS","Mass-Balance Model","LC Assay"})
        else
            legend({"Hybrid NIR-SS","CLS","Mass-Balance Model"})
        end
        hold off              
    elseif idx == 2 
        plot_var(tt,PAT5.Variable1Name(idx),PAT5.Label(idx),[])
        lgd = legend('show'); % Create legend
        set(lgd, 'Visible', 'off'); % Hide legend
    elseif idx == 3  
        stairs(tt.Time,tt.(string(PAT5.Variable1Name(idx))),'-k','LineWidth',2)
        ylabel(PAT5.Label(idx))
        ylim([0, 1.1]); yticks([0 1]);
    elseif idx == 4 
        stairs(tt.Time,tt.(string(PAT5.Variable1Name(idx))),'-k','LineWidth',2)
        ylabel(PAT5.Label(idx))
        ylim([0, 1.1]); yticks([0 1]);
        legend("0 = Manual , 1 = Auto","Location","southeastoutside")
    else
        stairs(tt.Time,tt.(string(PAT5.Variable1Name(idx))),'-k','LineWidth',2)
        ylabel(PAT5.Label(idx))
        ylim([0, 5.1]); yticks([0 5]);
        legend("0 = Off , 5 = On","Location","southeastoutside")
        xlabel('Time (HH:MM)')
    end
end
sgtitle(figure_title)
linkaxes(f3_axes,'x'); xlim(f3_axes,"tight")
%% Figure 4: CLS Predictions Comparison
f4_axes = gobjects(1,1);
figures_pcmm(4)  = figure("Name",strjoin(["PAT5_Zoom",figure_name_string],"_"));
idx = 1;

        plot_var(tt,PAT5.Variable1Name(idx),PAT5.Label(idx),[85 115], ...
        PAT5.Variable2Name(idx))
        hold on
        plot(tt.Time,ss_pred,'-m')
        
        yline(108,'--r',"DisplayName", '108 %')
        yline(92,'--r',"DisplayName", '92 %')
        if ~isempty(HPLC_data)
            errorbar(HPLC_data.Time,HPLC_data.LC_Assay,HPLC_data.Std*3,'vertical','o','Color','b','MarkerFaceColor','c');
            legend({"Hybrid NIR-SS","CLS","Mass-Balance Model","108 %","92 %","LC Assay"})
        else
            legend({"Hybrid NIR-SS","CLS","Mass-Balance Model","108 %","92 %"})
        end
        hold off
f4_axes(1) = gca;
xlim(f4_axes,"tight")
sgtitle(figure_title)
%% Figure 5: MST
MST = config_table(categorical(config_table.Figure) =="MST",:);
figures_pcmm(5)  = figure("Name",strjoin(["MST",figure_name_string],"_"));
f5_axes = gobjects(5,1);
tiledlayout(5,1)
for idx = 1:5
    f5_axes(idx) = nexttile;
    if idx == 1
        plot_var(tt,MST.Variable1Name(idx),MST.Label(idx),[]);
        lgd = legend('show'); % Create legend
        set(lgd, 'Visible', 'off'); % Hide legend

    elseif idx >= 2 && idx <5 
        stairs(tt.Time,tt.(string(MST.Variable1Name(idx))),'-k','LineWidth',2);
        ylabel(MST.Label(idx))
        ylim([0, 1.1]); yticks([0 1]);
        
    else
        stairs(tt.Time,tt.(string(MST.Variable1Name(idx))),'-k','LineWidth',2);
        ylabel(MST.Label(idx))
        ylim([0, 5.1]); yticks([0 5]);
        xlabel('Time HH:MM')
        legend(("5 = On, 0 = Off "),"Location","southeastoutside")
    end

    % Legends 
    switch idx
        case  3
        legend("1 = ON, 0 = OFF ","Location","southeastoutside")
        case  4
        legend("1 = Alarm, 0 = OK ","Location","southeastoutside")
        case  5 
        legend(("5 = ON, 0 = OFF "),"Location","southeastoutside")
    end
end
sgtitle(figure_title)
linkaxes(f5_axes,'x');xlim(f5_axes,"tight")
%% Set the figures to be same format
theseAxes = findobj(figures_pcmm,'Type','Axes');
set(theseAxes,"FontSize",11);
set(theseAxes,"FontName",'Arial');
set(figures_pcmm,"Position",[0,0,1920,1080]);
end
