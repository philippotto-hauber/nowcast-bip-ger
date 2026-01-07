args <- commandArgs(trailingOnly = TRUE)
dir_root <- args[1]
nowcast_year <- args[2]
nowcast_quarter <- args[3]
# for debugging
# dir_root <- "C:/Users/Hauber-P/Documents/dev"
# nowcast_year <- 2025
# nowcast_quarter <- 4

# functions ----
clean_up_model_name <- function(x){
  # 1. Replace the first underscore in each pair with " = "
  # Matches an underscore followed by a digit
  res <- gsub("_(\\d)", " = \\1", x)
  
  # 2. Replace the remaining underscores with ", "
  # Matches an underscore followed by a letter
  res <- gsub("_([A-Za-z])", ", \\1", res)
  
  return(res)
}

convert_date_to_str <- function(d){
  return(paste0(lubridate::year(d), "Q", ceiling(lubridate::month(d) / 3)))
}

convert_str_to_date <- function(y, q){
  return(as.Date(paste0(y, "-", as.numeric(q) * 3, "-01")))
}

get_now_and_forecast_periods <- function(year_nowcast, quarter_nowcast) {
  now <- as.Date(paste0(year_nowcast, "-", 3 * as.numeric(quarter_nowcast), "-01"))
  if (quarter_nowcast == "4") {
    # Increment the year and set quarter to Q1
    next_year <- as.numeric(year_nowcast) + 1
    fore <- as.Date(paste0(next_year, "-03-01"))
  } else {
    fore <- as.Date(paste0(year_nowcast, "-", 3 * (as.numeric(quarter_nowcast) + 1), "-01"))
  }
  
  return(c(now, fore))
}

source(here::here("src", "model", "R", "plt_nowcasts_news.R"))
source(here::here("src", "model", "R", "plt_range_of_forecasts.R"))

# set-up ----
library(ggplot2)
library(collapse)

vars <- data.frame(
  name = c("gross domestic product", "private consumption", "private gross fixed capital formation", "exports"),
  mnemonic = c("Y", "C", "I", "X")
)

periods <- get_now_and_forecast_periods(nowcast_year, nowcast_quarter)

for (flt_period in periods) print(flt_period)

dir_graphs <- paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/graphs/")

if (!dir.exists(paste0(dir_graphs, "/models"))) dir.create(paste0(dir_graphs, "/models"))

# load data ----
df_fore <- read.csv(paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/output_csv/forecasts.csv"))
df_fore$vintage <- readr::parse_date(df_fore$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))
df_fore$period <- readr::parse_date(df_fore$period, format = "%d-%b-%Y", locale = readr::locale("en"))

df_news <- read.csv(paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/output_csv/news.csv"))
df_news$vintage <- readr::parse_date(df_news$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))

df_news$group[df_news$group == "ifo" | df_news$group == "ESI"] <- "surveys"

vintages <- unique(df_news$vintage) 
models <- unique(df_news$model)

# generate plots ----

for (i in seq(1, nrow(vars))){
  flt_variable <- vars$name[i]
  
  for (j in seq(1, length(periods))){
    flt_period <- periods[j]
    plt_nowcast_and_news(
      fsubset(df_fore, period == flt_period  & variable == flt_variable),
      fsubset(df_news, period == paste0(lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) / 3))  & target == flt_variable),
      vintages,
      paste0(flt_variable, " (", convert_date_to_str(flt_period), "): equal-weight pool"),
      ew_pool = TRUE
    )
    ggsave(
      paste0(dir_graphs, vars$mnemonic[i], "_", convert_date_to_str(flt_period), "_equalweightpool.pdf"), 
      width = 20, 
      height = 15, 
      units = "cm"
    )

    for (flt_model in models){
      plt_nowcast_and_news(
        fsubset(df_fore, period == flt_period  & variable == flt_variable & model == flt_model),
        fsubset(df_news, period == convert_date_to_str(flt_period) & target == flt_variable & model == flt_model),
        vintages,
        paste0(flt_variable, " (", convert_date_to_str(flt_period), "): ", clean_up_model_name(flt_model))
      )
      
      ggsave(
        paste0(dir_graphs, "models/", vars$mnemonic[i], "_", convert_date_to_str(flt_period), "_", flt_model, ".pdf"), 
        width = 20, 
        height = 15, 
        units = "cm"
      )
    }
    
    plt_fancharts(
      fsubset(df_fore, variable == flt_variable & period == flt_period), 
      vintages,
      paste0(flt_variable, " (", convert_date_to_str(flt_period), ")")
    )
    
    ggsave(
      paste0(dir_graphs, vars$mnemonic[i], "_", convert_date_to_str(flt_period), "_range_of_forecasts.pdf"), 
      width = 20, 
      height = 15, 
      units = "cm"
    )
  }
}

print("Done generating plots!")