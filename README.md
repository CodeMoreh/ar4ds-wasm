# AR4DS – packages for the browser pages

This repository holds the R packages that the browser pages of the course Applied Replication for Data Skills (AR4DS) load: the labs, the live decks and the modules whose code runs in the browser through webR. It is a package repository in the layout of CRAN, served by GitHub Pages at <https://codemoreh.github.io/ar4ds-wasm/>. Nobody needs to download anything from it. A page of the course names it, and the browser fetches the packages from here when the page is opened.

Its purpose is to keep the versions fixed. Every build is the release of the package on the package date of the course, 17 November 2026, the date that also fixes the versions with which the pages of the course were built. The browser therefore runs the same versions between two deliveries of the course, whatever is published in the meantime.

## Contents

- `bin/emscripten/contrib/4.6/` – the WebAssembly builds of 105 packages for the R 4.6 of webR, with the index (`PACKAGES`) that webR reads: the 18 packages that the pages list and the packages on which those depend.
- `versions.csv` – each package with its version, the place from which its build was copied and its version on the package date.
- `build_repo.R` – the script that fills the repository when the package date moves.

The builds come from [R-universe](https://cran.r-universe.dev), which builds the current CRAN release of every package for the browser, and, for nloptr, from the [repository of the webR project](https://repo.r-wasm.org).

## Use in a Quarto Live page

```yaml
webr:
  packages:
    - datawizard
  repos:
    - https://codemoreh.github.io/ar4ds-wasm
```

Quarto Live also consults the repository of the webR project and takes a package from whichever source offers the higher version. The sites of the course change one line of their copy of the extension, so that a page that names a source uses that source alone.

## Licences

Each package is distributed under its own licence, stated in its `DESCRIPTION` file, and its source is on CRAN at the version listed in `versions.csv`.
