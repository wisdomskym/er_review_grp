# ======================================================================== #
# Render
# ======================================================================== #

library(here)
library(tidyverse)
library(fs)
library(quarto)

source(here("r", "render_helpers.R"))

# ------------------------------------------------------------------------ #
# master qmd
# ------------------------------------------------------------------------ #

projname <- "reviewtable_organize"
qmd_file <- here("script", str_c(projname, ".qmd"))

# in1: original review table
in1 <- here("data", "20260518_ER_reviewtable_merged_rangeshiftdata.csv")

# in2: cleaned review table
in2 <- here("data", "20260819_ER_reviewtable_cleaning.xlsx")


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
