# ======================================================================== #
# Setup R project and check R Version
# Previous file name: "_checkRversion_20260323.R"
# ======================================================================== #

# ======================================================================== #
# load

pacman::p_load(
  # data import
  here,
  
  # data manipulation
  tidyverse,
  
  # misc,
  usethis,
  sessioninfo,
  report
)



# =================================== #
# create directory
# https://www.projecttier.org/tier-protocol/protocol-4-0/root/

dir.create(here("data"))                # for data, read only
dir.create(here("r"))                   # for function script, source this in analysis
dir.create(here("script"))              # code to run the project
dir.create(here("output"))              # plots, logs, etc
dir.create(here("result"))              # export of results using Rmarkdown




# =================================== #
# record rversion and session info

# record datetime
datetime <- format(Sys.time(), "%Y%m%d-%H%M%OS")

# text filename
textfile <- here("output", 
                 str_c("Rversion_",datetime,".txt"))


# --------------------- #
# send records to text
sink(textfile) # sink()

# title
cat("R version memo")
cat("\n\n")
cat(R.version.string)
cat("\n\n")

# time
cat(str_c(datetime))
cat("\n\n\n\n")

# session info
cat("sessionInfo()")
cat("\n\n")

sessionInfo()
cat("\n\n\n\n")


# session info
cat("session_info()")
cat("\n\n")

session_info()
cat("\n\n\n\n")


# session info
cat("cite_packages()")
cat("\n\n")

cite_packages()
cat("\n\n\n\n")


# tidyverse info
cat("tidyverse_packages()")
cat("\n\n")

tidyverse_packages()


# end sending records to text
sink()
# --------------------- #









