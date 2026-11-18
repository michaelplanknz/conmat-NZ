# See https://idem-lab.github.io/conmat/dev/index.html

# Reads processed population data from "../output/ERP_2025_base_2023.csv"
# Saves contact matrix to "../output/NZ_conmat.csv"
# In the output matrix, C_ij is the average number of contacts someone in group i has with people in group j

library(conmat)
library(readr)
library(dplyr)
library(tibble)
library(tidyr)
library(ggplot)

# Specify the number of 5-year age bands to use - top age band will have lower limit of 5*(n_ages-1)
n_ages = 18;

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
  age_breaks = c(seq(0, 5*(n_ages-1), by = 5), Inf)
)

# Combine top edge bands (if top age band is less than 95)
N <- pop_dat$population[1:n_ages]
N[n_ages] <- sum(pop_dat$population[n_ages:length(pop_dat$population)] )


# Make a matrix of the model output
mat = predictions_to_matrix(synthetic_contact_NZ)

# Plot the matrix
autoplot(mat)

# Force detailed balanced condition
mat_DB = 0.5 * (mat + (N %*% (1/t(N)) ) * t(mat) )


# Calculate and display mismatch in detailed balance conditions for each matrix
DBerr0 = (sweep(mat, 2, N, `*`) - sweep(t(mat), 1, N, `*`)  ) / sweep(mat, 2, N, `*`)
DBerr1 = (sweep(mat_DB, 2, N, `*`) - sweep(t(mat_DB), 1, N, `*`)  ) / sweep(mat_DB, 2, N, `*`)

message("max relative difference in ij vs ji contacts:                        ", max(DBerr0))
message("max relative difference in ij vs ji contacts after detailed balance: ", max(DBerr1))

# Plot detailed balance matrix
autoplot(mat_DB)

# Plot contact rate vs age
conts_by_age = rowSums(t(mat_DB))
df = data.frame(x = seq(0, 5*(n_ages-1), by = 5), y = conts_by_age)
ggplot(df, aes(x = x, y = y)) +
  geom_line() +
  geom_point() +
  labs(x = "Age (years)", y = "Mean daily contacts") + 
  scale_y_continuous(limits = c(0, NA))

# Transpose so columns are age_group_to 
mat_DB_transposed = t(mat_DB)

# Save contact matrix as .csv
write_csv(
  as.data.frame(mat_DB_transposed),
  "../output/NZ_conmat.csv",
  col_names = FALSE
)


