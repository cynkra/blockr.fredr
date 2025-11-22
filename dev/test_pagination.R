# Test pagination to get more than 1000 results
library(fredr)

cat("\n=== TESTING PAGINATION ===\n\n")

# Test 1: Check if we can paginate text search
cat("1. Testing pagination with fredr_series_search_text()\n")
cat("=======================================================\n")

# Get first page
page1 <- fredr_series_search_text(
  search_text = "Switzerland",
  limit = 1000,
  offset = 0
)
cat("Page 1 (offset 0):", nrow(page1), "series\n")

# Try to get second page
tryCatch({
  page2 <- fredr_series_search_text(
    search_text = "Switzerland",
    limit = 1000,
    offset = 1000
  )
  cat("Page 2 (offset 1000):", nrow(page2), "series\n")

  # Check if we got different series
  overlap <- sum(page1$id %in% page2$id)
  cat("Overlap between pages:", overlap, "series\n")
  cat("New series in page 2:", nrow(page2) - overlap, "\n")

  if (nrow(page2) > 0) {
    cat("\nWe can paginate! Combining pages...\n")
    combined <- rbind(page1, page2)
    combined <- combined[!duplicated(combined$id), ]
    cat("Total unique series after 2 pages:", nrow(combined), "\n")
  }
}, error = function(e) {
  cat("ERROR getting page 2:", e$message, "\n")
})

cat("\n")

# Test 2: Check total count available
cat("2. Checking total available series\n")
cat("====================================\n")

# The FRED API often returns metadata about total count
# Let's check the attributes of the result
attrs <- attributes(page1)
cat("Available attributes:\n")
print(names(attrs))

# Many FRED API calls include a 'count' attribute
if ("count" %in% names(attrs)) {
  cat("\nTotal series available:", attrs$count, "\n")
}

cat("\n")

# Test 3: Try different strategies to get comprehensive lists
cat("3. Strategy: Use more specific searches to avoid limit\n")
cat("=======================================================\n")

# For Switzerland, we could search for specific indicators
swiss_searches <- list(
  gdp = fredr_series_search_text("Switzerland GDP", limit = 100),
  unemployment = fredr_series_search_text("Switzerland unemployment", limit = 100),
  inflation = fredr_series_search_text("Switzerland inflation", limit = 100),
  cpi = fredr_series_search_text("Switzerland CPI", limit = 100),
  interest = fredr_series_search_text("Switzerland interest rate", limit = 100),
  exchange = fredr_series_search_text("Switzerland exchange rate", limit = 100)
)

cat("Specific indicator searches:\n")
for (name in names(swiss_searches)) {
  cat("  -", name, ":", nrow(swiss_searches[[name]]), "series\n")
}

# Combine and deduplicate
combined_specific <- do.call(rbind, swiss_searches)
combined_specific <- combined_specific[!duplicated(combined_specific$id), ]
cat("\nTotal unique series from specific searches:", nrow(combined_specific), "\n")
cat("Compare to broad 'Switzerland' search:", nrow(page1), "series\n")

cat("\n")

# Test 4: Try pagination with tags
cat("4. Testing pagination with fredr_tags_series()\n")
cat("===============================================\n")

swiss_tag_p1 <- fredr_tags_series(
  tag_names = "switzerland",
  limit = 1000,
  offset = 0
)
cat("Page 1 (offset 0):", nrow(swiss_tag_p1), "series\n")

tryCatch({
  swiss_tag_p2 <- fredr_tags_series(
    tag_names = "switzerland",
    limit = 1000,
    offset = 1000
  )
  cat("Page 2 (offset 1000):", nrow(swiss_tag_p2), "series\n")

  if (nrow(swiss_tag_p2) > 0) {
    combined_tags <- rbind(swiss_tag_p1, swiss_tag_p2)
    combined_tags <- combined_tags[!duplicated(combined_tags$id), ]
    cat("Total unique series from tag pagination:", nrow(combined_tags), "\n")
  }
}, error = function(e) {
  cat("ERROR getting page 2:", e$message, "\n")
})

cat("\n")

# Test 5: Reality check - how many series do we really need?
cat("5. REALITY CHECK: Do we need all series?\n")
cat("==========================================\n")

cat("\nFor each category, consider:\n")
cat("- Switzerland: 1000+ series available, but many are duplicates or variants\n")
cat("- Do users really need 1000+ series in a dropdown?\n")
cat("- Better approach might be:\n")
cat("  A) Return top 1000 most popular series\n")
cat("  B) Allow filtering by indicator type (GDP, CPI, etc.)\n")
cat("  C) Use search within the category\n")

# Check popularity of series
if ("popularity" %in% names(page1)) {
  cat("\nTop 20 most popular Switzerland series:\n")
  top_popular <- page1[order(-page1$popularity), ]
  print(top_popular[1:20, c("id", "title", "popularity", "frequency_short")])

  cat("\nDistribution of popularity scores:\n")
  print(summary(page1$popularity))
}

cat("\n=== CONCLUSION ===\n")
cat("The 1000 series limit is a FRED API constraint.\n")
cat("Pagination may allow getting more, but:\n")
cat("  1. Returns may be limited server-side anyway\n")
cat("  2. 1000 series is already too many for a dropdown\n")
cat("  3. Better to use filtering, search, or curated lists\n")
