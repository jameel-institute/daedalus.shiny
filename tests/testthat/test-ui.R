test_that("ui is a shiny tag object", {
  expect_true(inherits(ui, c("shiny.tag", "shiny.tag.list")))
})

test_that("ui contains expected input IDs", {
  ui_html <- as.character(ui)
  expected_ids <- c(
    "country",
    "infection",
    "n_samples",
    "r0_min",
    "r0_max",
    "include_no_response",
    "add_scenario_btn",
    "vaccination_strategy",
    "time_end",
    "run_btn",
    "status_output",
    "npi_scenarios_container"
  )
  for (id in expected_ids) {
    expect_true(
      grepl(id, ui_html, fixed = TRUE),
      info = paste("Missing input ID:", id)
    )
  }
})
