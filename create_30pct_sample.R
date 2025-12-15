# =============================================================================
# CREATE 30% SAMPLE OF ANTIBIOTIC USE DATASET
# =============================================================================
# Purpose: Reduce dataset size for faster analysis
# Run this ONCE, then load the saved files in your analyses
# =============================================================================

library(tidyverse)
library(haven)

# Load original data
cat("Loading original SPSS data...\n")
data_raw <- read_sav("pone.0153778.s003.sav")
cat(sprintf("Original dataset: %d observations\n", nrow(data_raw)))

# Rename outcome variable
data_raw <- data_raw %>%
  rename(medicine_use = Psycmed)

# Change prevalence from 26% to 15%
set.seed(123)
current_users <- which(data_raw$medicine_use == 1)
n_total <- nrow(data_raw)
target_n <- round(n_total * 0.15)
n_to_change <- length(current_users) - target_n
to_change <- sample(current_users, n_to_change)
data_raw$medicine_use[to_change] <- 0
cat(sprintf("Adjusted prevalence to %.1f%%\n", mean(data_raw$medicine_use)*100))

# ====== 30% RANDOM SAMPLING ======
set.seed(456)
sample_indices <- sample(1:nrow(data_raw), size = round(0.30 * nrow(data_raw)))
data_raw <- data_raw[sample_indices, ]
cat(sprintf("\n30%% sample: %d observations\n", nrow(data_raw)))

# Prepare analysis dataset
data <- data_raw %>%
  mutate(
    neighbourhood = as.factor(Neigh),
    antibiotic_use = medicine_use,
    age_group = factor(agegroup, levels = 1:6,
                       labels = c("35-39", "40-44", "45-49", 
                                 "50-54", "55-59", "60-64")),
    sex = factor(male, levels = c(0, 1), labels = c("Female", "Male")),
    individual_income_low = poor,
    neighbourhood_income_low = poorarea,
    gp_private = Private
  ) %>%
  select(neighbourhood, antibiotic_use, age_group, sex, 
         individual_income_low, neighbourhood_income_low, gp_private)

# Summary
cat("\n=== DATASET SUMMARY ===\n")
cat(sprintf("Individuals: %d\n", nrow(data)))
cat(sprintf("Neighbourhoods: %d\n", length(unique(data$neighbourhood))))
cat(sprintf("Antibiotic use: %.1f%%\n", mean(data$antibiotic_use)*100))
cat(sprintf("Private GP use: %.1f%%\n", mean(data$gp_private)*100))
cat(sprintf("Male: %.1f%%\n", mean(data$sex == "Male")*100))
cat(sprintf("Low income: %.1f%%\n", mean(data$individual_income_low)*100))

# Save in multiple formats
cat("\n=== SAVING FILES ===\n")

# CSV (can open in Excel)
write.csv(data, "antibiotic_use_30pct_sample.csv", row.names = FALSE)
cat("✓ Saved: antibiotic_use_30pct_sample.csv\n")

# RDS (preserves R data types, smaller file)
saveRDS(data, "antibiotic_use_30pct_sample.rds")
cat("✓ Saved: antibiotic_use_30pct_sample.rds\n")

# RData (alternative R format)
save(data, file = "antibiotic_use_30pct_sample.RData")
cat("✓ Saved: antibiotic_use_30pct_sample.RData\n")

cat("\n=== DONE ===\n")
cat("\nTo use in your analyses:\n")
cat("  data <- readRDS('antibiotic_use_30pct_sample.rds')\n")
cat("  # OR\n")
cat("  data <- read.csv('antibiotic_use_30pct_sample.csv')\n")
