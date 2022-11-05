args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]

# create store_dir if it does not already exist
store_dir <- paste0(dir_main, "/Finanzmarktdaten/")
if (!dir.exists(store_dir)) dir.create(store_dir, recursive = TRUE)

# function that returns vector of series codes
source("get_var_codes_bbk_financial.R")

# Bundesbank API
url_base <- "https://api.statistiken.bundesbank.de/rest/download/"
url_params <- "?format=csv&lang=en"

df_na <- data.frame()

fill_in_dates <- function(df)
{
  start_date <- "1991-01-01"
  if (min(df$dates) < start_date)
  {
    return(subset(df, dates >= start_date)) # data from January 1991 onwards
  } else
  {
    # fill in values before start of data frame with NA
    df_tmp <- data.frame(dates = seq(as.Date("1991-01-01"), max(df$dates), by = "month"), 
                         values = NA
                         )
    df_merged <- merge(df, df_tmp, by = "dates", all.y = TRUE)
    df_merged <- df_merged[, c("dates", "values.x")]
    names(df_merged)[2] <- "values"
    return(df_merged)
  }
}

for (series_code in get_var_codes_bbk_financial()) 
{
  series_code_category <- substr(series_code, 1, 5) 
  series_code_series <- substr(series_code, 7, nchar(series_code)) 
  dat <- read.csv(paste0(url_base, series_code_category, "/", series_code_series, url_params), skip = 8, stringsAsFactors = FALSE)
  dat <- dat[, c(1, 2)] # get rid of flags column!
  names(dat) <- c("dates", "values")
  dat[, 1] <- as.Date(paste0(dat[, 1], "-01"), format = "%Y-%m-%d")
  if (!is.numeric(dat$values)) dat$values <- as.numeric(dat$values) # make sure values are numeric!
  dat_export <- fill_in_dates(dat)
  write.csv(dat_export, file = paste0(store_dir, series_code, ".csv"), na = "NaN")
}
print("Done downloading financial market data!")
