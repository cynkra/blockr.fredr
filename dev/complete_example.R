# Complete Example: Fetching FRED Series for Three Categories
# This script demonstrates the recommended approach for each category

library(fredr)

# NOTE: Make sure your FRED API key is set before running
# fredr::fredr_set_key("YOUR_API_KEY")
# or set environment variable: FRED_API_KEY

cat("\n")
cat("========================================================================\n")
cat("         COMPLETE EXAMPLE: FETCHING FRED SERIES BY CATEGORY            \n")
cat("========================================================================\n")
cat("\n")

# Helper function to format results
format_series_df <- function(series_df) {
  if (is.null(series_df) || nrow(series_df) == 0) {
    return(data.frame(
      id = character(0),
      title = character(0),
      frequency = character(0)
    ))
  }

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

# ============================================================================
# 1. SWITZERLAND SERIES
# ============================================================================

cat("1. Fetching Switzerland Series\n")
cat("===============================\n")
cat("Method: fredr_tags_series(tag_names = 'switzerland') with pagination\n\n")

fetch_switzerland_series <- function(max_results = 10000) {
  all_series <- list()
  offset <- 0

  repeat {
    cat("  Fetching offset", offset, "...\n")
    batch <- fredr::fredr_tags_series(
      tag_names = "switzerland",
      limit = 1000,
      offset = offset
    )

    if (nrow(batch) == 0) break
    all_series[[length(all_series) + 1]] <- batch
    offset <- offset + 1000
    if (nrow(batch) < 1000 || offset >= max_results) break
  }

  combined <- do.call(rbind, all_series)
  combined[!duplicated(combined$id), ]
}

switzerland_raw <- fetch_switzerland_series()
switzerland <- format_series_df(switzerland_raw)

cat("\nResults:\n")
cat("  Total series:", nrow(switzerland), "\n")
cat("  Sample (first 5):\n")
print(head(switzerland, 5))
cat("\n")

# ============================================================================
# 2. GLOBAL/INTERNATIONAL SERIES
# ============================================================================

cat("2. Fetching Global/International Series\n")
cat("========================================\n")
cat("Method: Combine OECD + IMF tags + International search\n\n")

fetch_global_series <- function(max_per_source = 2000) {
  fetch_with_pagination <- function(tag = NULL, text = NULL, max = 2000) {
    all_series <- list()
    offset <- 0

    repeat {
      if (!is.null(tag)) {
        batch <- fredr::fredr_tags_series(
          tag_names = tag,
          limit = 1000,
          offset = offset
        )
      } else {
        batch <- fredr::fredr_series_search_text(
          search_text = text,
          limit = 1000,
          offset = offset
        )
      }

      if (nrow(batch) == 0) break
      all_series[[length(all_series) + 1]] <- batch
      offset <- offset + 1000
      if (nrow(batch) < 1000 || offset >= max) break
    }

    if (length(all_series) > 0) {
      do.call(rbind, all_series)
    } else {
      data.frame()
    }
  }

  cat("  Fetching OECD series...\n")
  oecd <- fetch_with_pagination(tag = "oecd", max = max_per_source)

  cat("  Fetching IMF series...\n")
  imf <- fetch_with_pagination(tag = "imf", max = max_per_source)

  cat("  Fetching International series...\n")
  intl <- fetch_with_pagination(text = "International", max = max_per_source)

  # Combine and deduplicate
  cat("  Combining and deduplicating...\n")
  combined <- rbind(oecd, imf, intl)
  combined[!duplicated(combined$id), ]
}

global_raw <- fetch_global_series()
global <- format_series_df(global_raw)

cat("\nResults:\n")
cat("  Total unique series:", nrow(global), "\n")
cat("  Sample (first 5):\n")
print(head(global, 5))
cat("\n")

# ============================================================================
# 3A. US SERIES - FULL APPROACH (LIMITED)
# ============================================================================

cat("3A. Fetching US Series - Full Approach (Limited)\n")
cat("=================================================\n")
cat("Method: fredr_tags_series(tag_names = 'usa') with limit\n")
cat("Note: Full tag has 672K+ series. Fetching first 5,000 only.\n\n")

fetch_us_series_full <- function(max_results = 5000) {
  all_series <- list()
  offset <- 0

  repeat {
    cat("  Fetching offset", offset, "...\n")
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
  combined[!duplicated(combined$id), ]
}

us_full_raw <- fetch_us_series_full()
us_full <- format_series_df(us_full_raw)

cat("\nResults:\n")
cat("  Total series (limited):", nrow(us_full), "\n")
cat("  Sample (first 5):\n")
print(head(us_full, 5))
cat("\n")

# ============================================================================
# 3B. US SERIES - CURATED APPROACH
# ============================================================================

cat("3B. Fetching US Series - Curated Key Indicators\n")
cat("================================================\n")
cat("Method: Hand-picked list of most important indicators\n\n")

fetch_us_key_indicators <- function() {
  # Curated list of most important US indicators
  key_ids <- c(
    # Labor Market
    "UNRATE",        # Unemployment Rate
    "PAYEMS",        # Nonfarm Payrolls
    "CIVPART",       # Labor Force Participation Rate

    # GDP & Growth
    "GDP",           # Gross Domestic Product
    "GDPC1",         # Real GDP
    "A191RL1Q225SBEA", # Real GDP growth

    # Inflation & Prices
    "CPIAUCSL",      # Consumer Price Index
    "PCEPI",         # PCE Price Index
    "CPILFESL",      # Core CPI

    # Monetary Policy
    "FEDFUNDS",      # Federal Funds Rate
    "DFF",           # Federal Funds Daily
    "DGS10",         # 10-Year Treasury Rate
    "DGS2",          # 2-Year Treasury Rate
    "T10Y2Y",        # 10Y-2Y Treasury Spread

    # Money Supply
    "M2SL",          # M2 Money Supply
    "M1SL",          # M1 Money Supply

    # Housing
    "HOUST",         # Housing Starts
    "MORTGAGE30US",  # 30-Year Mortgage Rate
    "CSUSHPISA",     # Case-Shiller Home Price Index

    # Consumer & Sentiment
    "PCE",           # Personal Consumption Expenditures
    "UMCSENT",       # Consumer Sentiment
    "RSXFS",         # Retail Sales

    # Business & Production
    "INDPRO",        # Industrial Production
    "CAPUTL",        # Capacity Utilization
    "ISRATIO",       # Inventories to Sales Ratio

    # Trade
    "BOPGSTB",       # Trade Balance
    "EXPGS",         # Exports
    "IMPGS"          # Imports
  )

  cat("  Fetching metadata for", length(key_ids), "key indicators...\n")

  series_list <- lapply(key_ids, function(id) {
    tryCatch({
      info <- fredr::fredr_series(series_id = id)
      data.frame(
        id = info$id,
        title = info$title,
        frequency_short = info$frequency_short,
        stringsAsFactors = FALSE
      )
    }, error = function(e) {
      cat("    Warning: Could not fetch", id, "\n")
      NULL
    })
  })

  do.call(rbind, series_list)
}

us_curated_raw <- fetch_us_key_indicators()
us_curated <- format_series_df(us_curated_raw)

cat("\nResults:\n")
cat("  Total curated indicators:", nrow(us_curated), "\n")
cat("  All indicators:\n")
print(us_curated)
cat("\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("========================================================================\n")
cat("SUMMARY\n")
cat("========================================================================\n\n")

summary_table <- data.frame(
  Category = c("Switzerland", "Global/International", "US (Full, Limited)", "US (Curated)"),
  Series_Count = c(
    nrow(switzerland),
    nrow(global),
    nrow(us_full),
    nrow(us_curated)
  ),
  Method = c(
    "Tag: switzerland",
    "Tags: oecd + imf + search",
    "Tag: usa (limited to 5K)",
    "Hand-picked key indicators"
  )
)

print(summary_table, row.names = FALSE)

cat("\n")
cat("DATA FRAMES CREATED:\n")
cat("  - switzerland: ", nrow(switzerland), " series\n")
cat("  - global: ", nrow(global), " series\n")
cat("  - us_full: ", nrow(us_full), " series\n")
cat("  - us_curated: ", nrow(us_curated), " series\n")
cat("\n")

cat("Each data.frame has columns: id, title, frequency\n")
cat("\n")

cat("NEXT STEPS:\n")
cat("  - Filter by frequency if needed (e.g., monthly only)\n")
cat("  - Use fredr::fredr() to fetch actual data for a series\n")
cat("  - Save to CSV or database for later use\n")
cat("\n")

cat("EXAMPLE - Fetch actual data for a series:\n")
cat("  data <- fredr::fredr(series_id = 'UNRATE')\n")
cat("  plot(data$date, data$value, type = 'l')\n")
cat("\n")

cat("========================================================================\n")
cat("For detailed documentation, see: dev/RESEARCH_SUMMARY.md\n")
cat("========================================================================\n")
cat("\n")
