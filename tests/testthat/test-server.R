test_that("server creates status_output", {
  shiny::testServer(server, {
    expect_null(output$status_output)
  })
})

test_that("build_infection_list returns a list of daedalus_infection", {
  shiny::testServer(server, {
    session$setInputs(
      infection = "influenza_2009",
      n_samples = 3,
      r0_min = 1.0,
      r0_max = 2.0
    )
    result <- build_infection_list()
    expect_type(result, "list")
    expect_length(result, 3)
    for (i in seq_along(result)) {
      expect_s3_class(result[[i]], "daedalus_infection")
    }
  })
})

test_that("build_vaccination returns NULL when strategy is none", {
  shiny::testServer(server, {
    session$setInputs(
      vaccination_strategy = "none",
      country = "United Kingdom"
    )
    expect_null(build_vaccination())
  })
})

test_that("build_vaccination returns daedalus_vaccination for low", {
  shiny::testServer(server, {
    session$setInputs(
      vaccination_strategy = "low",
      country = "United Kingdom"
    )
    result <- build_vaccination()
    expect_s3_class(result, "daedalus_vaccination")
  })
})

test_that("run_btn produces a success message", {
  shiny::testServer(server, {
    session$setInputs(
      country = "United Kingdom",
      infection = "influenza_2009",
      n_samples = 2,
      r0_min = 1.0,
      r0_max = 2.0,
      include_no_response = TRUE,
      vaccination_strategy = "none",
      time_end = 100,
      run_btn = 1
    )
    expect_match(output$status_output, "complete", ignore.case = TRUE)
  })
})

test_that("epicurve_data returns a data.frame after run", {
  shiny::testServer(server, {
    session$setInputs(
      country = "United Kingdom",
      infection = "influenza_2009",
      n_samples = 2,
      r0_min = 1.0,
      r0_max = 2.0,
      include_no_response = TRUE,
      vaccination_strategy = "none",
      time_end = 100,
      run_btn = 1
    )
    df <- epicurve_data()
    expect_s3_class(df, "data.frame")
    expect_true("daily_hospitalisations" %in% df$measure)
    expect_true("time" %in% names(df))
    expect_true("value" %in% names(df))
    expect_true("response" %in% names(df))
    expect_true("tag" %in% names(df))
  })
})

test_that("epicurve_plot renders after run", {
  shiny::testServer(server, {
    session$setInputs(
      country = "United Kingdom",
      infection = "influenza_2009",
      n_samples = 2,
      r0_min = 1.0,
      r0_max = 2.0,
      include_no_response = TRUE,
      vaccination_strategy = "none",
      time_end = 100,
      run_btn = 1
    )
    expect_s3_class(output$epicurve_plot, "recordedplot")
  })
})
