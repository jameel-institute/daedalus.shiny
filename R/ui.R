ui <- shiny::fluidPage(
  shiny::titlePanel("DAEDALUS Scenario Runner"),
  shiny::sidebarLayout(
    sidebarPanel = shiny::sidebarPanel(
      # --- Country & Pathogen ---
      shiny::selectInput(
        "country",
        "Country",
        choices = daedalus.data::country_names,
        selected = "United Kingdom"
      ),
      shiny::selectInput(
        "infection",
        "Pathogen/Epidemic",
        choices = daedalus.data::epidemic_names,
        selected = "influenza_2009"
      ),

      # --- Infection uncertainty ---
      shiny::hr(),
      shiny::h4("Infection Parameter Uncertainty"),
      shiny::numericInput(
        "n_samples",
        "Number of R0 samples",
        value = 10,
        min = 2,
        step = 1
      ),
      shiny::numericInput(
        "r0_min",
        "R0 range: minimum",
        value = 1.0,
        min = 0.01,
        step = 0.1
      ),
      shiny::numericInput(
        "r0_max",
        "R0 range: maximum",
        value = 3.0,
        min = 0.01,
        step = 0.1
      ),

      # --- NPI Scenarios ---
      shiny::hr(),
      shiny::h4("NPI Scenarios"),
      shiny::checkboxInput(
        "include_no_response",
        "Include no-response scenario",
        value = TRUE
      ),
      shiny::actionButton(
        "add_scenario_btn",
        "Add NPI Scenario",
        class = "btn-primary"
      ),
      shiny::div(
        id = "npi_scenarios_container",
        style = "margin-top: 15px; max-height: 500px; overflow-y: auto;",
        shiny::p(
          "No NPI scenarios added yet. Click 'Add NPI Scenario' to create one.",
          style = "color: #666; font-style: italic;"
        )
      ),

      # --- Vaccination ---
      shiny::hr(),
      shiny::h4("Vaccination Strategy"),
      shiny::selectInput(
        "vaccination_strategy",
        "Vaccination strategy",
        choices = daedalus.data::vaccination_scenario_names,
        selected = "none"
      ),

      # --- Simulation duration ---
      shiny::hr(),
      shiny::numericInput(
        "time_end",
        "Simulation duration (days)",
        value = 300,
        min = 50,
        step = 10
      ),

      # --- Run ---
      shiny::hr(),
      shiny::actionButton("run_btn", "Run Model", class = "btn-primary")
    ),
    mainPanel = shiny::mainPanel(
      shiny::textOutput("status_output"),
      shiny::plotOutput("epicurve_plot")
    )
  )
)
