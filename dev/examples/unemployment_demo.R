# Simple Unemployment Rate Dashboard
# This example shows the basic usage of blockr.fredr to fetch and display
# unemployment rate data from FRED

library(blockr)
library(blockr.dag)
library(blockr.md)
pkgload::load_all()  # Load blockr.fredr from current directory

# Make sure your FRED API key is set:
# fredr::fredr_set_key("YOUR_FRED_API_KEY")
# Or add to ~/.Renviron: FRED_API_KEY=YOUR_FRED_API_KEY

# Demo workflow for FRED unemployment data
run_app(
  blocks = c(
    # Fetch unemployment rate from FRED
    unemployment = new_fred_block(
      series_id = "UNRATE",
      observation_start = as.Date("2010-01-01"),
      observation_end = Sys.Date()
    )
  ),
  extensions = list(
    new_dag_extension(),

    new_md_extension(
      content = c(
        "## FRED Unemployment Rate Dashboard\n\n",
        "This workflow demonstrates basic FRED data retrieval.\n\n",

        "### What this workflow does:\n\n",
        "1. Fetches unemployment rate data (UNRATE) from FRED\n",
        "2. Displays time series from 2010 to present\n\n",

        "### Try these features:\n\n",
        "- **Change series ID**: Try 'U6RATE' (broader unemployment measure)\n",
        "- **Adjust date range**: Use the date picker to focus on specific periods\n",
        "- **Explore other series**: See https://fred.stlouisfed.org/ for available series\n\n",

        "## Unemployment Data\n\n",
        "![](blockr://unemployment)\n\n"
      )
    )
  )
)
