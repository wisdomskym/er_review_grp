# ======================================================================== #
# Render
# ======================================================================== #

library(here)
library(tidyverse)
library(fs)
library(quarto)

rts <- "C:/Users/wisdo/Dropbox/02_proj_cloud/_localrepo/basicscripts/script"
source(here(rts, "render_helpers.R"))
source(here(rts, "othersettings.R"))
# ------------------------------------------------------------------------ #
# master qmd
# ------------------------------------------------------------------------ #

projname <- "prisma_diagram"
qmd_file <- here("script", str_c(projname, ".qmd"))

# PRISMA2020-format input table
in1 <- "PRISMA_erdata_20261103.csv"

in2 <- ""



# ============================================== #
# Render ----
# ============================================== #

# output directory
dir_out <- make_output_dir(proj_name = projname)

quarto::quarto_render(
  input = qmd_file,
  output_format = "html",
  output_file = projname,
  execute_params = list(
    in1 = in1,
    in2 = in2,
    dir_out = dir_out
  )
)

# archive rendered html, *_files, qmd, and render script
archive_render_outputs(
  qmd_file = qmd_file,
  output_file = projname,
  dir_out = dir_out,
  render_script = here("script", str_c(projname, "_render.R"))
)


# ------------------------------------- #
# update latest results

dir_result_proj <- here("result", projname)

if (dir.exists(dir_result_proj)) {
  fs::dir_delete(dir_result_proj)
}

fs::dir_copy(
  path = dir_out,
  new_path = dir_result_proj
)

# ============================================== #
