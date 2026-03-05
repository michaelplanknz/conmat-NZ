NZ_conmat.csv is a NZ contact matrix in 5-year age groups up to 85+

The matrix was generated using conmat with the R script makeContactMatrix.R

This uses POLYMOD survey data (all contacts) and the NZ population (according to ERP_2018_base.csv)

The matrix is forced to satisfy the detailed balance condition in the usual way.

In the output matrix, Cij is the number of contacts someone in age group i has with people in age group j.
