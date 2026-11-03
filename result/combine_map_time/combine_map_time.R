
library(here)
library(ggplot2)
library(patchwork)


rts <- "C:/Users/wisdo/Dropbox/02_proj_cloud/_localrepo/basicscripts/script"
source(here(rts, "render_helpers.R"))
source(here(rts, "othersettings.R"))


# ============================================== #
# Settings ----
# ============================================== #

projname <- "combine_map_time"

# Output directory (timestamped)
dir_out <- make_output_dir(proj_name = projname)




# ============================================== #
# Import RDS files

# original maps
g_marine <- readRDS(
  file.path("result", "create_static_map", "studyarea_map_marine.rds")
)

g_terr2 <- readRDS(
  file.path("result", "create_static_map", "studyarea_map_terrestrial2.rds")
)



# Restore raster for map
relief1_japan <- terra::unwrap(
  readRDS(
    file.path("result", "create_static_map", "relief1_japan.rds")
  )
)



# time plot
g_time_orig <- readRDS(
  file.path("result", "reviewtable_organize", "study_period.rds")
)



# ============================================== #
# Restore RGB raster layer

restore_rgb <- function(g, raster) {
  
  # Construct a temporary plot
  g_rgb <- ggplot() +
    tidyterra::geom_spatraster_rgb(
      data = raster,
      maxcell = 1e6
    )
  
  # Extract the actual ggplot layer
  g$layers[[1]] <- g_rgb$layers[[1]]
  
  return(g)
}


# ============================================== #
# Apply to maps

g_marine <- restore_rgb(g_marine, relief1_japan)

g_terr2 <- restore_rgb(g_terr2, relief1_japan)





# ============================================== #
# Inspect text size

# # Overall structure
# str(g_terr2, max.level = 2)


# # # Overall structure
# str(g_time_orig, max.level = 2)




# ============================================== #
# Adjust text sizes (picked up by GPT)

# Study indices (geom_text)
g_terr2$layers[[5]]$aes_params$size <- 4
g_marine$layers[[5]]$aes_params$size <- 4

# Annotation text
g_terr2$layers[[6]]$aes_params$size <- 4





# Geom text layers
g_time_orig$layers[[2]]$aes_params$size <- 2.5
g_time_orig$layers[[3]]$aes_params$size <- 2.5
g_time_orig$layers[[4]]$aes_params$size <- 2.5

# Theme text
g_time_orig <- g_time_orig +
  theme(
    text = element_text(size = 12),
    axis.title.x = element_text(size = 12),
    axis.text.x = element_text(size = 10),
    strip.text = element_text(size = 10),
    
    # Plot margins: top, right, bottom, left
    plot.margin = margin(
      t = 5,
      r = 5,
      b = 5,
      l = 170,
      unit = "pt"
    )
  )

# ============================================== #
# Add panel labels

labelsize <- 11

g_terr2 <- g_terr2 +
  labs(tag = "A") +
  theme(
    plot.tag = element_text(face = "bold", size = labelsize),
    plot.tag.position = c(0.02, 0.98)
  )

g_marine <- g_marine +
  labs(tag = "B") +
  theme(
    plot.tag = element_text(face = "bold", size = labelsize),
    plot.tag.position = c(0.02, 0.98)
  )

# ============================================== #
# Add label outside the plot panel

g_time <- cowplot::ggdraw(g_time_orig) +
  cowplot::draw_plot_label(
    label = "C",
    x = 0.01,
    y = 0.98,
    hjust = 0,
    vjust = 1,
    size = 11,
    fontface = "bold"
  )



# ============================================== #
# Combine maps with a small gap

g_maps <- (
  g_terr2 | plot_spacer() | g_marine
) +
  plot_layout(
    widths = c(1, 0.02, 1)
  )


# ============================================== #
# Combine maps and time plot

g_combined <- (
  patchwork::wrap_elements(
    full = g_maps
  ) /
    patchwork::wrap_elements(
      full = g_time
    )
) +
  plot_layout(
    heights = c(1, 1.2)
  )

# g_combined



# ============================================== #
# Combine time plot and maps
# Time plot on top, maps on bottom

# g_combined2 <- (
#   patchwork::wrap_elements(
#     full = g_time
#   ) /
#     patchwork::wrap_elements(
#       full = g_maps
#     )
# ) +
#   plot_layout(
#     heights = c(1.2, 1)
#   )
# 
# g_combined2



# ============================================== #
# Export PNG

ggsave(
  filename = file.path(dir_out, "combined_studyarea_time.png"),
  plot = g_combined,
  width = 20,
  height = 25,
  units = "cm",
  dpi = 300,
  bg = "white"
)


# ============================================== #
# Export PDF

ggsave(
  filename = file.path(dir_out, "combined_studyarea_time.pdf"),
  plot = g_combined,
  width = 20,
  height = 20,
  units = "cm",
  device = cairo_pdf
)


# svg
ggsave(
  filename = file.path(dir_out, "combined_studyarea_time.svg"),
  plot = g_combined,
  width = 20,
  height = 20,
  units = "cm",
  device = "svg"
)

# ============================================== #
# Export RDS

saveRDS(
  object = g_combined,
  file = file.path(dir_out, "combined_studyarea_time.rds")
)





# ============================================== #
# Archive R script ----
# ============================================== #

script_file <- here("script", str_c(projname, ".R"))

file.copy(
  from = script_file,
  to = file.path(dir_out, basename(script_file)),
  overwrite = TRUE
)


# ============================================== #
# Update latest results ----
# ============================================== #

dir_result_proj <- here("result", projname)

if (dir.exists(dir_result_proj)) {
  fs::dir_delete(dir_result_proj)
}

fs::dir_copy(
  path = dir_out,
  new_path = dir_result_proj
)