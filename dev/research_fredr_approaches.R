# Research script for fredr package approaches
# Goal: Determine best way to fetch series for Switzerland, Global, and US categories

library(fredr)

# Check if API key is set
if (!fredr_has_key()) {
  stop("FRED API key not set. Please set it with fredr_set_key() or FRED_API_KEY env var")
}

cat("\n=== FRED API Research ===\n\n")

# ============================================================================
# 1. TEXT SEARCH APPROACH
# ============================================================================
cat("1. TEXT SEARCH APPROACH\n")
cat("========================\n\n")

# 1.1 Switzerland search
cat("1.1 Testing fredr_series_search_text() for 'Switzerland'\n")
cat("---------------------------------------------------------\n")
tryCatch({
  switzerland_search <- fredr_series_search_text(
    search_text = "Switzerland",
    limit = 1000
  )

  cat("Total series found:", nrow(switzerland_search), "\n")
  cat("Columns:", paste(names(switzerland_search), collapse = ", "), "\n")

  if (nrow(switzerland_search) > 0) {
    cat("\nSample of first 10 series:\n")
    print(switzerland_search[1:min(10, nrow(switzerland_search)),
                             c("id", "title", "frequency_short")])

    cat("\nFrequency distribution:\n")
    print(table(switzerland_search$frequency_short))
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 1.2 United States search
cat("1.2 Testing fredr_series_search_text() for 'United States'\n")
cat("------------------------------------------------------------\n")
tryCatch({
  us_search <- fredr_series_search_text(
    search_text = "United States",
    limit = 1000
  )

  cat("Total series found:", nrow(us_search), "\n")

  if (nrow(us_search) > 0) {
    cat("\nSample of first 10 series:\n")
    print(us_search[1:min(10, nrow(us_search)),
                   c("id", "title", "frequency_short")])

    cat("\nFrequency distribution:\n")
    print(table(us_search$frequency_short))
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 1.3 International/Global search
cat("1.3 Testing fredr_series_search_text() for 'International'\n")
cat("------------------------------------------------------------\n")
tryCatch({
  intl_search <- fredr_series_search_text(
    search_text = "International",
    limit = 1000
  )

  cat("Total series found:", nrow(intl_search), "\n")

  if (nrow(intl_search) > 0) {
    cat("\nSample of first 10 series:\n")
    print(intl_search[1:min(10, nrow(intl_search)),
                     c("id", "title", "frequency_short")])
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# ============================================================================
# 2. CATEGORY APPROACH
# ============================================================================
cat("2. CATEGORY APPROACH\n")
cat("====================\n\n")

# 2.1 Explore root categories
cat("2.1 Exploring root categories\n")
cat("------------------------------\n")
tryCatch({
  root_cats <- fredr_category_children(category_id = 0)
  cat("Root categories:\n")
  print(root_cats[, c("id", "name")])
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 2.2 Look for international/regional categories
cat("2.2 Searching for regional/international categories\n")
cat("-----------------------------------------------------\n")
tryCatch({
  # Try to find categories related to regions
  # Category 32992 is often "Regional Data" or similar
  regional_cats <- fredr_category_children(category_id = 32992)
  cat("Regional categories (if category 32992 exists):\n")
  print(regional_cats[, c("id", "name")])

  # Get series from a category to see what's available
  cat("\nGetting series from first regional category...\n")
  if (nrow(regional_cats) > 0) {
    sample_series <- fredr_category_series(
      category_id = regional_cats$id[1],
      limit = 10
    )
    cat("Sample series:\n")
    print(sample_series[, c("id", "title", "frequency_short")])
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 2.3 Try specific category for US data
cat("2.3 US-specific categories\n")
cat("--------------------------\n")
tryCatch({
  # Category 32255 is often "National" or US data
  us_cats <- fredr_category_children(category_id = 32255)
  cat("US categories (if category 32255 exists):\n")
  print(us_cats[, c("id", "name")])
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# ============================================================================
# 3. TAGS APPROACH
# ============================================================================
cat("3. TAGS APPROACH\n")
cat("================\n\n")

# 3.1 Search for Switzerland tag
cat("3.1 Testing fredr_tags() for Switzerland-related tags\n")
cat("-------------------------------------------------------\n")
tryCatch({
  # Search for tags containing "switzerland"
  swiss_tags <- fredr_tags(
    search_text = "switzerland",
    limit = 100
  )

  cat("Tags found:", nrow(swiss_tags), "\n")
  if (nrow(swiss_tags) > 0) {
    cat("Available tags:\n")
    print(swiss_tags)

    # Try to get series for the first tag
    if (nrow(swiss_tags) > 0) {
      cat("\nGetting series for first tag:", swiss_tags$name[1], "\n")
      tag_series <- fredr_tags_series(
        tag_names = swiss_tags$name[1],
        limit = 100
      )
      cat("Series found with this tag:", nrow(tag_series), "\n")
      if (nrow(tag_series) > 0) {
        cat("Sample:\n")
        print(tag_series[1:min(10, nrow(tag_series)),
                        c("id", "title", "frequency_short")])
      }
    }
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 3.2 Search for US/national tags
cat("3.2 Testing fredr_tags() for US-related tags\n")
cat("---------------------------------------------\n")
tryCatch({
  us_tags <- fredr_tags(
    search_text = "nation",
    limit = 100
  )

  cat("Tags found:", nrow(us_tags), "\n")
  if (nrow(us_tags) > 0) {
    cat("Sample tags:\n")
    print(head(us_tags, 10))
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 3.3 Search for international tags
cat("3.3 Testing fredr_tags() for international tags\n")
cat("------------------------------------------------\n")
tryCatch({
  intl_tags <- fredr_tags(
    search_text = "international",
    limit = 100
  )

  cat("Tags found:", nrow(intl_tags), "\n")
  if (nrow(intl_tags) > 0) {
    cat("Sample tags:\n")
    print(head(intl_tags, 10))
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# ============================================================================
# 4. COMBINED APPROACHES
# ============================================================================
cat("4. TESTING COMBINED SEARCH STRATEGIES\n")
cat("======================================\n\n")

# 4.1 Search for specific economic indicators by country
cat("4.1 Search for GDP by country\n")
cat("------------------------------\n")
tryCatch({
  # GDP Switzerland
  gdp_swiss <- fredr_series_search_text(
    search_text = "GDP Switzerland",
    limit = 50
  )
  cat("GDP Switzerland results:", nrow(gdp_swiss), "\n")
  if (nrow(gdp_swiss) > 0) {
    print(gdp_swiss[1:min(5, nrow(gdp_swiss)), c("id", "title", "frequency_short")])
  }
  cat("\n")

  # Unemployment Switzerland
  unemp_swiss <- fredr_series_search_text(
    search_text = "unemployment Switzerland",
    limit = 50
  )
  cat("Unemployment Switzerland results:", nrow(unemp_swiss), "\n")
  if (nrow(unemp_swiss) > 0) {
    print(unemp_swiss[1:min(5, nrow(unemp_swiss)), c("id", "title", "frequency_short")])
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# ============================================================================
# 5. SUMMARY RECOMMENDATIONS
# ============================================================================
cat("5. CREATING DATA FRAMES WITH RECOMMENDED APPROACH\n")
cat("==================================================\n\n")

# Helper function to create the desired output format
format_series_df <- function(series_df) {
  if (is.null(series_df) || nrow(series_df) == 0) {
    return(data.frame(
      id = character(0),
      title = character(0),
      frequency = character(0)
    ))
  }

  # Map frequency_short to full frequency names
  freq_map <- c(
    "D" = "Daily",
    "W" = "Weekly",
    "BW" = "Biweekly",
    "M" = "Monthly",
    "Q" = "Quarterly",
    "SA" = "Semiannual",
    "A" = "Annual"
  )

  data.frame(
    id = series_df$id,
    title = series_df$title,
    frequency = ifelse(
      series_df$frequency_short %in% names(freq_map),
      freq_map[series_df$frequency_short],
      series_df$frequency_short
    ),
    stringsAsFactors = FALSE
  )
}

# 5.1 Switzerland
cat("5.1 SWITZERLAND - Recommended approach\n")
cat("---------------------------------------\n")
tryCatch({
  switzerland_df <- fredr_series_search_text(
    search_text = "Switzerland",
    limit = 1000
  )
  switzerland_result <- format_series_df(switzerland_df)

  cat("Total series:", nrow(switzerland_result), "\n")
  cat("Sample (first 20):\n")
  print(head(switzerland_result, 20))

  # Save to CSV for reference
  write.csv(switzerland_result,
            "/Users/christophsax/git/blockr/blockr.fredr/dev/switzerland_series.csv",
            row.names = FALSE)
  cat("\nFull list saved to: dev/switzerland_series.csv\n")
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 5.2 Global/International
cat("5.2 GLOBAL/INTERNATIONAL - Recommended approach\n")
cat("------------------------------------------------\n")
tryCatch({
  # Try combining multiple search terms
  global_searches <- list(
    intl = fredr_series_search_text("International", limit = 1000),
    oecd = fredr_series_search_text("OECD", limit = 1000)
  )

  # Combine and deduplicate
  global_df <- do.call(rbind, global_searches)
  global_df <- global_df[!duplicated(global_df$id), ]
  global_result <- format_series_df(global_df)

  cat("Total series:", nrow(global_result), "\n")
  cat("Sample (first 20):\n")
  print(head(global_result, 20))

  # Save to CSV
  write.csv(global_result,
            "/Users/christophsax/git/blockr/blockr.fredr/dev/global_series.csv",
            row.names = FALSE)
  cat("\nFull list saved to: dev/global_series.csv\n")
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

# 5.3 US
cat("5.3 US - Recommended approach\n")
cat("------------------------------\n")
tryCatch({
  # For US, we might want key indicators rather than all series
  # Let's try a few approaches

  # Approach A: Search for "United States"
  us_search_df <- fredr_series_search_text("United States", limit = 1000)

  # Approach B: Key US economic indicators (curated list)
  key_indicators <- c(
    "UNRATE", "GDP", "CPIAUCSL", "FEDFUNDS", "DGS10",
    "PAYEMS", "INDPRO", "HOUST", "RSXFS", "PCE"
  )

  cat("Approach A: Search 'United States' - found", nrow(us_search_df), "series\n")
  cat("Approach B: Curated key indicators - ", length(key_indicators), "series\n")
  cat("\nUsing search approach...\n")

  us_result <- format_series_df(us_search_df)

  cat("Total series:", nrow(us_result), "\n")
  cat("Sample (first 20):\n")
  print(head(us_result, 20))

  # Save to CSV
  write.csv(us_result,
            "/Users/christophsax/git/blockr/blockr.fredr/dev/us_series.csv",
            row.names = FALSE)
  cat("\nFull list saved to: dev/us_series.csv\n")
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
cat("\n")

cat("\n=== RESEARCH COMPLETE ===\n")
cat("Check the CSV files in dev/ directory for full series lists\n")
