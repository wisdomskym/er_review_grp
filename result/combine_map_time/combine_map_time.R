
library(ggplot2)
library(patchwork)

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
g_time <- readRDS(
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
# Add panel labels

g_terr2 <- g_terr2 +
  labs(tag = "A") +
  theme(
    plot.tag = element_text(face = "bold", size = 16),
    plot.tag.position = c(0.02, 0.98)
  )

g_marine <- g_marine +
  labs(tag = "B") +
  theme(
    plot.tag = element_text(face = "bold", size = 16),
    plot.tag.position = c(0.02, 0.98)
  )

# ============================================== #
# Add label outside the plot panel

g_time <- cowplot::ggdraw(g_time) +
  cowplot::draw_plot_label(
    label = "C",
    x = 0.01,
    y = 0.98,
    hjust = 0,
    vjust = 1,
    size = 16,
    fontface = "bold"
  )



# ============================================== #
# Combine maps with a small gap

g_maps <- (
  g_terr2 | plot_spacer() | g_marine
) +
  plot_layout(
    widths = c(1, 0.05, 1)
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

g_combined




# ============================================== #
# Combine time plot and maps
# Time plot on top, maps on bottom

g_combined2 <- (
  patchwork::wrap_elements(
    full = g_time
  ) /
    patchwork::wrap_elements(
      full = g_maps
    )
) +
  plot_layout(
    heights = c(1.2, 1)
  )

g_combined2



# ============================================== #
# Export PNG

ggsave(
  filename = file.path(dir_out, "combined_studyarea_time.png"),
  plot = g_combined2,
  width = 30,
  height = 30,
  units = "cm",
  dpi = 600,
  bg = "white"
)


# ============================================== #
# Export PDF

ggsave(
  filename = file.path(dir_out, "combined_studyarea_time.pdf"),
  plot = g_combined2,
  width = 30,
  height = 30,
  units = "cm",
  device = cairo_pdf
)


# ============================================== #
# Export RDS

saveRDS(
  object = g_combined2,
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