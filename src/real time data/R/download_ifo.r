args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]
# dir_main = "C:/Users/Hauber-P/Documents/dev/Echtzeitdatensatz/raw data"

# create store_dir if it does not already exist
dir_dest <- paste0(dir_main, "/ifo")
if (!dir.exists(dir_dest)) dir.create(dir_dest, recursive = TRUE)

file_dest <- paste0(dir_dest, "/ifo_current.xlsx")
yy <- as.numeric(format(Sys.Date(),"%Y"))
mm <- as.numeric(format(Sys.Date(),"%m"))
url_start <- "https://www.ifo.de/sites/default/files/secure/timeseries/gsk-d-"
url_end <- ".xlsx"

looking_for_file = TRUE
while (looking_for_file)
{
  if (mm < 10)
    url_data <- paste0(url_start, yy, "0", mm, url_end)
  else
    url_data <- paste0(url_start, yy, mm, url_end)
  
  if (class(try(download.file(url = url_data, destfile = file_dest, mode = "wb"))) == "try-error"){
    # update yy and mm
    if (mm == 1)
    {
      mm = 12
      yy = yy-1
    } else
    {
      mm = mm - 1
    }
  } else {
    print(paste0("Done downloading ", url_data, " to ", file_dest, "!"))
    looking_for_file <- FALSE
  }
}
