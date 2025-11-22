#!/usr/bin/env Rscript
# Test the new series selector with category filtering
# This demo showcases the multi-column selectize UI with category checkboxes

library(blockr)
library(blockr.dag)
pkgload::load_all()  # Load blockr.fredr from current directory

# Make sure your FRED API key is set:
# fredr::fredr_set_key("YOUR_FRED_API_KEY")
# Or add to ~/.Renviron: FRED_API_KEY=YOUR_FRED_API_KEY

# Option 1: Create a FRED block from scratch
run_app(
  blocks = c(
    # Create FRED block with default series
    data = new_fred_block(
      series_id = "UNRATE"  # Start with unemployment rate
    )
  ),
  extensions = list(
    new_dag_extension()
  )
)

# Option 2: Load dashboard from JSON file
# After saving your dashboard using the Save button in the UI,
# you can load it directly:
# serve("path/to/your/saved_dashboard.json")

# Features to test:
# 1. Category checkboxes: Try checking/unchecking Global, Switzerland, US
# 2. Series search: Type to search by ID or description
# 3. Multi-column display: See ID | Title | Frequency in dropdown
# 4. Performance: Check the US category (5,000 series) - should be fast
# 5. Combination: Select multiple categories to see combined results
