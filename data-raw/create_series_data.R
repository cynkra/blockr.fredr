#!/usr/bin/env Rscript
# Create cached FRED series data for category filtering
# This script creates internal package data (R/sysdata.rda)

library(readr)

# Read the CSV files created by research
switzerland_data <- read_csv("dev/switzerland_final.csv", show_col_types = FALSE)
global_data <- read_csv("dev/global_final.csv", show_col_types = FALSE)
us_data <- read_csv("dev/us_final.csv", show_col_types = FALSE)

# Create clean data frames with only needed columns
fred_series_switzerland <- data.frame(
  id = switzerland_data$id,
  title = switzerland_data$title,
  frequency = switzerland_data$frequency,
  stringsAsFactors = FALSE
)

fred_series_global <- data.frame(
  id = global_data$id,
  title = global_data$title,
  frequency = global_data$frequency,
  stringsAsFactors = FALSE
)

fred_series_us <- data.frame(
  id = us_data$id,
  title = us_data$title,
  frequency = us_data$frequency,
  stringsAsFactors = FALSE
)

# Print summary
cat("Switzerland:", nrow(fred_series_switzerland), "series\n")
cat("Global:", nrow(fred_series_global), "series\n")
cat("US:", nrow(fred_series_us), "series\n")
cat("Total:", nrow(fred_series_switzerland) + nrow(fred_series_global) + nrow(fred_series_us), "series\n")

# Save as internal package data
usethis::use_data(
  fred_series_switzerland,
  fred_series_global,
  fred_series_us,
  internal = TRUE,
  overwrite = TRUE
)

cat("\nInternal data saved to R/sysdata.rda\n")
