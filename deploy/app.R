# blockr.fredr Dashboard for shinyapps.io

library(blockr)
library(blockr.fredr)

# Set FRED API key from environment
# Make sure to set FRED_API_KEY as an environment variable in shinyapps.io settings
if (Sys.getenv("FRED_API_KEY") != "") {
  fredr::fredr_set_key(Sys.getenv("FRED_API_KEY"))
}

# Lock the dashboard to prevent moving panels around
options(blockr.dock_is_locked = FALSE)

# Serve the dashboard
serve("dashboard.json")
