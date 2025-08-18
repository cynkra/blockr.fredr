#' FRED data block
#'
#' A data-import block that retrieves a FRED time series via `fredr::fredr()`.
#' Make sure a FRED API key is set (see `fredr::fredr_set_key()` or environment
#' variable `FRED_API_KEY`).
#'
#' @param series_id FRED series ID (e.g., "UNRATE")
#' @param observation_start,observation_end Optional date range
#' @export
new_fred_block <- function(
  series_id = "UNRATE",
  observation_start = NULL,
  observation_end = NULL,
  ...
) {

  if (is.null(observation_start)) {
    observation_start <- as.Date(Sys.Date() - 365 * 10)
  }
  if (is.null(observation_end)) {
    observation_end <- Sys.Date()
  }

  blockr.core::new_data_block(
    function(id) {
      moduleServer(
        id,
        function(input, output, session) {

          sid <- reactiveVal(series_id)
          dates <- reactiveVal(c(observation_start, observation_end))

          observeEvent(input$series_id, sid(input$series_id))
          observeEvent(input$dates, dates(as.Date(input$dates)))

          key_set <- reactive({
            env_key <- Sys.getenv("FRED_API_KEY", unset = "")
            opt_key <- getOption("fredr.key", default = "")
            has_env <- nzchar(env_key) || nzchar(opt_key)
            has_pkg <- tryCatch(isTRUE(fredr::fredr_has_key()), error = function(e) FALSE)
            isTRUE(has_env || has_pkg)
          })

          output$key_warning <- renderUI({
            if (!key_set()) {
              helpText("FRED API key not set. Call fredr::fredr_set_key('YOUR_KEY') or set FRED_API_KEY / options(fredr.key='YOUR_KEY').")
            }
          })

          list(
            expr = reactive({
              dts <- dates()
              bquote(
                fredr::fredr(
                  series_id = .(sid()),
                  observation_start = .(dts[1L]),
                  observation_end = .(dts[2L])
                )
              )
            }),
            state = list(
              series_id = sid,
              observation_start = reactive(dates()[1L]),
              observation_end = reactive(dates()[2L])
            )
          )
        }
      )
    },
    function(id) {
      tagList(
        textInput(
          inputId = NS(id, "series_id"),
          label = "FRED series ID",
          value = series_id,
          width = "100%"
        ),
        dateRangeInput(
          inputId = NS(id, "dates"),
          label = "Date range",
          start = observation_start,
          end = observation_end,
          startview = "year"
        ),
        uiOutput(NS(id, "key_warning"))
      )
    },
    class = "fred_block",
    ...
  )
}

register_fredr_blocks <- function() {
  blockr.core::register_blocks(
    c("new_fred_block"),
    name = c("FRED data block"),
    description = c("Fetch a series from FRED via fredr"),
    category = c("data"),
    package = utils::packageName(),
    overwrite = TRUE
  )
}

#' @importFrom fredr fredr fredr_has_key
#' @importFrom shiny NS dateRangeInput helpText moduleServer observeEvent reactive reactiveVal renderUI tagList textInput
#' @importFrom utils packageName
NULL

