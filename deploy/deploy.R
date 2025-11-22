# Deployment script for blockr.fredr dashboard to shinyapps.io
#
# Prerequisites:
# 1. Run setup-shinyapps.R first to configure your credentials
# 2. Set FRED_API_KEY environment variable on shinyapps.io (see instructions below)

library(rsconnect)

# Check if account is configured
accounts <- rsconnect::accounts()
if (nrow(accounts) == 0) {
  stop("No shinyapps.io account configured. Please run setup-shinyapps.R first.")
}

cat("Deploying to account:", accounts$name[1], "\n")

# Deploy the application
rsconnect::deployApp(
  appDir = ".",
  appName = "blockr-fredr-dashboard",
  account = accounts$name[1],
  forceUpdate = TRUE
)

cat("\n=== IMPORTANT: Set FRED_API_KEY on shinyapps.io ===\n")
cat("After deployment completes:\n")
cat("1. Go to https://www.shinyapps.io/admin/#/applications\n")
cat("2. Click on 'blockr-fredr-dashboard'\n")
cat("3. Go to Settings -> Variables\n")
cat("4. Add a new variable:\n")
cat("   Name: FRED_API_KEY\n")
cat("   Value: Your FRED API key from ~/.Renviron\n")
cat("5. Click 'Save' and restart the application\n")
cat("\nYour FRED_API_KEY from .Renviron is: ", Sys.getenv("FRED_API_KEY"), "\n")
