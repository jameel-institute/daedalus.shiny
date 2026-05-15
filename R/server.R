`%||%` <- function(x, y) if (is.null(x)) y else x

make_scenario_ui <- function(sid) {
  shiny::div(
    id = paste0("scenario_wrapper_", sid),
    class = "card mb-3",
    style = "border-left: 4px solid #0275d8;",
    shiny::div(
      class = "card-header",
      shiny::div(
        class = "d-flex justify-content-between align-items-center",
        style = "gap: 10px;",
        shiny::textInput(
          paste0("scenario_name_", sid),
          NULL,
          value = paste0("scenario_", sid),
          placeholder = paste0("Scenario ", sid),
          width = "100%"
        ),
        shiny::actionButton(
          paste0("remove_scenario_btn_", sid),
          "Remove",
          class = "btn-sm btn-danger",
          style = "white-space: nowrap;"
        )
      )
    ),
    shiny::div(
      class = "card-body",
      shiny::fluidRow(
        shiny::column(
          4,
          shiny::numericInput(
            paste0("start_time_", sid),
            "Start day",
            value = 30,
            min = 0
          )
        ),
        shiny::column(
          4,
          shiny::numericInput(
            paste0("end_time_", sid),
            "End day",
            value = 90,
            min = 0
          )
        ),
        shiny::column(
          4,
          shiny::numericInput(
            paste0("openness_", sid),
            "Openness (0–1)",
            value = 1.0,
            min = 0,
            max = 1,
            step = 0.05
          )
        )
      )
    )
  )
}

server <- function(input, output, session) {
  rv <- shiny::reactiveValues(
    scenario_ids = integer(0),
    next_scenario_id = 1L,
    model_result = NULL,
    disease_tags = character(0),
    model_run = FALSE,
    status_message = ""
  )

  shiny::observeEvent(input$add_scenario_btn, {
    sid <- rv$next_scenario_id
    rv$next_scenario_id <- rv$next_scenario_id + 1L
    rv$scenario_ids <- c(rv$scenario_ids, sid)

    shiny::insertUI(
      selector = "#npi_scenarios_container",
      where = "beforeEnd",
      ui = make_scenario_ui(sid)
    )

    local({
      local_sid <- sid
      shiny::observeEvent(
        input[[paste0("remove_scenario_btn_", local_sid)]],
        {
          rv$scenario_ids <- setdiff(rv$scenario_ids, local_sid)
          shiny::removeUI(
            selector = paste0("#scenario_wrapper_", local_sid)
          )
        },
        ignoreInit = TRUE,
        once = TRUE
      )
    })
  })

  build_infection_list <- shiny::reactive({
    shiny::req(input$infection, input$n_samples, input$r0_min, input$r0_max)
    n <- max(2L, as.integer(input$n_samples))
    daedalus.compare::make_infection_samples(
      name = input$infection,
      param_distributions = list(r0 = distributional::dist_beta(2, 5)),
      param_ranges = list(r0 = c(input$r0_min, input$r0_max)),
      samples = n
    )
  })

  build_npi_list <- shiny::reactive({
    ids <- rv$scenario_ids
    if (length(ids) == 0) {
      return(NULL)
    }

    country_val <- input$country
    n_sectors <- length(daedalus.data::closure_strategy_data[["none"]])
    n_age_groups <- 4L
    n_rows <- n_age_groups + n_sectors

    scenarios <- lapply(ids, function(sid) {
      start <- as.numeric(input[[paste0("start_time_", sid)]] %||% 30)
      end <- as.numeric(input[[paste0("end_time_", sid)]] %||% 90)
      coef <- as.numeric(input[[paste0("openness_", sid)]] %||% 1.0)
      coef <- max(0, min(1, coef))

      openness_mat <- list(as.matrix(cbind(
        rep(1.0, n_rows),
        c(rep(1.0, n_age_groups), rep(coef, n_sectors))
      )))

      tryCatch(
        daedalus::daedalus_timed_npi(
          start_time = start,
          end_time = end,
          openness = openness_mat,
          country = country_val
        ),
        error = function(e) NULL
      )
    })

    names(scenarios) <- vapply(
      ids,
      function(sid) {
        nm <- input[[paste0("scenario_name_", sid)]]
        if (is.null(nm) || nchar(trimws(nm)) == 0) {
          paste0("scenario_", sid)
        } else {
          nm
        }
      },
      character(1)
    )

    valid <- !vapply(scenarios, is.null, logical(1))
    scenarios[valid]
  })

  build_vaccination <- shiny::reactive({
    shiny::req(input$vaccination_strategy, input$country)
    vax_name <- input$vaccination_strategy
    if (vax_name == "none") {
      return(NULL)
    }
    daedalus::daedalus_vaccination(vax_name, country = input$country)
  })

  shiny::observeEvent(input$run_btn, {
    rv$status_message <- "Running model, please wait..."

    infection_list <- tryCatch(
      build_infection_list(),
      error = function(e) {
        rv$status_message <<- paste("Infection error:", e$message)
        return(NULL)
      }
    )
    shiny::req(infection_list)

    npi_list <- build_npi_list()
    include_none <- isTRUE(input$include_no_response)

    response_arg <- if (is.null(npi_list) || length(npi_list) == 0) {
      if (include_none) NULL else NULL
    } else {
      if (include_none) {
        c(list(none = NULL), npi_list)
      } else {
        npi_list
      }
    }

    if (is.list(response_arg) && length(response_arg) == 1) {
      response_arg <- response_arg[[1]]
    }

    vax_arg <- tryCatch(
      build_vaccination(),
      error = function(e) NULL
    )

    result <- tryCatch(
      daedalus.compare::run_scenarios(
        country = input$country,
        infection = infection_list,
        response_strategy = response_arg,
        vaccination_strategy = vax_arg,
        time_end = input$time_end
      ),
      error = function(e) {
        rv$status_message <<- paste("Model run failed:", e$message)
        NULL
      }
    )

    if (!is.null(result)) {
      n_samples <- max(2L, as.integer(input$n_samples))
      rv$disease_tags <- sprintf("sample_%i", seq_len(n_samples))
      rv$model_result <- result
      rv$model_run <- TRUE

      n_scenarios <- nrow(result)
      rv$status_message <- paste0(
        "Model run complete. ",
        n_scenarios,
        " scenario(s) computed successfully."
      )
    }
  })

  epicurve_data <- shiny::reactive({
    shiny::req(rv$model_run, rv$model_result, length(rv$disease_tags) > 0)
    daedalus.compare::get_epicurve_data(
      rv$model_result,
      rv$disease_tags,
      format = "long"
    )
  })

  output$status_output <- shiny::renderText({
    if (rv$model_run || nchar(rv$status_message) > 0) {
      rv$status_message
    } else {
      ""
    }
  })

  output$epicurve_plot <- shiny::renderPlot({
    if (!rv$model_run) {
      return(NULL)
    }
    df <- epicurve_data()
    df_hosp <- df[df$measure == "daily_hospitalisations", ]
    ggplot2::ggplot(df_hosp, ggplot2::aes(x = time, y = value)) +
      ggplot2::geom_line(
        ggplot2::aes(
          col = response,
          group = interaction(tag, response)
        ),
        alpha = 0.4
      ) +
      ggplot2::labs(
        x = "Time (days)",
        y = "Daily hospitalisations",
        col = "Response scenario"
      ) +
      ggplot2::theme_bw()
  })
}
