%% Script to generate PAT5 Trends for post-campaign analysis
% Vladimir Villanueva-Lopez
% clear the workspace
close all; clear; clc;
% Metadata 
compound= "BDKi PF-07328948";
PAT= "PAT 5";
folder = "C:\Users\VILLAV16\Pfizer\Drug Product Development Analytics - Integrated Predictive Science\Projects\PharmaMV PAT Batch Trends\BDKi";
% Add the current folder (pwd) and all its subfolders to the MATLAB path for the current session
addpath(genpath(pwd))
% Load Configuration File to Generate Report
config_table = readtable("Configuration_File_BDKi.xlsx","Sheet","figures");
% Read PharmaMV Files
folder_campaign_info = "C:\Users\VILLAV16\OneDrive - Pfizer\Electronic Notebooks Biovia\" + ...
    "BDKi\BDKi_Campaigns_Info.xlsx";
campaign_sum = import_campaign_summary(folder_campaign_info);
campaign_sum = campaign_sum(campaign_sum.Selected_Trends == 1,:); 
% read BDKi Campaigns info day by day 
campaign_info = import_campaign_info(folder_campaign_info);
%% IPM and trends
figureTable = table.empty();
for idx = 1:height(campaign_sum)
    % Time range to trim PharmaMV Timetable based on full campaign
    t_range_campaign = timerange(campaign_sum.Start_Date(idx),campaign_sum.Stop_Date(idx), "closed");
    % Conditional to load matlab or mdat file format 
    if campaign_sum.PMV_Data_Format == "Matlab"
        load (folder + campaign_sum.PMV_Data(idx))
        % Convert matrix to table with appropriate column names
        columnNames = "x" + erase(Signal_Info(1,:),'.');
        columnNames = string(columnNames);
        TT = array2table(Data, 'VariableNames',columnNames);
        TT.Time = Timestamps; % Add timestamps as a separate column
        % Rearranging columns so 'Time' appears first
        TT = TT(:, ['Time', columnNames]);
        TT = table2timetable(TT);
        TT.Properties.VariableDescriptions = string(Signal_Info(3,:));
        TT.Properties.VariableUnits = string(Signal_Info(4,:));
        TT = TT(t_range_campaign,:);
        campaign_sum.DB(idx) = {TT};
    else  % Data in mdat file format.
        % Create DataStore Objects
        campaign_sum.DB(idx) = PMV.DataStore("Sources",folder + campaign_sum.PMV_Data(idx));
            % Create IPM assessment
        TT = campaign_sum.DB(idx).Data; TT = TT(t_range_campaign,:);          
    end
        % Create IPM assessment
        [~,~,campaign_sum.fig_IPM(idx),TT_IPM] = PCMM.PAT5.IPM_IPC_Check(TT,0.09,23, ...
        compound + " - " + campaign_sum.Campaign(idx));
     
    % Load HPLC data if available
    if ~(campaign_sum.LC_Assay_File(idx) == "")
        LC_Assay = read_LC_assay(folder + campaign_sum.LC_Assay_File(idx));
        LC_Assay = table2timetable(LC_Assay,'RowTimes','Time');
        
        % Calculate the RMSEP
        % if campaign_sum.PMV_Data_Format == "mdat"
        %     TT = campaign_sum.DB(idx).Data;
        % end
        % runSignal      = (TT.x1705ME == 1 & TT.x1695ME == 5);
        %        ... % Press Mode (1705ME) = "Auto" (1)
        %           % Press On/Off (1695ME) = "On" (5)
        % TimeAxis_Filtered = TT.Time(runSignal);
        idx_rmsep = zeros(height(LC_Assay),1);
        rmsep = table(idx_rmsep); % RMSEP 
        for i = 1:height(LC_Assay) 
            [~, rmsep.idx_rmsep(i)] = min(abs(timeofday(TT_IPM.Time) - timeofday(LC_Assay.Time(i))));
            rmsep.LC_assay_time(i) = LC_Assay.Time(i);
            rmsep.nearest_time(i)  = TT_IPM.Time(rmsep.idx_rmsep(i));
            rmsep.diff_time_check(i) = TT_IPM.Time(rmsep.idx_rmsep(i)) - LC_Assay.Time(i);
            rmsep.predicted_potency(i) = TT_IPM.x1300ME(rmsep.idx_rmsep(i));
            rmsep.LC_assay(i)          = LC_Assay.LC_Assay(i); 
            rmsep.diff_potency(i) = rmsep.predicted_potency(i)-LC_Assay.LC_Assay(i);
        end             
        rmsep.diff_potency = rmsep.diff_potency(rmsep.predicted_potency > 0);
        campaign_sum.rmsep(idx) = rms(rmsep.diff_potency);
    else 
        LC_Assay = timetable();
        campaign_sum.rmsep(idx) = NaN;
    end
    %  Display trends
    thisCampaign = campaign_sum.Campaign(idx);
    campaign_info_sub = campaign_info(campaign_info.Campaign == thisCampaign,:);
    if campaign_sum.PMV_Data_Format == "Matlab"
        thisDB = campaign_sum.DB(idx);
        thisDB = thisDB{1};
    else 
        thisDB = campaign_sum.DB(idx).Data;
    end
    thisELN = campaign_sum.ELN(idx);
    for i = 1:height(campaign_info_sub)
        thisDay = campaign_info_sub.Day_Number(i);
        t_range = timerange(campaign_info_sub.Start_Date(i),campaign_info_sub.Stop_Date(i), "closed");
        sub_TT = thisDB(t_range,:);
        sub_LC_Assay = LC_Assay(t_range,:);
        f_tmp = plot_PAT_Trends(sub_TT, ...
                            thisELN,compound, ...
                            config_table,[],sub_LC_Assay,thisCampaign);
        if isempty(figureTable)
            figureTable = table(repmat(thisCampaign,length(f_tmp),1),...
                repmat(thisDay,length(f_tmp),1),f_tmp,'VariableNames',["Campaign","Day_Number","Figures"]);
        else
            figureTable = [figureTable;table(repmat(thisCampaign,length(f_tmp),1),...
                repmat(thisDay,length(f_tmp),1),f_tmp,'VariableNames',["Campaign","Day_Number","Figures"])];
        end
    end
end
%% Save IPM figures and Trends to PowerPoint
for idx = 1:size(campaign_sum,1)
    thisCampaign = campaign_sum.Campaign(idx);
    folderName = folder_campaign_info + "\Output\" + thisCampaign; % Specify folder name
    
    if ~exist(folderName,"dir") % Check if folder does not exist
        mkdir(folderName); % Create the folder
        disp(['Folder "', folderName, '" has been created.']);
    else
        disp(['Folder "', folderName, '" already exists.']);
    end
    wfOpts = SAN.wfOptions("compound","PF-07328948","eln",campaign_sum.ELN(idx),"lot",thisCampaign,"data_output",...
    fullfile(folderName));
    wfOpts.user = ""; % Remove the user field, this makes the filenames slightly shorter
    % Workaround for figure 4 being same name as figure 5
    sn = SAN.sdc_namer(wfOpts);
    F = SAN.FigureWriter("Figure",campaign_sum.fig_IPM(idx),"Name",sn.fn("IPM"),"Output",wfOpts.data_output);
    figs = figureTable{figureTable.Campaign == thisCampaign,'Figures'};
    for j = 1:length(figs)
        fileName = figs(j).Name;
        F=F.append(figs(j),...
        sn.fn(fileName),...
        wfOpts.data_output);
    end
    SAN.PPTxWriter(F,sn.fn());
end
%% Zip up the figures
wfOpts.lot = campaign_sum.Campaign(idx); % Remove the lot as this applies to all
zip(fullfile(wfOpts.data_output,sn.fn("Figures.zip")),...
    [fullfile(wfOpts.data_output,"PNG"),...
    fullfile(wfOpts.data_output,"SVG"),...
    fullfile(wfOpts.data_output,"FIG")]);
%% Tidy up the workspace
allVars = struct2table(whos);
clearvars -except campaign_sum campaign_info config_table wfOpts sn
%clearvars(allVars{contains(allVars.class,"Figure"),"name"}{:}) % Remove figure handles
%clearvars(allVars{contains(allVars.name,"Tmp"),"name"}{:}) % Remove temporary variables
%clearvars(allVars{cellfun(@isscalar,allVars.name),"name"}{:}) % Remove single letter variables (loop counters etc.)
%clearvars(allVars{contains(allVars.name,"figure"),"name"}{:}) % Remove variables with the word "Figure" in them
%clearvars("ans") % And lastly this one
%% gather files
SAN.gatherFiles("Run_PCMM_Wet_Gran_Trends.m",wfOpts.data_output,sn);
%% Save the workspace (optional)
%wfOpts.lot = ""; % Remove the lot as this applies to all
%save(fullfile(wfOpts.data_output,wfOpts.save_workspace_name));

