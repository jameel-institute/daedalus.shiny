test_that("run_app() is a function", {
  expect_true(is.function(run_app))
})

test_that("run_app() returns a shiny app object", {
  app <- run_app()
  expect_s3_class(app, "shiny.appobj")
})
