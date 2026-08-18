library(here)
library(fs)
library(stringr)

# make_output_dir <- function(proj_name, label = NULL, base_dir = "output") {
#   datetime <- format(Sys.time(), "%Y%m%d-%H%M%S")
#   
#   project_folder <- if (!is.null(label) && nzchar(label)) {
#     str_c(proj_name, label, sep = "_")
#   } else {
#     proj_name
#   }
#   
#   dir_out <- here(base_dir, project_folder, datetime)
#   dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
#   
#   dir_out
# }

make_output_dir <- function(proj_name, label = NULL, base_dir = "output") {
  
  datetime <- format(Sys.time(), "%Y%m%d-%H%M%S")
  
  run_folder <- if (!is.null(label) && nzchar(label)) {
    str_c(label, datetime, sep = "_")
  } else {
    datetime
  }
  
  dir_out <- here(base_dir, proj_name, run_folder)
  
  dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
  
  dir_out
}



archive_render_outputs <- function(qmd_file,
                                   output_file,
                                   dir_out,
                                   render_script = NULL) {
  
  qmd_dir <- dirname(qmd_file)
  qmd_name <- tools::file_path_sans_ext(basename(qmd_file))
  
  src_html  <- file.path(qmd_dir, str_c(output_file, ".html"))
  src_files <- file.path(qmd_dir, str_c(output_file, "_files"))
  src_qmd   <- qmd_file
  
  dst_html  <- file.path(dir_out, str_c(output_file, ".html"))
  dst_files <- file.path(dir_out, str_c(output_file, "_files"))
  dst_qmd   <- file.path(dir_out, basename(qmd_file))
  
  if (file.exists(src_html)) {
    fs::file_move(src_html, dst_html)
  }
  
  if (dir.exists(src_files)) {
    fs::dir_copy(src_files, dst_files, overwrite = TRUE)
  }
  
  if (file.exists(src_qmd)) {
    fs::file_copy(src_qmd, dst_qmd, overwrite = TRUE)
  }
  
  if (!is.null(render_script) && file.exists(render_script)) {
    dst_render <- file.path(dir_out, basename(render_script))
    fs::file_copy(render_script, dst_render, overwrite = TRUE)
  }
}


check_scenario <- function(sc) {
  required_names <- c(
    "label", "in1", "in2", "in3", "in4",
    "exclude_sites", "exclude_site_plots"
  )
  
  missing_names <- setdiff(required_names, names(sc))
  
  if (length(missing_names) > 0) {
    stop("Scenario is missing: ", paste(missing_names, collapse = ", "))
  }
  
  invisible(TRUE)
}



# # Function for reorganizing folder structure
# # This is not used often but it was used to reorganize folder structure
# #  following changes in how I name the output directory (20260703)
#
# reorganize_output_dirs <- function(proj_name,
#                                    base_dir = here::here("output"),
#                                    dry_run = TRUE) {
#   dirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
#   
#   pattern <- paste0("^", proj_name, "(_.*)?_(\\d{8}-\\d{6})$")
#   
#   moves <- purrr::map_dfr(dirs, function(old_dir) {
#     old_name <- basename(old_dir)
#     
#     m <- stringr::str_match(old_name, pattern)
#     
#     if (is.na(m[, 1])) return(NULL)
#     
#     extra_info <- m[, 2]
#     datetime   <- m[, 3]
#     
#     extra_info <- stringr::str_remove(extra_info, "^_")
#     
#     new_subfolder <- if (!is.na(extra_info) && nzchar(extra_info)) {
#       paste(extra_info, datetime, sep = "_")
#     } else {
#       datetime
#     }
#     
#     tibble::tibble(
#       from = old_dir,
#       to = file.path(base_dir, proj_name, new_subfolder)
#     )
#   })
#   
#   print(moves)
#   
#   if (!dry_run) {
#     purrr::walk2(moves$from, moves$to, function(from, to) {
#       if (dir.exists(to)) {
#         warning("Destination already exists, skipping: ", to)
#       } else {
#         dir.create(dirname(to), recursive = TRUE, showWarnings = FALSE)
#         file.rename(from, to)
#       }
#     })
#   }
#   
#   invisible(moves)
# }
# 
# # # First check
# # reorganize_output_dirs("prec_nordicgrid", dry_run = T)
# 
# # # Then run
# # reorganize_output_dirs("visualize_vege_density", dry_run = F)
# 







