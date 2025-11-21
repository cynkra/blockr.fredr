# Basic construction tests
test_that("fred block constructor works", {
  blk <- new_fred_block(series_id = "UNRATE")
  expect_s3_class(blk, "fred_block")
  expect_s3_class(blk, "data_block")
})

test_that("fred block with default parameters has initialized state", {
  skip_if_not_installed("shiny")

  # Create block with all defaults (this is what user does)
  blk <- new_fred_block(series_id = "UNRATE")

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()

      # State should be initialized immediately
      state <- session$returned$state
      expect_true(is.reactive(state$series_id))
      expect_true(is.reactive(state$observation_start))
      expect_true(is.reactive(state$observation_end))
      expect_true(is.reactive(state$frequency))
      expect_true(is.reactive(state$aggregation_method))

      # All state values should return non-NULL values
      expect_equal(state$series_id(), "UNRATE")
      expect_s3_class(state$observation_start(), "Date")
      expect_s3_class(state$observation_end(), "Date")
      expect_equal(state$frequency(), "(none)")  # "(none)" for "Original"
      expect_equal(state$aggregation_method(), "avg")
    },
    args = list(x = blk, data = list())
  )
})

test_that("fred block registration works", {
  expect_no_error(register_fredr_blocks())
})

# Restorability tests - verify constructor params are in state
test_that("fred block restorability - default dates", {
  skip_if_not_installed("shiny")

  blk <- new_fred_block(series_id = "UNRATE")

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()

      # Access state through returned list
      state <- session$returned$state

      # Verify all constructor params are in state
      expect_true(is.reactive(state$series_id))
      expect_true(is.reactive(state$observation_start))
      expect_true(is.reactive(state$observation_end))

      # Verify state values match constructor
      expect_equal(state$series_id(), "UNRATE")
      expect_s3_class(state$observation_start(), "Date")
      expect_s3_class(state$observation_end(), "Date")
    },
    args = list(x = blk, data = list())
  )
})

test_that("fred block restorability - custom dates", {
  skip_if_not_installed("shiny")

  start_date <- as.Date("2020-01-01")
  end_date <- as.Date("2023-12-31")

  blk <- new_fred_block(
    series_id = "GDP",
    observation_start = start_date,
    observation_end = end_date
  )

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()

      state <- session$returned$state

      # Verify all constructor params are restored in state
      expect_equal(state$series_id(), "GDP")
      expect_equal(state$observation_start(), start_date)
      expect_equal(state$observation_end(), end_date)
    },
    args = list(x = blk, data = list())
  )
})

test_that("fred block restorability - different series", {
  skip_if_not_installed("shiny")

  series_ids <- c("UNRATE", "GDP", "CPIAUCSL", "FEDFUNDS", "DGS10")

  for (sid in series_ids) {
    blk <- new_fred_block(series_id = sid)

    shiny::testServer(
      blockr.core:::get_s3_method("block_server", blk),
      {
        session$flushReact()
        state <- session$returned$state
        expect_equal(state$series_id(), sid)
      },
      args = list(x = blk, data = list())
    )
  }
})

# Expression generation tests
test_that("fred block generates correct expression - default dates", {
  skip_if_not_installed("shiny")

  blk <- new_fred_block(series_id = "UNRATE")

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()

      expr_result <- session$returned$expr()

      # Verify expression is a call
      expect_true(inherits(expr_result, "call"))

      # Verify it's calling fredr::fredr
      expect_equal(as.character(expr_result[[1]]), c("::", "fredr", "fredr"))

      # Verify arguments
      expect_equal(expr_result$series_id, "UNRATE")
      expect_s3_class(expr_result$observation_start, "Date")
      expect_s3_class(expr_result$observation_end, "Date")
    },
    args = list(x = blk, data = list())
  )
})

test_that("fred block generates correct expression - custom dates", {
  skip_if_not_installed("shiny")

  start_date <- as.Date("2020-01-01")
  end_date <- as.Date("2023-12-31")

  blk <- new_fred_block(
    series_id = "GDP",
    observation_start = start_date,
    observation_end = end_date
  )

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()

      expr_result <- session$returned$expr()

      # Verify it's calling fredr::fredr with correct arguments
      expect_equal(expr_result$series_id, "GDP")
      expect_equal(expr_result$observation_start, start_date)
      expect_equal(expr_result$observation_end, end_date)
    },
    args = list(x = blk, data = list())
  )
})

# Date handling tests
test_that("fred block handles date inputs correctly", {
  skip_if_not_installed("shiny")

  # Test with Date objects
  start <- as.Date("2015-01-01")
  end <- as.Date("2020-12-31")

  blk <- new_fred_block(
    series_id = "UNRATE",
    observation_start = start,
    observation_end = end
  )

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()
      state <- session$returned$state

      # Dates should be Date objects in state
      expect_s3_class(state$observation_start(), "Date")
      expect_s3_class(state$observation_end(), "Date")
      expect_equal(state$observation_start(), start)
      expect_equal(state$observation_end(), end)
    },
    args = list(x = blk, data = list())
  )
})

test_that("fred block handles NULL dates with defaults", {
  skip_if_not_installed("shiny")

  blk <- new_fred_block(
    series_id = "CPIAUCSL",
    observation_start = NULL,
    observation_end = NULL
  )

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()
      state <- session$returned$state

      # Should have Date defaults (10 years ago to today)
      start_date <- state$observation_start()
      end_date <- state$observation_end()

      expect_s3_class(start_date, "Date")
      expect_s3_class(end_date, "Date")
      expect_true(start_date < end_date)
      expect_true(end_date <= Sys.Date())
    },
    args = list(x = blk, data = list())
  )
})

# Frequency and aggregation tests
test_that("fred block with frequency parameter", {
  skip_if_not_installed("shiny")

  blk <- new_fred_block(
    series_id = "UNRATE",
    frequency = "q",
    aggregation_method = "avg"
  )

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()
      state <- session$returned$state

      # Verify frequency and aggregation in state
      expect_equal(state$frequency(), "q")
      expect_equal(state$aggregation_method(), "avg")

      # Verify expression includes frequency parameters
      expr_result <- session$returned$expr()
      expect_equal(expr_result$frequency, "q")
      expect_equal(expr_result$aggregation_method, "avg")
    },
    args = list(x = blk, data = list())
  )
})

test_that("fred block without frequency (default)", {
  skip_if_not_installed("shiny")

  blk <- new_fred_block(series_id = "GDP")

  shiny::testServer(
    blockr.core:::get_s3_method("block_server", blk),
    {
      session$flushReact()
      state <- session$returned$state

      # Verify frequency is "(none)" (Original/no aggregation)
      expect_equal(state$frequency(), "(none)")

      # Verify expression does NOT include frequency parameters
      expr_result <- session$returned$expr()
      expect_null(expr_result$frequency)
      expect_null(expr_result$aggregation_method)
    },
    args = list(x = blk, data = list())
  )
})

test_that("fred block with different frequencies", {
  skip_if_not_installed("shiny")

  frequencies <- c("d", "w", "m", "q", "sa", "a")

  for (freq in frequencies) {
    blk <- new_fred_block(
      series_id = "UNRATE",
      frequency = freq,
      aggregation_method = "sum"
    )

    shiny::testServer(
      blockr.core:::get_s3_method("block_server", blk),
      {
        session$flushReact()
        state <- session$returned$state
        expect_equal(state$frequency(), freq)
        expect_equal(state$aggregation_method(), "sum")
      },
      args = list(x = blk, data = list())
    )
  }
})

test_that("fred block with different aggregation methods", {
  skip_if_not_installed("shiny")

  methods <- c("avg", "sum", "eop")

  for (method in methods) {
    blk <- new_fred_block(
      series_id = "GDP",
      frequency = "a",
      aggregation_method = method
    )

    shiny::testServer(
      blockr.core:::get_s3_method("block_server", blk),
      {
        session$flushReact()
        state <- session$returned$state
        expect_equal(state$aggregation_method(), method)

        # Verify in expression
        expr_result <- session$returned$expr()
        expect_equal(expr_result$aggregation_method, method)
      },
      args = list(x = blk, data = list())
    )
  }
})
