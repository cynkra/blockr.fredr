#!/usr/bin/env Rscript
# Fetch FRED series metadata for selected tags and save to parquet
# This script creates the metadata cache used by the FRED block

library(fredr)
library(dplyr)
library(duckplyr)

# Check for FRED API key
if (!fredr_has_key()) {
  stop("FRED API key not found. Set with fredr_set_key('YOUR_KEY') or FRED_API_KEY env var")
}

# Tags to fetch metadata for
tags <- c("switzerland", "usa", "euro area", "oecd")

cat("Fetching FRED series metadata for tags:", paste(tags, collapse = ", "), "\n\n")

# Fetch metadata for each tag
all_series <- lapply(tags, function(tag) {
  cat("Fetching", tag, "... ")

  series <- fredr_tags_series(
    tag_names = tag,
    limit = 1000  # FRED API limit is 1000 per request
  )

  cat(nrow(series), "series found\n")

  # Add tag column and select relevant fields
  series |>
    mutate(tag = tag) |>
    select(
      id,
      title,
      frequency,
      frequency_short,
      popularity,
      seasonal_adjustment_short,
      tag
    )
}) |>
  bind_rows()

# Summary
cat("\nTotal series fetched:", nrow(all_series), "\n")
cat("Breakdown by tag:\n")
print(table(all_series$tag))

# Create inst/extdata directory if it doesn't exist
if (!dir.exists("inst/extdata")) {
  dir.create("inst/extdata", recursive = TRUE)
  cat("\nCreated inst/extdata directory\n")
}

# Save to parquet using duckplyr
output_path <- "inst/extdata/fred_metadata.parquet"
all_series |>
  duckplyr::compute_parquet(output_path)

# Check file size
file_size <- file.info(output_path)$size / 1024 / 1024
cat("\nSaved to:", output_path, "\n")
cat("File size:", round(file_size, 2), "MB\n")

cat("\nDone! Metadata cache is ready for use.\n")
