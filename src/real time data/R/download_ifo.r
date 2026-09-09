args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]
dir_main = "C:/Users/Hauber-P/Documents/Echtzeitdatensatz/raw data"

# create store_dir if it does not already exist
dir_dest <- paste0(dir_main, "/ifo")
if (!dir.exists(dir_dest)) dir.create(dir_dest, recursive = TRUE)

file_dest <- paste0(dir_dest, "/ifo_current.xlsx")

# NOTE: ifo.de now sits behind a bot-protection WAF that returns HTTP 200
# with an HTML "Client Challenge" page for any non-browser request to this
# path, instead of a real 403 for missing files. That means we can no longer
# tell "file exists" from "file missing" via status code alone, and this
# script can no longer download the file automatically. Until that's solved
# (e.g. by ifo whitelisting programmatic access), download ifo_current.xlsx
# manually from ifo.de and place it in dir_dest -- this script just checks
# that a real xlsx is already there and otherwise leaves it untouched.

yy <- as.numeric(format(Sys.Date(),"%Y"))
mm <- as.numeric(format(Sys.Date(),"%m"))
url_start <- "https://www.ifo.de/sites/default/files/secure/timeseries/gsk-d-"
url_end <- ".xlsx"

is_xlsx <- function(resp) {
  ctype <- httr::headers(resp)[["content-type"]]
  !is.null(ctype) && grepl("spreadsheet|officedocument|application/vnd", ctype, ignore.case = TRUE)
}

max_tries <- 3
looking_for_file <- TRUE
downloaded <- FALSE
n_tries <- 0

while (looking_for_file && n_tries < max_tries)
{
  n_tries <- n_tries + 1

  if (mm < 10){
    url_data <- paste0(url_start, yy, "0", mm, url_end)
  } else {
    url_data <- paste0(url_start, yy, mm, url_end)
  }

  resp <- httr::GET(url_data)

  if (resp$status_code == 200 && is_xlsx(resp)) {
    writeBin(httr::content(resp, "raw"), file_dest)
    print(paste0("Done downloading ", url_data, " to ", file_dest, "!"))
    downloaded <- TRUE
    looking_for_file <- FALSE
  } else if (resp$status_code == 403) {
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
    # 200 but not a real xlsx -> almost certainly the WAF challenge page.
    looking_for_file <- FALSE
  }
}

if (!downloaded) {
  if (file.exists(file_dest)) {
    print(paste0("Skipped auto-download (blocked by ifo.de); keeping existing file: ", file_dest))
  } else {
    warning(paste0(
      "Could not download ifo_current.xlsx automatically (ifo.de's bot ",
      "protection is blocking this request). Please download it manually ",
      "from ifo.de and save it to: ", file_dest
    ))
  }
}
