# Developer Documentation - blockr.fredr

This folder contains developer documentation for blockr.fredr. These files are **not** included in the package build (excluded via `.Rbuildignore`).

## What's Here

### Quick Start

The blockr.fredr package provides FRED (Federal Reserve Economic Data) blocks for blockr.core. This is a **data source package**, not a transformation package like blockr.dplyr.

**Prerequisites:**
- Get a free FRED API key: https://fredaccount.stlouisfed.org/apikeys
- Set it via `fredr::fredr_set_key("YOUR_KEY")` or add `FRED_API_KEY=YOUR_KEY` to `~/.Renviron`

### Example Workflows

The `examples/` folder contains complete runnable workflows demonstrating blockr.fredr usage:

- **[unemployment_demo.R](examples/unemployment_demo.R)** - Simple unemployment rate dashboard
- **[economic_indicators_demo.R](examples/economic_indicators_demo.R)** - Compare multiple economic indicators
- **[fred_with_dplyr_demo.R](examples/fred_with_dplyr_demo.R)** - Combine FRED data with dplyr transformations

### Running Examples

```r
# From the blockr monorepo
devtools::load_all("blockr.fredr")
source("blockr.fredr/dev/examples/unemployment_demo.R")
```

## Package Structure

### FRED Block

The package provides a single block type:

```r
new_fred_block(
  series_id = "UNRATE",              # FRED series ID
  observation_start = NULL,          # Start date (defaults to 10 years ago)
  observation_end = NULL             # End date (defaults to today)
)
```

**Common FRED Series IDs:**
- `UNRATE` - Unemployment Rate
- `GDP` - Gross Domestic Product
- `CPIAUCSL` - Consumer Price Index
- `FEDFUNDS` - Federal Funds Rate
- `DGS10` - 10-Year Treasury Rate

Full catalog: https://fred.stlouisfed.org/

### Block Features

1. **Dynamic Series Selection** - UI allows changing series ID on the fly
2. **Date Range Picker** - Select observation period interactively
3. **API Key Validation** - Warns if API key not configured
4. **Auto-Registration** - Block registers automatically when package loads

## Development Workflow

### Adding New Features

1. **Modify the block** - Edit `R/fred-block.R`
2. **Update tests** - Add tests in `tests/testthat/test-fred-block.R`
3. **Document** - Update roxygen comments
4. **Check** - Run `devtools::check()`

### Testing

```r
# Load package
devtools::load_all()

# Run tests
devtools::test()

# Interactive testing
serve(new_fred_block("UNRATE"))
```

### Key Principles

1. **Data Source Block** - This is a `data_block`, not a `transform_block`
2. **External API** - Requires internet connection and valid API key
3. **Rate Limits** - FRED API has rate limits; cache data when developing
4. **Error Handling** - Let blockr.core framework handle API errors (use `req()`)

## Related Packages

- **blockr.core** - Core framework and block infrastructure
- **blockr.dplyr** - Data transformation blocks (good to combine with FRED data)
- **blockr.ggplot** - Visualization blocks (great for plotting economic trends)
- **fredr** - Underlying FRED API client (see: https://github.com/sboysel/fredr)

## Resources

- **FRED Website:** https://fred.stlouisfed.org/
- **FRED API Docs:** https://fred.stlouisfed.org/docs/api/fred/
- **fredr Package:** https://github.com/sboysel/fredr
- **blockr.core Vignettes:** https://blockr-org.github.io/blockr.core/

## Common Use Cases

### 1. Economic Dashboard
Fetch multiple indicators and visualize trends over time.

### 2. Data Analysis Pipeline
Use FRED as input → transform with blockr.dplyr → visualize with blockr.ggplot

### 3. Comparative Analysis
Compare different economic metrics (e.g., unemployment vs GDP growth)

### 4. Time Series Analysis
Extract FRED data for econometric modeling

## Tips

- **Cache API responses** during development to avoid hitting rate limits
- **Use meaningful series IDs** - FRED has thousands of series
- **Check data availability** - Some series have limited historical data
- **Handle missing values** - Economic data often has gaps
