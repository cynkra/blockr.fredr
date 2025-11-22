# Final Recommendations for Fetching FRED Series Data
# Based on comprehensive testing of fredr package functions

library(fredr)

cat("\n")
cat("========================================================================\n")
cat("  RECOMMENDED APPROACHES FOR FETCHING FRED SERIES BY CATEGORY\n")
cat("========================================================================\n")
cat("\n")

# Helper function to format series data
format_series_df <- function(series_df) {
  if (is.null(series_df) || nrow(series_df) == 0) {
    return(data.frame(
      id = character(0),
      title = character(0),
      frequency = character(0)
    ))
  }

  # Map frequency_short to full names
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

# Helper function to fetch with pagination
fetch_all_series <- function(search_text = NULL, tag_names = NULL, max_results = 10000) {
  all_series <- list()
  offset <- 0
  limit <- 1000

  repeat {
    if (!is.null(search_text)) {
      batch <- fredr_series_search_text(
        search_text = search_text,
        limit = limit,
        offset = offset
      )
    } else if (!is.null(tag_names)) {
      batch <- fredr_tags_series(
        tag_names = tag_names,
        limit = limit,
        offset = offset
      )
    } else {
      stop("Must provide either search_text or tag_names")
    }

    if (nrow(batch) == 0) break

    all_series[[length(all_series) + 1]] <- batch
    offset <- offset + limit

    cat("  Fetched", offset, "series so far...\n")

    # Stop if we've reached max or got fewer than requested (last page)
    if (nrow(batch) < limit || offset >= max_results) break
  }

  if (length(all_series) > 0) {
    combined <- do.call(rbind, all_series)
    combined[!duplicated(combined$id), ]
  } else {
    data.frame()
  }
}

cat("========================================================================\n")
cat("1. SWITZERLAND SERIES\n")
cat("========================================================================\n\n")

cat("RECOMMENDED APPROACH: fredr_tags_series() with 'switzerland' tag\n")
cat("REASONING:\n")
cat("  - More focused than text search\n")
cat("  - Tag is officially curated by FRED\n")
cat("  - Returns 2000+ Switzerland-specific series with pagination\n")
cat("  - Better quality filtering than free-text search\n\n")

cat("Fetching Switzerland series using tag approach...\n")
switzerland_df <- fetch_all_series(tag_names = "switzerland", max_results = 5000)
switzerland_result <- format_series_df(switzerland_df)

cat("\nRESULTS:\n")
cat("  Total series:", nrow(switzerland_result), "\n")
cat("  Frequency breakdown:\n")
print(table(switzerland_result$frequency))

cat("\n  Top 15 most popular series:\n")
if ("popularity" %in% names(switzerland_df)) {
  top_swiss <- switzerland_df[order(-switzerland_df$popularity), ]
  print(top_swiss[1:15, c("id", "title", "popularity", "frequency_short")])
}

write.csv(switzerland_result,
          "/Users/christophsax/git/blockr/blockr.fredr/dev/switzerland_final.csv",
          row.names = FALSE)
cat("\n  Saved to: dev/switzerland_final.csv\n")

cat("\n")

# SAMPLE R CODE
cat("SAMPLE R CODE:\n")
cat("---------------------------------------------------------------------\n")
cat('
# Fetch all Switzerland series
fetch_switzerland_series <- function() {
  library(fredr)

  # Fetch using pagination
  all_series <- list()
  offset <- 0

  repeat {
    batch <- fredr::fredr_tags_series(
      tag_names = "switzerland",
      limit = 1000,
      offset = offset
    )

    if (nrow(batch) == 0) break
    all_series[[length(all_series) + 1]] <- batch
    offset <- offset + 1000
    if (nrow(batch) < 1000) break  # Last page
  }

  # Combine and format
  combined <- do.call(rbind, all_series)
  combined <- combined[!duplicated(combined$id), ]

  data.frame(
    id = combined$id,
    title = combined$title,
    frequency = combined$frequency_short,
    stringsAsFactors = FALSE
  )
}

switzerland_series <- fetch_switzerland_series()
')
cat("---------------------------------------------------------------------\n\n")

cat("========================================================================\n")
cat("2. GLOBAL/INTERNATIONAL SERIES\n")
cat("========================================================================\n\n")

cat("RECOMMENDED APPROACH: Combine multiple search strategies\n")
cat("REASONING:\n")
cat("  - No single tag/search covers all global indicators\n")
cat("  - Multiple searches capture different aspects:\n")
cat("    * International organizations (OECD, IMF)\n")
cat("    * Country-specific data (major economies)\n")
cat("    * Global economic indicators\n")
cat("  - Combine and deduplicate for comprehensive list\n\n")

cat("Fetching global/international series...\n")

# Strategy: Combine multiple targeted searches
global_searches <- list()

cat("  Fetching OECD series...\n")
global_searches$oecd <- fetch_all_series(tag_names = "oecd", max_results = 2000)

cat("  Fetching IMF series...\n")
global_searches$imf <- fetch_all_series(tag_names = "imf", max_results = 2000)

cat("  Fetching general international series...\n")
global_searches$international <- fetch_all_series(
  search_text = "International",
  max_results = 2000
)

# Combine and deduplicate
cat("\nCombining and deduplicating...\n")
global_df <- do.call(rbind, global_searches)
global_df <- global_df[!duplicated(global_df$id), ]
global_result <- format_series_df(global_df)

cat("\nRESULTS:\n")
cat("  Total unique series:", nrow(global_result), "\n")
cat("  Series from each source:\n")
cat("    - OECD tag:", nrow(global_searches$oecd), "\n")
cat("    - IMF tag:", nrow(global_searches$imf), "\n")
cat("    - International search:", nrow(global_searches$international), "\n")
cat("  Frequency breakdown:\n")
print(table(global_result$frequency))

write.csv(global_result,
          "/Users/christophsax/git/blockr/blockr.fredr/dev/global_final.csv",
          row.names = FALSE)
cat("\n  Saved to: dev/global_final.csv\n")

cat("\n")

# SAMPLE R CODE
cat("SAMPLE R CODE:\n")
cat("---------------------------------------------------------------------\n")
cat('
# Fetch global/international series
fetch_global_series <- function() {
  library(fredr)

  fetch_with_pagination <- function(tag = NULL, text = NULL, max = 2000) {
    all_series <- list()
    offset <- 0

    repeat {
      if (!is.null(tag)) {
        batch <- fredr::fredr_tags_series(tag_names = tag, limit = 1000, offset = offset)
      } else {
        batch <- fredr::fredr_series_search_text(search_text = text, limit = 1000, offset = offset)
      }

      if (nrow(batch) == 0) break
      all_series[[length(all_series) + 1]] <- batch
      offset <- offset + 1000
      if (nrow(batch) < 1000 || offset >= max) break
    }

    if (length(all_series) > 0) do.call(rbind, all_series) else data.frame()
  }

  # Combine multiple sources
  oecd <- fetch_with_pagination(tag = "oecd")
  imf <- fetch_with_pagination(tag = "imf")
  intl <- fetch_with_pagination(text = "International")

  # Deduplicate
  combined <- rbind(oecd, imf, intl)
  combined <- combined[!duplicated(combined$id), ]

  data.frame(
    id = combined$id,
    title = combined$title,
    frequency = combined$frequency_short,
    stringsAsFactors = FALSE
  )
}

global_series <- fetch_global_series()
')
cat("---------------------------------------------------------------------\n\n")

cat("========================================================================\n")
cat("3. UNITED STATES SERIES\n")
cat("========================================================================\n\n")

cat("RECOMMENDED APPROACH: Use 'usa' tag\n")
cat("REASONING:\n")
cat("  - The 'usa' tag has 672,590 series (most comprehensive)\n")
cat("  - More focused than 'United States' text search\n")
cat("  - Officially curated by FRED\n")
cat("  - Alternative: Curated list of key indicators for smaller, focused set\n\n")

cat("Note: Full 'usa' tag has 672K+ series - fetching first 5000 for demo...\n")
us_df <- fetch_all_series(tag_names = "usa", max_results = 5000)
us_result <- format_series_df(us_df)

cat("\nRESULTS:\n")
cat("  Total series (sampled):", nrow(us_result), "\n")
cat("  Full tag contains ~672,590 series\n")
cat("  Frequency breakdown (sample):\n")
print(table(us_result$frequency))

cat("\n  Top 20 most popular US series:\n")
if ("popularity" %in% names(us_df)) {
  top_us <- us_df[order(-us_df$popularity), ]
  print(top_us[1:20, c("id", "title", "popularity", "frequency_short")])
}

write.csv(us_result,
          "/Users/christophsax/git/blockr/blockr.fredr/dev/us_final.csv",
          row.names = FALSE)
cat("\n  Saved to: dev/us_final.csv\n")

cat("\n")

# SAMPLE R CODE
cat("SAMPLE R CODE (Option 1 - Full tag):\n")
cat("---------------------------------------------------------------------\n")
cat('
# Fetch all US series (WARNING: 672K+ series!)
fetch_us_series_full <- function(max_results = 10000) {
  library(fredr)

  all_series <- list()
  offset <- 0

  repeat {
    batch <- fredr::fredr_tags_series(
      tag_names = "usa",
      limit = 1000,
      offset = offset
    )

    if (nrow(batch) == 0) break
    all_series[[length(all_series) + 1]] <- batch
    offset <- offset + 1000
    if (nrow(batch) < 1000 || offset >= max_results) break
  }

  combined <- do.call(rbind, all_series)
  combined <- combined[!duplicated(combined$id), ]

  data.frame(
    id = combined$id,
    title = combined$title,
    frequency = combined$frequency_short,
    stringsAsFactors = FALSE
  )
}

# Limit to first 10,000 series
us_series <- fetch_us_series_full(max_results = 10000)
')
cat("---------------------------------------------------------------------\n\n")

cat("SAMPLE R CODE (Option 2 - Curated key indicators):\n")
cat("---------------------------------------------------------------------\n")
cat('
# Fetch curated list of key US economic indicators
fetch_us_key_indicators <- function() {
  library(fredr)

  # Curated list of most important US indicators
  key_ids <- c(
    "UNRATE",        # Unemployment Rate
    "GDP",           # Gross Domestic Product
    "CPIAUCSL",      # Consumer Price Index
    "FEDFUNDS",      # Federal Funds Rate
    "DGS10",         # 10-Year Treasury Rate
    "PAYEMS",        # Nonfarm Payrolls
    "INDPRO",        # Industrial Production
    "HOUST",         # Housing Starts
    "RSXFS",         # Retail Sales
    "PCE",           # Personal Consumption Expenditures
    "M2SL",          # M2 Money Supply
    "UMCSENT",       # Consumer Sentiment
    "DFF",           # Federal Funds Daily
    "T10Y2Y",        # 10Y-2Y Treasury Spread
    "MORTGAGE30US"   # 30-Year Mortgage Rate
  )

  # Fetch metadata for each series
  series_list <- lapply(key_ids, function(id) {
    tryCatch({
      info <- fredr::fredr_series(series_id = id)
      data.frame(
        id = info$id,
        title = info$title,
        frequency = info$frequency_short,
        stringsAsFactors = FALSE
      )
    }, error = function(e) NULL)
  })

  do.call(rbind, series_list)
}

us_key_series <- fetch_us_key_indicators()
')
cat("---------------------------------------------------------------------\n\n")

cat("========================================================================\n")
cat("SUMMARY AND RECOMMENDATIONS\n")
cat("========================================================================\n\n")

cat("APPROACH SUMMARY:\n")
cat("-----------------\n")
cat("1. Switzerland: fredr_tags_series(tag_names = \'switzerland\')\n")
cat("   - ~2000+ series\n")
cat("   - Well-curated, focused on Switzerland\n\n")

cat("2. Global: Combine multiple tag/search strategies\n")
cat("   - OECD tag + IMF tag + International search\n")
cat("   - ~5000+ unique series\n")
cat("   - Comprehensive coverage of international data\n\n")

cat("3. US: fredr_tags_series(tag_names = \'usa\')\n")
cat("   - 672K+ series available (use pagination or limit)\n")
cat("   - Alternative: Curated list of ~15-50 key indicators\n\n")

cat("CHALLENGES DISCOVERED:\n")
cat("----------------------\n")
cat("1. API Limit: 1000 series per call (solved with pagination)\n")
cat("2. US series count is huge (672K+) - may need filtering or curated lists\n")
cat("3. Some series have multiple variants (different frequencies, seasonal adj.)\n")
cat("4. Search quality varies - tags are more reliable than free text\n")
cat("5. No category hierarchy for easy regional/country filtering\n\n")

cat("BEST PRACTICES:\n")
cat("---------------\n")
cat("1. Use tags when available (switzerland, usa, oecd, imf)\n")
cat("2. Implement pagination for complete results\n")
cat("3. Consider filtering by popularity for better user experience\n")
cat("4. Allow users to filter by frequency (Monthly, Quarterly, etc.)\n")
cat("5. For large result sets (US), consider curated lists or search\n\n")

cat("========================================================================\n")
cat("All results saved to dev/ directory:\n")
cat("  - switzerland_final.csv\n")
cat("  - global_final.csv\n")
cat("  - us_final.csv\n")
cat("========================================================================\n\n")
