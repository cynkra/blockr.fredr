# FRED API Research Summary

## Research Goal

Determine the best way to fetch FRED series data for three categories:
1. **Switzerland**: All series related to Switzerland
2. **Global/International**: Major international economic indicators
3. **US**: US-specific economic series

Each should return a data.frame with:
- `id` (series ID like "UNRATE")
- `title` (series description)
- `frequency` (Daily, Monthly, Quarterly, etc.)

---

## Functions Investigated

### 1. `fredr_series_search_text()`
- **How it works**: Full-text search across series titles and descriptions
- **Pros**: Simple, works for any search term
- **Cons**: Returns up to 1000 results per call (API limit), may include irrelevant results
- **Pagination**: Supported via `offset` parameter

### 2. `fredr_tags_series()`
- **How it works**: Returns series associated with specific FRED tags
- **Pros**: More focused/curated than text search, officially maintained by FRED
- **Cons**: Requires knowing tag names, still has 1000 result limit per call
- **Pagination**: Supported via `offset` parameter

### 3. `fredr_category_series()`
- **How it works**: Returns series within a specific category ID
- **Findings**: Category structure is complex and not well-suited for country/region filtering
- **Recommendation**: Not recommended for this use case

### 4. `fredr_tags()`
- **How it works**: Search for available tags
- **Use**: Useful for discovering tag names to use with `fredr_tags_series()`

---

## Recommended Approaches

### 1. Switzerland Series

**Recommended Function**: `fredr_tags_series(tag_names = "switzerland")`

**Reasoning**:
- Switzerland has an official 'switzerland' tag in FRED
- More focused than text search
- Returns 2,455 series (with pagination)
- Better quality filtering

**Results**:
- **Total series**: 2,455
- **Frequency breakdown**:
  - Annual: 946
  - Monthly: 494
  - Quarterly: 935
  - Daily: 76
  - 5-Year: 4

**Top series** (by popularity):
1. `DEXSZUS` - Swiss Francs to U.S. Dollar Spot Exchange Rate (Daily)
2. `IRLTLT01CHM156N` - Interest Rates: 10-Year Government Bond Yields (Monthly)
3. `CLVMNACSAB1GQCH` - Real GDP for Switzerland (Quarterly)
4. `EXSZUS` - Swiss Francs to U.S. Dollar Spot Exchange Rate (Monthly)
5. `IR3TIB01CHM156N` - Interest Rates: 3-Month Interbank Rates (Monthly)

**Sample R Code**:
```r
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
```

---

### 2. Global/International Series

**Recommended Approach**: **Combine multiple search strategies**

**Reasoning**:
- No single tag/search covers all global indicators
- Multiple sources provide comprehensive coverage:
  - OECD tag: International organization data
  - IMF tag: International Monetary Fund data
  - International search: General international indicators
- Combining and deduplicating gives best results

**Results**:
- **Total unique series**: 5,996
- **Source breakdown**:
  - OECD tag: 2,000 series
  - IMF tag: 2,000 series
  - International search: 2,000 series
  - After deduplication: 5,996 unique
- **Frequency breakdown**:
  - Annual: 3,654
  - Quarterly: 1,194
  - Monthly: 644
  - Daily: 500
  - Weekly: 4

**Sample R Code**:
```r
fetch_global_series <- function() {
  library(fredr)

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
```

---

### 3. United States Series

**Recommended Approach**: `fredr_tags_series(tag_names = "usa")` with limits, OR curated list

**Reasoning**:
- The 'usa' tag contains **672,590+ series** (massive!)
- More focused than "United States" text search
- Two viable strategies:
  1. **Full approach**: Fetch large subset with pagination (up to 10K-50K series)
  2. **Curated approach**: Hand-pick key economic indicators (~15-50 series)

**Results**:
- **Total series available**: 672,590+
- **Sample (first 5,000)**:
  - Annual: 4,260
  - Quarterly: 453
  - Monthly: 287

**Top series** (by popularity):
1. `A091RC1Q027SBEA` - Federal government expenditures (Quarterly)
2. `A191RL1Q225SBEA` - Real GDP (Quarterly)
3. `A229RX0` - Real Disposable Personal Income (Monthly)
4. `A191RI1Q225SBEA` - GDP Implicit Price Deflator (Quarterly)
5. `A191RP1Q027SBEA` - Gross Domestic Product (Quarterly)

**Sample R Code (Option 1 - Paginated approach)**:
```r
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

# Fetch first 10,000 series (or adjust max_results as needed)
us_series <- fetch_us_series_full(max_results = 10000)
```

**Sample R Code (Option 2 - Curated key indicators)**:
```r
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
```

---

## Challenges and Limitations

### 1. API Limit (1000 per call)
- **Challenge**: FRED API returns maximum 1000 results per call
- **Solution**: Use `offset` parameter for pagination
- **Impact**: Need multiple API calls for comprehensive results

### 2. Massive US Series Count
- **Challenge**: 672K+ series with 'usa' tag is impractical for dropdowns
- **Solutions**:
  - Limit to first N thousand results (filtered by popularity)
  - Use curated list of key indicators
  - Implement search/filter within category
  - Allow users to specify subcategories (employment, GDP, etc.)

### 3. Series Variants
- **Challenge**: Many series have multiple variants
  - Different frequencies (daily, monthly, quarterly)
  - Seasonal adjustments vs non-adjusted
  - Different calculation methods
- **Solution**: May want to filter or group by frequency/adjustment type

### 4. Search Quality
- **Challenge**: Text search can return irrelevant results
- **Solution**: Tags are more reliable than free-text search when available

### 5. No Geographic Hierarchy
- **Challenge**: FRED doesn't have a clean category structure for countries/regions
- **Solution**: Tags work better than categories for geographic filtering

---

## Best Practices

1. **Use tags when available** (switzerland, usa, oecd, imf)
   - More reliable than text search
   - Officially curated by FRED

2. **Implement pagination for complete results**
   - Use `offset` parameter
   - Loop until fewer than 1000 results returned

3. **Filter by popularity for better UX**
   - Most FRED series have a `popularity` field
   - Sort by popularity to surface most relevant series

4. **Allow frequency filtering**
   - Let users filter by Daily, Monthly, Quarterly, etc.
   - Reduces overwhelming number of options

5. **For large result sets, consider**:
   - Curated lists of key indicators
   - Search within category
   - Lazy loading / pagination in UI

---

## Approximate Series Counts

| Category | Recommended Approach | Approximate Count |
|----------|---------------------|-------------------|
| Switzerland | `fredr_tags_series(tag_names = "switzerland")` | 2,455 |
| Global/International | Combine OECD + IMF + International | 5,996 |
| US | `fredr_tags_series(tag_names = "usa")` | 672,590+ (recommend limiting) |

---

## Output Files

All results saved to CSV files in `/Users/christophsax/git/blockr/blockr.fredr/dev/`:
- `switzerland_final.csv` - 2,455 Switzerland series
- `global_final.csv` - 5,996 global/international series
- `us_final.csv` - 5,000 US series (sample)

---

## Testing Scripts

Research scripts available in `/Users/christophsax/git/blockr/blockr.fredr/dev/`:
1. `research_fredr_approaches.R` - Initial exploration
2. `test_tags_approach.R` - Tag-based approach testing
3. `test_pagination.R` - Pagination testing
4. `final_recommendations.R` - Complete implementation (RUN THIS)

To reproduce results:
```bash
cd /Users/christophsax/git/blockr/blockr.fredr
Rscript dev/final_recommendations.R
```

---

## Conclusion

### Switzerland
✅ Use `fredr_tags_series(tag_names = "switzerland")` with pagination
- Clean, focused results (2,455 series)
- Well-curated tag

### Global/International
✅ Combine OECD + IMF tags + International search
- Comprehensive coverage (5,996 unique series)
- Multiple sources ensure broad coverage

### US
✅ Two options:
1. **Full**: `fredr_tags_series(tag_names = "usa")` with limits (recommend 10K max)
2. **Curated**: Hand-picked list of 15-50 key indicators

For most use cases, the curated approach is recommended for US due to the massive number of series available.
