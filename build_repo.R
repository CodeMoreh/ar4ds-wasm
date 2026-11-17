##############################################################################
# Title:        build_repo.R – fill the package repository of the browser pages
# Purpose:      Copy the WebAssembly builds of the packages that the browser
#               pages of the course load, with their dependencies, into
#               bin/emscripten/contrib/<R minor>/, write the index that webR
#               reads, and record every version in versions.csv beside the
#               version of the package date of the course.
# Reads:        the indexes of https://cran.r-universe.dev, of
#               https://repo.r-wasm.org and of the snapshot of the package
#               date at https://packagemanager.posit.co
# Writes:       bin/emscripten/contrib/<R minor>/ (the builds and PACKAGES*),
#               versions.csv
# Author:       Chris Moreh
# Last updated: 2026-11-17
##############################################################################

# The date that fixes the package versions of the course, and the minor
# version of the R inside webR (webR 0.6.0 carries R 4.6). R-universe holds
# only the current release of a package, so the repository is filled on the
# day on which the package date moves; versions.csv shows whether a build
# has moved past the date since.
package_date <- "2026-11-17"
r_minor <- "4.6"

# The packages that the browser pages list under `webr: packages:`.
listed <- c(
  "datawizard", "dplyr", "effectsize", "fixest", "gt", "haven", "htmltools",
  "knitr", "lme4", "lmerTest", "marginaleffects", "markdown", "parameters",
  "purrr", "sandwich", "sjlabelled", "tibble", "tinyplot"
)

universe <- paste0("https://cran.r-universe.dev/bin/emscripten/contrib/", r_minor)
webr <- paste0("https://repo.r-wasm.org/bin/emscripten/contrib/", r_minor)
out_dir <- file.path("bin", "emscripten", "contrib", r_minor)

index_universe <- utils::available.packages(contriburl = universe, filters = list())
index_webr <- utils::available.packages(contriburl = webr, filters = list())
index_date <- utils::available.packages(
  repos = paste0("https://packagemanager.posit.co/cran/", package_date),
  type = "source"
)

# R-universe comes first. The repository of the webR project supplies only
# what R-universe cannot build for the browser (nloptr, which lme4 needs).
only_webr <- setdiff(rownames(index_webr), rownames(index_universe))
index_all <- rbind(index_universe, index_webr[only_webr, , drop = FALSE])

needed <- listed |>
  tools::package_dependencies(db = index_all, which = c("Depends", "Imports", "LinkingTo"), recursive = TRUE) |>
  unlist() |>
  c(listed) |>
  unique() |>
  setdiff(rownames(utils::installed.packages(priority = "base"))) |>
  sort()

stopifnot("a needed package has no build for the browser" = all(needed %in% rownames(index_all)))

versions <- tibble::tibble(
  package = needed,
  version = unname(index_all[needed, "Version"]),
  source = dplyr::if_else(needed %in% only_webr, webr, universe),
  version_at_package_date = unname(index_date[, "Version"][needed]),
  file = paste0(package, "_", version, ".tgz")
)

unlink(out_dir, recursive = TRUE)
dir.create(out_dir, recursive = TRUE)
purrr::walk2(
  paste0(versions$source, "/", versions$file),
  file.path(out_dir, versions$file),
  \(from, to) utils::download.file(from, to, mode = "wb", quiet = TRUE)
)

# A build for the browser is a .tgz archive laid out like a macOS binary,
# which is the type under which write_PACKAGES() reads its DESCRIPTION.
tools::write_PACKAGES(out_dir, type = "mac.binary")

readr::write_csv(versions, "versions.csv")
