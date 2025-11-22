# Summary Statistics for FRED Series Research
# Quick overview of the three categories

library(fredr)

cat("\n")
cat("=========================================================================\n")
cat("                    FRED SERIES RESEARCH SUMMARY                         \n")
cat("=========================================================================\n")
cat("\n")

# Read the CSV files
switzerland <- read.csv("dev/switzerland_final.csv", stringsAsFactors = FALSE)
global <- read.csv("dev/global_final.csv", stringsAsFactors = FALSE)
us <- read.csv("dev/us_final.csv", stringsAsFactors = FALSE)

# Function to create a nice table
print_table <- function(data, title) {
  cat("\n")
  cat(title, "\n")
  cat(paste(rep("-", nchar(title)), collapse = ""), "\n")
  for (i in 1:nrow(data)) {
    cat(sprintf("%-20s %s\n", data[i, 1], data[i, 2]))
  }
  cat("\n")
}

# 1. Overall counts
cat("1. OVERALL SERIES COUNTS\n")
cat("========================\n\n")

counts <- data.frame(
  Category = c("Switzerland", "Global/International", "US (sample)"),
  Count = c(
    format(nrow(switzerland), big.mark = ","),
    format(nrow(global), big.mark = ","),
    format(nrow(us), big.mark = ",")
  )
)
print(counts, row.names = FALSE)

cat("\nNote: US sample is limited to 5,000 series. Full 'usa' tag has 672,590+ series.\n")

# 2. Frequency breakdown
cat("\n2. FREQUENCY DISTRIBUTION\n")
cat("=========================\n\n")

cat("SWITZERLAND:\n")
print(sort(table(switzerland$frequency), decreasing = TRUE))

cat("\nGLOBAL/INTERNATIONAL:\n")
print(sort(table(global$frequency), decreasing = TRUE))

cat("\nUS:\n")
print(sort(table(us$frequency), decreasing = TRUE))

# 3. Sample series
cat("\n3. SAMPLE SERIES (First 10 from each category)\n")
cat("===============================================\n\n")

cat("SWITZERLAND:\n")
cat("------------\n")
for (i in 1:min(10, nrow(switzerland))) {
  cat(sprintf("%2d. %-20s [%s] %s\n",
              i,
              switzerland$id[i],
              switzerland$frequency[i],
              substr(switzerland$title[i], 1, 60)))
}

cat("\nGLOBAL/INTERNATIONAL:\n")
cat("---------------------\n")
for (i in 1:min(10, nrow(global))) {
  cat(sprintf("%2d. %-20s [%s] %s\n",
              i,
              global$id[i],
              global$frequency[i],
              substr(global$title[i], 1, 60)))
}

cat("\nUS:\n")
cat("---\n")
for (i in 1:min(10, nrow(us))) {
  cat(sprintf("%2d. %-20s [%s] %s\n",
              i,
              us$id[i],
              us$frequency[i],
              substr(us$title[i], 1, 60)))
}

# 4. Recommended usage
cat("\n4. RECOMMENDED USAGE\n")
cat("====================\n\n")

cat("Switzerland (2,455 series):\n")
cat("---------------------------\n")
cat("  library(fredr)\n")
cat("  swiss <- fredr_tags_series(tag_names = 'switzerland', limit = 1000)\n")
cat("  # Use pagination for all 2,455 series\n\n")

cat("Global/International (5,996 series):\n")
cat("------------------------------------\n")
cat("  # Combine multiple sources:\n")
cat("  oecd <- fredr_tags_series(tag_names = 'oecd', limit = 1000)\n")
cat("  imf <- fredr_tags_series(tag_names = 'imf', limit = 1000)\n")
cat("  intl <- fredr_series_search_text(search_text = 'International', limit = 1000)\n")
cat("  global <- rbind(oecd, imf, intl)\n")
cat("  global <- global[!duplicated(global$id), ]\n\n")

cat("US (672,590+ series - recommend limiting):\n")
cat("------------------------------------------\n")
cat("  Option 1 - Limited subset:\n")
cat("    us <- fredr_tags_series(tag_names = 'usa', limit = 1000)\n\n")
cat("  Option 2 - Curated key indicators:\n")
cat("    key_ids <- c('UNRATE', 'GDP', 'CPIAUCSL', 'FEDFUNDS', 'DGS10', ...)\n")
cat("    us <- lapply(key_ids, fredr_series)\n\n")

# 5. Key findings
cat("\n5. KEY FINDINGS\n")
cat("===============\n\n")

findings <- c(
  "1. Tags are more reliable than text search for geographic filtering",
  "2. Pagination is required to get more than 1,000 results per call",
  "3. Switzerland and Global categories are manageable in size",
  "4. US category is massive (672K+) and needs filtering or curation",
  "5. Most series have variants (different frequencies/adjustments)",
  "6. Popularity field can help surface most relevant series",
  "7. fredr package supports all necessary functions for data retrieval"
)

for (finding in findings) {
  cat("   ", finding, "\n")
}

cat("\n")
cat("=========================================================================\n")
cat("For complete details, see: dev/RESEARCH_SUMMARY.md\n")
cat("=========================================================================\n")
cat("\n")
