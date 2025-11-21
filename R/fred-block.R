#' FRED data block
#'
#' A data-import block that retrieves a FRED time series via `fredr::fredr()`.
#' Make sure a FRED API key is set (see `fredr::fredr_set_key()` or environment
#' variable `FRED_API_KEY`).
#'
#' @param series_id FRED series ID (e.g., "UNRATE" for unemployment rate,
#'   "GDP" for gross domestic product, "CPIAUCSL" for consumer price index)
#' @param observation_start,observation_end Optional date range for data retrieval.
#'   Defaults to last 10 years if not specified.
#' @param frequency Optional frequency aggregation. One of: "d" (daily), "w" (weekly),
#'   "bw" (biweekly), "m" (monthly), "q" (quarterly), "sa" (semiannual), "a" (annual).
#'   NULL (default) uses the original data frequency.
#' @param aggregation_method Method for aggregating observations when frequency is specified.
#'   One of: "avg" (average, default), "sum", "eop" (end of period).
#' @param ... Forwarded to [blockr.core::new_data_block()]
#'
#' @details
#' Common FRED series IDs:
#' \itemize{
#'   \item \code{UNRATE} - Unemployment Rate
#'   \item \code{GDP} - Gross Domestic Product
#'   \item \code{CPIAUCSL} - Consumer Price Index
#'   \item \code{FEDFUNDS} - Federal Funds Rate
#'   \item \code{DGS10} - 10-Year Treasury Rate
#' }
#'
#' See \url{https://fred.stlouisfed.org/} for available series.
#'
#' @examples
#' # Create a FRED block for unemployment data
#' new_fred_block(series_id = "UNRATE")
#'
#' if (interactive()) {
#'   library(blockr.core)
#'   library(blockr.fredr)
#'
#'   # Basic usage - fetch unemployment rate
#'   serve(new_fred_block(series_id = "UNRATE"))
#'
#'   # Custom date range
#'   serve(
#'     new_fred_block(
#'       series_id = "GDP",
#'       observation_start = as.Date("2020-01-01"),
#'       observation_end = as.Date("2023-12-31")
#'     )
#'   )
#'
#'   # Multiple series comparison
#'   serve(
#'     new_board(
#'       blocks = list(
#'         unrate = new_fred_block(series_id = "UNRATE"),
#'         gdp = new_fred_block(series_id = "GDP")
#'       )
#'     )
#'   )
#' }
#'
#' @export
new_fred_block <- function(
  series_id = "UNRATE",
  observation_start = NULL,
  observation_end = NULL,
  frequency = NULL,
  aggregation_method = "avg",
  ...
) {
  # Set default date range if not provided
  if (is.null(observation_start)) {
    observation_start <- as.Date(Sys.Date() - 365 * 10)
  }
  if (is.null(observation_end)) {
    observation_end <- Sys.Date()
  }

  ui <- function(id) {
    tagList(
      shinyjs::useShinyjs(),
      css_responsive_grid(),
      css_single_column("fred"),

      div(
        class = "block-container fred-block-container",

        div(
          class = "block-form-grid",

          # Main section
          div(
            class = "block-section",
            div(
              class = "block-section-grid",

              # Help text with FRED documentation link
              div(
                class = "block-help-text",
                p(
                  "Fetch economic time series data from FRED. ",
                  tags$a(
                    href = "https://fred.stlouisfed.org/",
                    target = "_blank",
                    style = "text-decoration: none; font-size: 0.9em;",
                    "FRED Documentation \u2197"
                  )
                )
              ),

              # Series ID input
              div(
                class = "block-input-wrapper",
                textInput(
                  inputId = NS(id, "series_id"),
                  label = "FRED Series ID",
                  value = series_id,
                  width = "100%",
                  placeholder = "e.g., UNRATE, GDP, CPIAUCSL"
                )
              ),

              # Date range input
              div(
                class = "block-input-wrapper",
                dateRangeInput(
                  inputId = NS(id, "dates"),
                  label = "Date Range",
                  start = observation_start,
                  end = observation_end,
                  startview = "year",
                  width = "100%"
                )
              ),

              # Frequency input
              div(
                class = "block-input-wrapper",
                selectInput(
                  inputId = NS(id, "frequency"),
                  label = "Frequency",
                  choices = c(
                    "Original (no aggregation)" = "(none)",
                    "Daily" = "d",
                    "Weekly" = "w",
                    "Biweekly" = "bw",
                    "Monthly" = "m",
                    "Quarterly" = "q",
                    "Semiannual" = "sa",
                    "Annual" = "a"
                  ),
                  selected = if (is.null(frequency)) "(none)" else frequency,
                  width = "100%"
                )
              ),

              # Aggregation method input (conditional on frequency)
              conditionalPanel(
                condition = sprintf("input['%s'] && input['%s'] != '(none)'", NS(id, "frequency"), NS(id, "frequency")),
                div(
                  class = "block-input-wrapper",
                  selectInput(
                    inputId = NS(id, "aggregation_method"),
                    label = "Aggregation Method",
                    choices = c(
                      "Average" = "avg",
                      "Sum" = "sum",
                      "End of Period" = "eop"
                    ),
                    selected = aggregation_method,
                    width = "100%"
                  )
                )
              ),

              # API key warning (conditional display)
              div(
                class = "block-input-wrapper",
                uiOutput(NS(id, "key_warning"))
              )
            )
          )
        )
      )
    )
  }

  server <- function(id) {
    moduleServer(
      id,
      function(input, output, session) {
        # Initialize reactive values from constructor parameters
        r_series_id <- reactiveVal(series_id)
        r_observation_start <- reactiveVal(observation_start)
        r_observation_end <- reactiveVal(observation_end)
        # Initialize frequency with "(none)" if NULL (for "Original")
        r_frequency <- reactiveVal(if (is.null(frequency)) "(none)" else frequency)
        r_aggregation_method <- reactiveVal(aggregation_method)

        # Sync inputs to reactive values
        observeEvent(input$series_id, {
          r_series_id(input$series_id)
        })

        observeEvent(input$dates, {
          dates <- as.Date(input$dates)
          r_observation_start(dates[1])
          r_observation_end(dates[2])
        })

        observeEvent(input$frequency, {
          # Keep empty string as-is (for "Original" option)
          r_frequency(input$frequency)
        })

        observeEvent(input$aggregation_method, {
          r_aggregation_method(input$aggregation_method)
        })

        # Check if API key is set
        key_set <- reactive({
          env_key <- Sys.getenv("FRED_API_KEY", unset = "")
          opt_key <- getOption("fredr.key", default = "")
          has_env <- nzchar(env_key) || nzchar(opt_key)
          has_pkg <- tryCatch(
            isTRUE(fredr::fredr_has_key()),
            error = function(e) FALSE
          )
          isTRUE(has_env || has_pkg)
        })

        # Render API key warning if needed
        output$key_warning <- renderUI({
          if (!key_set()) {
            div(
              style = "color: #856404; background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 10px; border-radius: 4px; margin-top: 10px;",
              tags$strong("API Key Required:"),
              " Set your FRED API key using ",
              tags$code("fredr::fredr_set_key('YOUR_KEY')"),
              " or environment variable ",
              tags$code("FRED_API_KEY"),
              ". Get a free key at ",
              tags$a(
                href = "https://fredaccount.stlouisfed.org/apikeys",
                target = "_blank",
                "fred.stlouisfed.org"
              ),
              "."
            )
          }
        })

        list(
          expr = reactive({
            # Validate required inputs
            req(r_series_id())
            req(r_observation_start())
            req(r_observation_end())

            # Build base expression
            freq <- r_frequency()
            agg_method <- r_aggregation_method()

            # Build expression with conditional parameters
            if (!is.null(freq) && freq != "(none)") {
              # Include frequency and aggregation method
              bquote(
                fredr::fredr(
                  series_id = .(r_series_id()),
                  observation_start = .(r_observation_start()),
                  observation_end = .(r_observation_end()),
                  frequency = .(freq),
                  aggregation_method = .(agg_method)
                )
              )
            } else {
              # No frequency - just base parameters
              bquote(
                fredr::fredr(
                  series_id = .(r_series_id()),
                  observation_start = .(r_observation_start()),
                  observation_end = .(r_observation_end())
                )
              )
            }
          }),
          state = list(
            series_id = r_series_id,
            observation_start = r_observation_start,
            observation_end = r_observation_end,
            frequency = r_frequency,
            aggregation_method = r_aggregation_method
          )
        )
      }
    )
  }

  blockr.core::new_data_block(
    server = server,
    ui = ui,
    class = "fred_block",
    allow_empty_state = c("frequency"),
    ...
  )
}

#' Register FRED blocks
#'
#' Registers all FRED blocks with the blockr.core registry.
#' This function is called automatically when the package is loaded.
#'
#' @export
register_fredr_blocks <- function() {
  blockr.core::register_blocks(
    c("new_fred_block"),
    name = c("FRED Data"),
    description = c("Fetch economic time series from FRED"),
    category = c("input"),
    package = utils::packageName(),
    overwrite = TRUE
  )
}

#' CSS Utilities for FRED Block
#'
#' Provides responsive grid layout CSS for the FRED block.
#' Based on blockr.dplyr CSS patterns.
#'
#' @return HTML style tag with responsive grid CSS
#' @noRd
css_responsive_grid <- function() {
  tags$style(HTML(
    "
    .block-container {
      width: 100%;
      margin: 0px;
      padding: 0px;
      padding-bottom: 15px;
    }

    /* One shared grid across the whole form */
    .block-form-grid {
      display: grid;
      gap: 15px;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    }

    /* Flatten wrappers so all controls share the same tracks */
    .block-section,
    .block-section-grid {
      display: contents;
    }

    /* Headings/help span full width */
    .block-section h4,
    .block-help-text {
      grid-column: 1 / -1;
    }

    .block-section h4 {
      margin-top: 5px;
      margin-bottom: 0px;
      font-size: 1.1rem;
      font-weight: 600;
      color: #333;
    }

    .block-section:not(:first-child) {
      margin-top: 20px;
    }

    .block-input-wrapper {
      width: 100%;
    }

    .block-input-wrapper .form-group {
      margin-bottom: 10px;
    }

    .block-help-text {
      margin-top: 0px;
      padding-top: 0px;
      font-size: 0.875rem;
      color: #666;
    }

    .block-help-text p {
      margin-bottom: 5px;
    }
    "
  ))
}

#' Force single-column layout for FRED block
#'
#' @param block_name Character string, name of the block
#' @return HTML style tag with single-column grid CSS
#' @noRd
css_single_column <- function(block_name) {
  tags$style(HTML(sprintf(
    "
    .%s-block-container .block-form-grid {
      grid-template-columns: 1fr !important;
    }
    ",
    block_name
  )))
}

#' @importFrom fredr fredr fredr_has_key
#' @importFrom glue glue
#' @importFrom htmltools tags HTML
#' @importFrom shiny NS dateRangeInput moduleServer observeEvent reactive reactiveVal renderUI tagList textInput req div p uiOutput selectInput conditionalPanel
#' @importFrom shinyjs useShinyjs
#' @importFrom utils packageName
NULL
