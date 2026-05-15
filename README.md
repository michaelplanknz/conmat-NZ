# New Zealand contact matrcies from conmat

Uses the R package conmat to make contact matrices for New Zealand.

This combines POLYMOD data with NZ age-stratified population data to make a NZ-specific contact matrix.


## How to use this repo

Pre-requisites:
* Install the R package [conmat](https://idem-lab.github.io/conmat/dev/index.html).
* You ned a population data file `output/ERP_YYYY_base_ZZZZ.csv' which contains the NZ estimated resident population in year YYYY using census base ZZZZ, stratified by ethnicity and in 5-year age groups (see format below).
* This file can be generated from raw population data (output from the IDI) by running the Matlab script `process_ERP2023_data.m` in the folder `code`. This processes the raw data `input_data/ERP counts 2019-2025_confidentialised.xlsx`.

The `ERP...` data file needs to be a .csv file in the following format.
|age     |Other    |Maori    |Pacific  |Asian    |
|--------|---------|---------|---------|---------|
|0-4     |         |         |         |         |
|5-9     |         |         |         |         |
|...     |         |         |         |         |
|95+     |         |         |         |         |

To generate a contact matrix:
* Run the R script `code/makeContractMatrix.R`.
* This saves the contact matrix in `output/NZ_conmat.csv`, which contains is a NZ contact matrix in 5-year age groups up to 95+. The entry in the ith row and jth column of this matrix is the estmiated number of daily contacts that someone in age group i has with people in age group j.

## Notes

This uses POLYMOD survey data (all contacts). In principle, it could be modified to use home, school, work and other contacts to generate separate contact matrices for these settings.

The matrix is forced to satisfy the detailed balance condition in the usual way.

The code can be adapted to use a different top age band if required. 
