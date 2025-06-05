function campaign_info = import_campaign_info(workbookFile, sheetName, dataLines)
%% Input handling
% If no sheet is specified, read from Sheet1
if nargin == 1 || isempty(sheetName)
    sheetName = "Day by Day";
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 5);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = dataLines(1, :);

% Specify column names and types
opts.VariableNames = ["Campaign", "Day_Number", "Start_Date", "Stop_Date","ELN"];
opts.VariableTypes = ["string", "double", "datetime", "datetime","string"];

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";

% Specify variable properties
opts = setvaropts(opts, "Campaign", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Campaign", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Day_Number", "TreatAsMissing", '');

% Import the data
campaign_info = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = dataLines(idx, :);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    campaign_info = [campaign_info; tb]; %#ok<AGROW>
end
end