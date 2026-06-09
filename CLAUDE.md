
# daedalus.shiny

This repository is an R package that is intended to serve a Shiny dashboard that exposes the full functionality of the Daedalus epidemiological-economic model.

## Prior art

Refer to the following packages and repositories. If they cannot be found locally, read the source from GitHub.

- Daedalus (https://github.com/jameel-institute/daedalus) or at @../daedalus : this is the Daedalus epidemiological-economic model. The key aim of this package is to expose the functionality of this package in the dashboard. Examples of use cases are shown in the directory 'vignettes' within the daedalus repo.
- daedalus.compare (https://github.com/jameel-institute/daedalus.compare) or at @../daedalus.compare : this is an extension to the daedalus package which allows running multiple scenarios of infection parameters, as well as multiple intervention scenarios.
- Daedalus Explore (https://github.com/jameel-institute/daedalus-web-app) : this is a professionally developed web application that exposes only some of the functionality of the Daedalus R package. The goal is to build something approximating this, but without the visual elements.

## Design spec

- Build a Shiny app
- The app must allow users to run the Daedalus model using daedalus.compare for real-world use-cases involving running multiple parameter sets per scenario.
- The app must allow users to specify multiple NPIs using `daedalus_timed_npi()` as shown in the vignettes of daedalus and daedalus.compare.
- The end point of this app is currently to simply run the chosen model and print a success message once complete.

## Implementation rules

- Use the skills r-package-development, testing-r-packages, brand-yml, shiny-bslib, and shiny-bslib-theming from provider posit-dev/skills
- Always add a new plan when new functionality is requested.
- New plans should be added under @plans/
- Never run tests locally.
- Do not commit any files unless requested.
- Always credit Claude with the model version when a commit is requested.
- Always add a summary to the changelog in @CHANGELOG.md when making edits.
