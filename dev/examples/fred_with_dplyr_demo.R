# FRED Data with dplyr Transformations
# This example shows how to combine FRED data with blockr.dplyr transformations

library(blockr)
library(blockr.dag)
library(blockr.md)
library(blockr.dplyr)
pkgload::load_all()  # Load blockr.fredr from current directory

# Make sure your FRED API key is set:
# fredr::fredr_set_key("YOUR_FRED_API_KEY")

# Demo workflow: FRED → dplyr transformations
run_app(
  blocks = c(
    # 1. Fetch unemployment data from FRED
    data = new_fred_block(
      series_id = "UNRATE",
      observation_start = as.Date("2020-01-01")
    ),

    # 2. Add calculated columns
    mutated = new_mutate_block(
      exprs = list(
        year = "lubridate::year(date)",
        month = "lubridate::month(date, label = TRUE)",
        unemployment_pct = "value"
      )
    ),

    # 3. Filter to recent years
    filtered = new_filter_expr_block(
      exprs = list(
        recent = "year >= 2022"
      )
    )
  ),
  links = c(
    # Connect the data pipeline
    new_link("data", "mutated", "data"),
    new_link("mutated", "filtered", "data")
  ),
  extensions = list(
    new_dag_extension()
  )
)
