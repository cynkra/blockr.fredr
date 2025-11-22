# blockr.fredr Dashboard Deployment

This directory contains everything needed to deploy the blockr.fredr dashboard to shinyapps.io.

## Files

- `app.R` - Main Shiny application
- `dashboard.json` - Dashboard configuration
- `DESCRIPTION` - Package dependencies (including GitHub sources)
- `setup-shinyapps.R` - One-time setup for shinyapps.io credentials
- `deploy.R` - Deployment script

## Deployment Steps

### 1. Configure shinyapps.io Credentials (One-time)

```r
# In R console, from the deploy/ directory:
source("setup-shinyapps.R")

# Then uncomment and run the rsconnect::setAccountInfo() command
# with your credentials from https://www.shinyapps.io/
```

### 2. Deploy the Application

```r
# From the deploy/ directory:
source("deploy.R")
```

This will:
- Deploy the app to shinyapps.io
- Print instructions for setting the FRED_API_KEY

### 3. Configure FRED API Key on shinyapps.io

After deployment:
1. Go to https://www.shinyapps.io/admin/#/applications
2. Click on `blockr-fredr-dashboard`
3. Go to **Settings** → **Variables**
4. Add environment variable:
   - **Name**: `FRED_API_KEY`
   - **Value**: Your FRED API key
5. Click **Save**
6. Restart the application

## Testing Locally

Before deploying, you can test the app locally:

```r
# From the deploy/ directory:
shiny::runApp()
```

## Troubleshooting

**Problem**: Packages not installing on shinyapps.io
- **Solution**: Make sure all GitHub packages in `DESCRIPTION` are public and accessible

**Problem**: FRED API errors
- **Solution**: Verify FRED_API_KEY is set correctly in shinyapps.io environment variables

**Problem**: Dashboard not loading
- **Solution**: Check the logs in shinyapps.io dashboard for errors

## Architecture

The deployment uses:
- GitHub packages from `cynkra` organization
- FRED API for economic data
- blockr framework for modular data visualization
