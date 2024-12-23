# =============================================================================
# Install necessary packages
# =============================================================================

# -----------------------------------------------------------------------------
# Install packages used for provisioning other packages
# -----------------------------------------------------------------------------

# for package installation
if (!require("pak")) {
  install.packages("pak")
}

# for parsing package specifications for pak
if (!require("stringr")) {
  install.packages("stringr")
}

# for iteration over list of packages
if (!require("purrr")) {
  install.packages("purrr")
}

# -----------------------------------------------------------------------------
# Install any missing requirements
# -----------------------------------------------------------------------------

required_packages <- c(
  # path construction and other file operations
  "fs",
  # reading/writing Stata files
  "haven",
  # data munging
  "dplyr",
  # composing interactive table
  "reactable"
)

#' Install package if missing on system
#' 
#' @param package Character. Name of package to install.
#' @importFrom stringr str_detect
install_if_missing <- function(package) {

  # strip out package name from repo address
  slash_pattern <- "\\/"
  if (stringr::str_detect(string = package, pattern = slash_pattern) ) {
    slash_position <- stringr::str_locate(
      string = package,
      pattern = slash_pattern
    )
    package <- stringr::str_sub(
      string = package,
      start = slash_position[[1]] + 1
    )
  }

  if (!require(package, character.only = TRUE)) {
    pak::pak(package)
  }

}

# install any missing requirements
purrr::walk(
  .x = required_packages,
  .f = ~ install_if_missing(.x)
)