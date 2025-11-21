# Multiple Economic Indicators Dashboard
# This example demonstrates fetching and comparing multiple FRED series

library(blockr)
library(blockr.dag)
library(blockr.md)
pkgload::load_all()  # Load blockr.fredr from current directory

# Make sure your FRED API key is set:
# fredr::fredr_set_key("YOUR_FRED_API_KEY")

# Demo workflow with multiple economic indicators
run_app(
  blocks = c(
    # Unemployment rate
    unemployment = new_fred_block(
      series_id = "UNRATE",
      observation_start = as.Date("2015-01-01")
    ),

    # GDP
    gdp = new_fred_block(
      series_id = "GDP",
      observation_start = as.Date("2015-01-01")
    ),

    # Consumer Price Index (inflation)
    cpi = new_fred_block(
      series_id = "CPIAUCSL",
      observation_start = as.Date("2015-01-01")
    ),

    # Federal Funds Rate
    fed_funds = new_fred_block(
      series_id = "FEDFUNDS",
      observation_start = as.Date("2015-01-01")
    ),

    # 10-Year Treasury Rate
    treasury = new_fred_block(
      series_id = "DGS10",
      observation_start = as.Date("2015-01-01")
    )
  ),
  extensions = list(
    new_dag_extension(),

    new_md_extension(
      content = c(
        "## Multiple Economic Indicators Dashboard\n\n",
        "This workflow demonstrates fetching multiple FRED series simultaneously.\n\n",

        "### Data Sources:\n\n",
        "Each block fetches a different economic indicator from FRED:\n\n",
        "- **UNRATE**: Unemployment Rate\n",
        "- **GDP**: Gross Domestic Product\n",
        "- **CPIAUCSL**: Consumer Price Index (inflation measure)\n",
        "- **FEDFUNDS**: Federal Funds Effective Rate\n",
        "- **DGS10**: 10-Year Treasury Constant Maturity Rate\n\n",

        "### Compare Trends:\n\n",
        "View each indicator side-by-side to observe economic relationships:\n",
        "- How does unemployment relate to Fed policy?\n",
        "- What's the relationship between inflation and interest rates?\n",
        "- How do treasury yields respond to economic changes?\n\n",

        "## Unemployment Rate\n\n",
        "![](blockr://unemployment)\n\n",

        "## GDP Growth\n\n",
        "![](blockr://gdp)\n\n",

        "## Consumer Price Index\n\n",
        "![](blockr://cpi)\n\n",

        "## Federal Funds Rate\n\n",
        "![](blockr://fed_funds)\n\n",

        "## 10-Year Treasury Rate\n\n",
        "![](blockr://treasury)\n\n"
      )
    )
  )
)
