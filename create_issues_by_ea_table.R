# ==============================================================================
# Set project params
# ==============================================================================

main_file <- "MTF_2024_HH_Namibia_Final.dta"

ea_vars <- c(
  "SEC_A_Q04",
  "SEC_A_Q05"
)

# ==============================================================================
# Install dependencies, as needed
# ==============================================================================

if (!require("here", quietly = TRUE, character.only = TRUE)) {
  install.packages("here")
}
source(here::here("R", "install_dependencies.R"))

# ==============================================================================
# Check inputs : !!! TODO !!!
# ==============================================================================

# data present

# main file exists

# EA variables exist in main file

# etc

# ==============================================================================
# Prepare data
# ==============================================================================

data_dir <- here::here("data")

interviews <- fs::path(data_dir, "01_microdata", main_file) |>
  haven::read_dta() |>
  dplyr::select(interview__id, dplyr::all_of(ea_vars))

issues <- fs::path(data_dir, "02_issues", "to_reject_details.dta") |>
  haven::read_dta()

issues_w_ea <- issues |>
  dplyr::left_join(interviews, by = "interview__id") |>
  dplyr::select(
    dplyr::all_of(ea_vars),
    interview__id, reject_comment, interview__status
  )

eas <- issues_w_ea |>
  dplyr::group_by(!!!rlang::data_syms(ea_vars)) |>
  dplyr::summarise(
    n_int_w_issue = dplyr::n()
  ) |>
  dplyr::ungroup()

# ==============================================================================
# Compose interactive table of EAs with details on issues in each EA
# ==============================================================================

# reuse theme from monitorMTF
reactable_style <- reactable::reactableTheme(
  headerStyle = list(color = "#ffffff", background = "#6f3996")
)

reactable::reactable(
  data = eas,
  searchable = TRUE,
  onClick = "expand",
  columns = list(
    n_int_w_issue = reactable::colDef(name = "N. interviews with issues")
  ),
  striped = TRUE,
  theme = reactable_style,
  # NOTE: failed attempt to write columns specification where names are not
  # known ahead of time. Perhaps better to specify list separately and then
  # use setNames to provide names afterwards
  #
  # columns = list(
  #   !!rlang::sym(ea_vars[1]) = reactable::colDef(
  #     name = dplyr::if_else(
  #       condition = !is.null(labelled::get_variable_labels(eas[[ea_vars[1]]])),
  #       true = labelled::get_variable_labels(eas[[ea_vars[1]]]),
  #       false = ea_vars[1]
  #     )
  #   )
    # ,
    # !!rlang::sym(ea_vars[2]) = reactable::colDef(
    #   name = dplyr::if_else(
    #     condition = !is.null(labelled::get_variable_labels(eas[[ea_vars[2]]])),
    #     true = labelled::get_variable_labels(eas[[ea_vars[2]]]),
    #     false = ea_vars[2]
    #   )
    # )

  # ),
  details = function(index) {

    # select issues for the EA whose details are shown
    issues_in_ea <- issues_w_ea |>
      dplyr::filter(
        issues_w_ea[[ea_vars[1]]] == eas[[ea_vars[1]]][index] &
        issues_w_ea[[ea_vars[2]]] == eas[[ea_vars[2]]][index]
      ) |>
      dplyr::select(interview__id, reject_comment)

    if (nrow(issues_in_ea) > 0) {

      # compose a reactable
      issues_details <- reactable::reactable(
        data = issues_in_ea
      )

    } else {

      issues_details <- "No issues identified in this EA"

    }

    return(issues_details)

  }

)
