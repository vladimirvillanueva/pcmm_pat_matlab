function BDKiCampaignsInfoS1  = import_campaign_summary(workbookFile, sheetName, dataLines)
%% Input handling

% If no sheet is specified, read from Summary
if nargin == 1 || isempty(sheetName)
    sheetName = "Summary";
end

% If row start and end points are not specified, define defaults
lastRowOfDataIdx = 0;
if nargin <= 2
    dataLines = [2, Inf];
    lastRowOfDataIdx = 1;
elseif dataLines(end,2) >= Inf
    lastRowOfDataIdx = size(dataLines, 1);
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 10);

% Specify sheet and range
opts.Sheet = sheetName;
if lastRowOfDataIdx == 1
    opts.DataRange = "A" + dataLines(1, 1);
else
    opts.DataRange = "A" + dataLines(1, 1) + ":J" + dataLines(1, 2);
end

% Specify column names and types
opts.VariableNames = ["Selected_Trends", "Campaign","ELN","Start_Date", "Stop_Date", "PMV_Data", "LC_Assay_File","PMV_Data_Format"];
opts.VariableTypes = ["double", "string", "string", "string", "string", "string", "string", "string"];

% Specify variable properties
opts = setvaropts(opts, ["Campaign", "ELN", "Start_Date", "Stop_Date", "PMV_Data", "LC_Assay_File"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Campaign", "ELN", "Start_Date", "Stop_Date", "PMV_Data", "LC_Assay_File"], "EmptyFieldRule", "auto");

% Import the data
BDKiCampaignsInfoS1 = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    if idx == lastRowOfDataIdx
        opts.DataRange = "A" + dataLines(idx, 1);
    else
        opts.DataRange = "A" + dataLines(idx, 1) + ":J" + dataLines(idx, 2);
    end
    tb = readtable(workbookFile, opts, "UseExcel", false);
    BDKiCampaignsInfoS1 = [BDKiCampaignsInfoS1; tb]; %#ok<AGROW>
end

end