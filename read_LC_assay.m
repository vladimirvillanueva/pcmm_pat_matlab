function LC_assay_data  = read_LC_assay(workbookFile, sheetName, dataLines)
%read_LC_assay Import data from a spreadsheet that contains LC assay values
%% Input handling

% If no sheet is specified, read from Sheet1
if nargin == 1 || isempty(sheetName)
    sheetName = "Sheet1";
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
opts = spreadsheetImportOptions("NumVariables", 5);

% Specify sheet and range
opts.Sheet = sheetName;
if lastRowOfDataIdx == 1
    opts.DataRange = "A" + dataLines(1, 1);
else
    opts.DataRange = "A" + dataLines(1, 1) + ":E" + dataLines(1, 2);
end

% Specify column names and types
opts.VariableNames = ["Time", "LC_Assay", "Std", "Std3", "Sample"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double"];

% Import the data
LC_assay_data = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    if idx == lastRowOfDataIdx
        opts.DataRange = "A" + dataLines(idx, 1);
    else
        opts.DataRange = "A" + dataLines(idx, 1) + ":E" + dataLines(idx, 2);
    end
    tb = readtimetable(workbookFile, opts, "UseExcel", false);
    LC_assay_data  = [LC_assay_data; tb]; %#ok<AGROW>
end

end