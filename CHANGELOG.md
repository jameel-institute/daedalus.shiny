# Changelog

## daedalus.shiny (development version)

### New features

- Added `run_app()` as the main entry point to launch the Shiny dashboard for
  configuring and running DAEDALUS epidemiological-economic model scenarios.
- Added Shiny UI (`R/ui.R`) with inputs for country selection, pathogen
  selection, infection parameter uncertainty via R0 sampling
  (`make_infection_samples()`), multiple timed NPI scenarios with per-phase
  strategy selection via `daedalus_timed_npi()`, vaccination strategy selection,
  and simulation duration configuration.
- Added Shiny server (`R/server.R`) with reactive logic to dynamically build
  `daedalus_timed_npi()` objects from user input, assemble infection parameter
  samples via `make_infection_samples()`, assemble vaccination strategy objects,
  and run `daedalus.compare::run_scenarios()` on button click, displaying a
  success message with scenario count on completion.
- Added tests for `run_app()`, UI structure, and server reactive logic in
  `tests/testthat/`.
- Updated `DESCRIPTION` with package metadata and dependency imports.
- Added epidemic curve plot showing daily hospitalisations over time for all
  response scenarios overlaid with colour coding after a successful model run,
  using `daedalus.compare::get_epicurve_data()` and `ggplot2` for visualization.

### Improvements

- Refactored server output rendering to display results only after the "Run Model"
  button is clicked. No output is shown on initial page load, and changing inputs
  no longer triggers automatic re-computation.
- Fixed NPI phase interface: replaced strategy dropdown with a continuous openness
  coefficient input (0–1 range). The openness value is now properly replicated
  across all 45 economic sectors and correctly constructs the 49×2 openness
  matrix required by `daedalus_timed_npi()`, with community contacts unscaled
  and workplace contacts adjusted per the user-specified openness coefficient.
- Simplified NPI system: each NPI scenario now has exactly one phase instead of
  multiple phases. Removed complex dynamic phase management, eliminated buggy
  nested observer pattern, and made input handling more reliable. Users can still
  add multiple NPI scenarios, each with single start time, end time, and openness
  coefficient. Fixed type coercion to ensure all numeric inputs are passed as
  doubles (not integers) to `daedalus_timed_npi()`.
- Improved NPI scenario UI: scenarios are now displayed as clean Bootstrap cards
  with editable scenario names in the header alongside the remove button. Each
  scenario card shows the scenario controls (start day, end day, openness) in a
  dedicated body section. The NPI scenarios container uses scrolling when multiple
  scenarios are added, keeping the sidebar compact. Added placeholder text and
  empty-state messaging for better UX.
