#args <- commandArgs(trailingOnly = TRUE)
#dir_main <- args[length(args)]
dir_main = "C:/Users/Philipp/Desktop/Echtzeitdatensatz/raw data"

# create store_dir if it does not already exist
dir_dest <- paste0(dir_main, "/ESI BCI/")
if (!dir.exists(dir_dest)) dir.create(dir_dest, recursive = TRUE)

# download latest zip package
counter_max <- 10
counter <- 1
file_dest <- paste0(dir_dest, "tmp.zip")
yy <- as.numeric(format(Sys.Date(),"%y"))
mm <- as.numeric(format(Sys.Date(),"%m"))
mm <- 10
url_start <- "https://ec.europa.eu/economy_finance/db_indicators/surveys/documents/series/nace2_ecfin_"
url_end <- "/all_surveys_total_sa_nace2.zip"

looking_for_file = TRUE
while (looking_for_file)
{
  tryCatch(
    {
      if (mm < 10)
        url_data <- paste0(url_start, yy, "0", mm, url_end)
      else
        url_data <- paste0(url_start, yy, mm, url_end)

      file_dest <- paste0(dir_dest, "tmp.zip")
      download.file(url_data, destfile = file_dest, quiet = FALSE)
      unzip(file_dest, exdir = dir_dest, list = FALSE)
    },
    error = function(cond)
    {
      message(paste("URL does not seem to exist:", url_data))
      message("Here's the original error message:")
      message(cond)
      return(NA)
    },
    finally =
    {
      unlink(file_dest)
      print("Done downloading ESI series!")
      looking_for_file <- FALSE
    }
  )
  # update yy and mm
  if (mm == 1)
  {
    mm = 12
    yy = yy-1
  } else
  {
    mm = mm - 1
  }
}
