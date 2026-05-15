clear
close all

% Script to read in the raw ERP 2018 base data "t6_region_2025-12-17.csv" downloaded from Te Whatu Ora populatiom web tool 
% And save it as a wide-format table of population sizes by age % and ethnicity


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input/output settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_data_folder = "../input_data/";
raw_data_fname = "t6_region_2025-12-17.csv";

output_folder = "../output/";
output_fname = "ERP_2018_base.csv";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fIn = raw_data_folder + raw_data_fname;
opts = detectImportOptions(fIn);
opts = setvartype(opts, {'eth_mpao', 'agegrp'}, 'categorical');
raw = readtable(fIn, opts);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Omit the "AllAge" data
keepFlag = raw.agegrp ~= "AllAge";
raw = raw(keepFlag, :);

% Make a new variable called age and relace group labbl "<5" with "0-4"
raw.age = raw.agegrp;
raw.age(raw.age == "<5") = "0-4";

% Specify ordering of age and ethnicity categories
raw.eth_mpao = reordercats(raw.eth_mpao, ["Other", "Maori", "Pacific", "Asian"]);

% Make a wide-format table
tbl = unstack(raw, 'popcount', 'eth_mpao', 'groupingvariables', 'age');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One-way pop totals from raw data
% Totals bu ethnicity
tmp = groupsummary(raw, 'eth_mpao', "sum", "popcount");
popByEth1 = tmp.sum_popcount;

% Totals by age
tmp = groupsummary(raw, 'age', "sum", "popcount");

% Need to sort this by age so make a string variable
tmp.agestring = string(tmp.age);

% Replace the "+" in "85+" with a "-" for consistency with other groups
tmp.agestring = replace(tmp.agestring, "+", "-");

% Create a numeric variable corresponding to the lower end of the age band
tmp.agenum = double(extractBefore(tmp.agestring, "-"));

% Sort
tmp = sortrows(tmp, 'agenum');
popByAge1 = tmp.sum_popcount;


% One-way pop totals from processed data
popByEth2 = sum(table2array(tbl(:,2:end)))';
popByAge2 = sum(table2array(tbl(:,2:end)), 2);


% Check these are the same
assert(isequal(popByEth1, popByEth2));
assert(isequal(popByAge1, popByAge2));

fprintf('Data processed and all tests passed, total pop size = %i\n', sum(popByAge1))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save processed data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fOut = output_folder + output_fname;
writetable(tbl, fOut);


