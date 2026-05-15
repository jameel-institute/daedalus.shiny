#' Run the daedalus.shiny Application
#'
#' Launches the Shiny dashboard for configuring and running DAEDALUS
#' epidemiological-economic model scenarios.
#'
#' @param ... Arguments passed to [shiny::shinyApp()].
#'
#' @return A `shiny.appobj` (invisibly). Called for side-effects.
#' @export
run_app <- function(...) {
  shiny::shinyApp(ui = ui, server = server, ...)
}
