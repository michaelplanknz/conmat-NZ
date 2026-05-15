# See https://idem-lab.github.io/conmat/dev/index.html

# Reads processed population data from "../output/ERP_2025_base_2023.csv"
# Saves contact matrix to "../output/NZ_conmat.csv"
# In the output matrix, C_ij is the average number of contacts someone in group i has with people in group j

library(conmat)
library(readr)
library(dplyr)
library(tibble)
library(tidyr)

polymod_contact_data <- get_polymod_contact_data(setting = "all")
polymod_survey_data <- get_polymod_population()

set.seed(2022 - 09 - 06)
contact_model <- fit_single_contact_model(
  contact_data = polymod_contact_data,
  population = polymod_survey_data
)

# Get NZ pop data
pop_dat_nz <- read_csv("../output/ERP_2025_base_2023.csv")

# Sum over ethnicities
pop_dat_nz <- pop_dat_nz %>%
  mutate(population = Other + Maori + Pacific + Asian)

# Get a data frame that is in the correct format for conmat
pop_dat = age_population(data = pop_dat_nz, location_col = NULL, location = NULL, age)

# Run the synthetic contact matrix model
synthetic_contact_NZ <- predict_contacts(
  model = contact_model,
  population = pop_dat,
  age_breaks = c(seq(0, 95, by = 5), Inf)
)

# Make a matrix of the model output
mat = predictions_to_matrix(synthetic_contact_NZ)

# Plot the matrix
autoplot(mat)

# Force detailed balanced condition
mat_DB = 0.5 * (mat + (pop_dat$population %*% (1/t(pop_dat$population)) ) * t(mat) )


# Calculate and display mismatch in detailed balance conditions for each matrix
DBerr0 = (sweep(mat, 2, pop_dat$population, `*`) - sweep(t(mat), 1, pop_dat$population, `*`)  ) / sweep(mat, 2, pop_dat$population, `*`)
DBerr1 = (sweep(mat_DB, 2, pop_dat$population, `*`) - sweep(t(mat_DB), 1, pop_dat$population, `*`)  ) / sweep(mat_DB, 2, pop_dat$population, `*`)

message("max relative difference in ij vs ji contacts:                        ", max(DBerr0))
message("max relative difference in ij vs ji contacts after detailed balance: ", max(DBerr1))

# Plot detailed balance matrix
autoplot(mat_DB)

# Transpose so columns are age_group_to 
mat_DB_transposed = t(mat_DB)

# Save as .csv
write_csv(
  as.data.frame(mat_DB_transposed),
  "../output/NZ_conmat.csv",
  col_names = FALSE
)


