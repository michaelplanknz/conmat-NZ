clear
close all

% Script to read in the raw ERP 2023 base data "ERP counts 2019-2025_confidentialised.xlsx" output from the IDI
% And save it as a wide-format table of population sizes by age % and ethnicity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input/output settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use ERP pop estimates for this year (all are from the 2023 census base)
estYear = 2025;

raw_data_folder = "../input_data/";
raw_data_fname = "ERP counts 2019-2025_confidentialised.xlsx";

output_folder = "../output/";
output_fname = "ERP_" + estYear + "_base_2023.csv";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fIn = raw_data_folder + raw_data_fname;
opts = detectImportOptions(fIn, 'Sheet', string(estYear));
opts = setvartype(opts, {'Ethnicity', 'AgeGroup'}, 'categorical');
raw = readtable(fIn, opts);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Replace "AgeGroup" with a field called "Age" formatted as "0-4", "5-9", etc.
raw.age = categorical(replace(string(raw.AgeGroup), ",", "-"));
raw = removevars(raw, 'AgeGroup');


% Specify ordering of age and ethnicity categories
raw.Ethnicity = reordercats(raw.Ethnicity, ["Other", "Maori", "Pacific", "Asian"]);

% Make a wide-format table
tbl = unstack(raw, 'N', 'Ethnicity', 'groupingvariables', 'age');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One-way pop totals from raw data
% Totals bu ethnicity
tmp = groupsummary(raw, 'Ethnicity', "sum", "N");
popByEth1 = tmp.sum_N;

% Totals by age
tmp = groupsummary(raw, 'age', "sum", "N");

% Need to sort this by age so make a string variable
tmp.agestring = string(tmp.age);

% Replace the "+" in "95+" with a "-" for consistency with other groups
tmp.agestring = replace(tmp.agestring, "+", "-");

% Create a numeric variable corresponding to the lower end of the age band
tmp.agenum = double(extractBefore(tmp.agestring, "-"));

% Sort
tmp = sortrows(tmp, 'agenum');
popByAge1 = tmp.sum_N;


% One-way pop totals from processed data
popByEth2 = sum(table2array(tbl(:, 2:end)))';
popByAge2 = sum(table2array(tbl(:, 2:end)), 2);


% Check these are the same
assert(isequal(popByEth1, popByEth2));
assert(isequal(popByAge1, popByAge2));

fprintf('Data processed and all tests passed, total pop size = %i\n', sum(popByAge1))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save processed data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fOut = output_folder + output_fname;
writetable(tbl, fOut);


