# blockr.fredr

FRED data blocks for blockr.

## Installation

```r
# from the monorepo
devtools::load_all("/Users/christophsax/git/blockr/blockr.fredr")

# or install if split out
# remotes::install_github("<org>/blockr.fredr")
```

## Setup

Set your FRED API key (one-time per session) or via `.Renviron`:
```r
fredr::fredr_set_key("YOUR_FRED_API_KEY")
# or persistently: add FRED_API_KEY=YOUR_FRED_API_KEY to ~/.Renviron
```

## Minimal example (with blockr.ui)

```r
library(blockr.core)
library(blockr.fredr)
library(blockr.ui)
library(blockr.ai)

# Build a dashboard board and insert a FRED block
bd <- blockr.ui::new_dag_board(
  blocks = c(
    a = new_fred_block("UNRATE")
  )
)

# Launch the UI
blockr.core::serve(bd)
```

The block UI lets you change the FRED series ID and the date range. The result table displays the `fredr` tibble.

## Generated code
Use the code plugin to see the R code for your pipeline:
```r
# In the UI, click the code button, or programmatically:
blockr.core::export_code(
  expressions = list(a = quote(fredr::fredr(series_id = "UNRATE"))),
  board = bd
)
```

## Notes
- The package auto-registers its blocks on load.
- API key detection supports `Sys.getenv("FRED_API_KEY")`, `options(fredr.key=...)`, and `fredr::fredr_has_key()`.
