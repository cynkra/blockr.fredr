# Testing tags approach more thoroughly
library(fredr)

cat("\n=== TESTING TAGS APPROACH ===\n\n")

# Test 1: Get all series for 'switzerland' tag
cat("1. Using fredr_tags_series() for 'switzerland' tag\n")
cat("====================================================\n")
swiss_tag_series <- fredr_tags_series(
  tag_names = "switzerland",
  limit = 1000  # FRED API typically limits to 1000
)

cat("Total series found:", nrow(swiss_tag_series), "\n")
cat("Note: The tag returned", nrow(swiss_tag_series), "series\n")
cat("Earlier search returned 1000 series (hit API limit)\n")
cat("The tag approach may be more focused!\n\n")

cat("Sample of first 20:\n")
print(swiss_tag_series[1:min(20, nrow(swiss_tag_series)),
                       c("id", "title", "frequency_short")])

cat("\nFrequency distribution:\n")
print(table(swiss_tag_series$frequency_short))

# Save this for comparison
write.csv(
  data.frame(
    id = swiss_tag_series$id,
    title = swiss_tag_series$title,
    frequency = swiss_tag_series$frequency_short
  ),
  "/Users/christophsax/git/blockr/blockr.fredr/dev/switzerland_tag_series.csv",
  row.names = FALSE
)
cat("\nSaved to: dev/switzerland_tag_series.csv\n\n")

# Test 2: Try to find other relevant tags
cat("\n2. Finding other useful geo tags\n")
cat("==================================\n")

# Get all geo tags
geo_tags <- fredr_tags(
  limit = 1000,
  tag_group_id = "geo"  # Geographic tags
)

cat("Total geographic tags:", nrow(geo_tags), "\n")
cat("Sample of interesting geo tags:\n")
interesting <- geo_tags[grep("^[A-Z]", geo_tags$name), ]
print(head(interesting[order(-interesting$series_count), c("name", "series_count")], 30))

# Test 3: Check if we can use multiple tags together
cat("\n3. Testing combined tags\n")
cat("=========================\n")

# Try Switzerland + GDP
cat("Trying tags: switzerland;gdp\n")
swiss_gdp <- fredr_tags_series(
  tag_names = "switzerland;gdp",
  limit = 100
)
cat("Results:", nrow(swiss_gdp), "series\n")
if (nrow(swiss_gdp) > 0) {
  print(swiss_gdp[, c("id", "title", "frequency_short")])
}

cat("\nTrying tags: switzerland;quarterly\n")
swiss_quarterly <- fredr_tags_series(
  tag_names = "switzerland;quarterly",
  limit = 100
)
cat("Results:", nrow(swiss_quarterly), "series\n\n")

# Test 4: Look for international/global tags
cat("\n4. Looking for international/global tags\n")
cat("=========================================\n")

# Check what tags are available for international data
intl_tags <- fredr_tags(
  search_text = "oecd",
  limit = 100
)
cat("OECD-related tags:\n")
print(intl_tags[, c("name", "series_count")])

cat("\nChecking series count for 'oecd' tag:\n")
oecd_series <- fredr_tags_series(
  tag_names = "oecd",
  limit = 1000
)
cat("OECD tag series:", nrow(oecd_series), "\n\n")

# Test 5: US tags
cat("\n5. US-specific tags\n")
cat("====================\n")

usa_tags <- fredr_tags(
  search_text = "usa",
  limit = 100
)
cat("USA-related tags:\n")
print(usa_tags[, c("name", "series_count")])

cat("\n=== COMPARISON: Text Search vs Tags ===\n\n")
cat("Switzerland:\n")
cat("  - Text search ('Switzerland'): 1000+ series (hit limit)\n")
cat("  - Tag search ('switzerland'):", nrow(swiss_tag_series), "series\n")
cat("  - Tag approach is more focused and doesn't hit limit\n\n")

cat("Recommendation: Use TAGS for Switzerland, TEXT SEARCH for others\n")
