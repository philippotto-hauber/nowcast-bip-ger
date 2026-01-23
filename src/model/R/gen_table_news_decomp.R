# args <- commandArgs(trailingOnly = TRUE)
# dir_root <- args[1]
# nowcast_year <- args[2]
# nowcast_quarter <- args[3]
# for debugging
dir_root <- "C:/Users/Hauber-P/Documents/dev"
nowcast_year <- 2025
nowcast_quarter <- 4

# setup ----
library(collapse)
library(ggplot2)
library(gt)

vars <- data.frame(
  name = c("gross domestic product", "private consumption", "private gross fixed capital formation", "exports"),
  mnemonic = c("Y", "C", "I", "X")
)

dir_tables <- paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/tables/")
if (!dir.exists(paste0(dir_tables, "/models"))) dir.create(paste0(dir_tables, "/models"), recursive = TRUE)

gen_table_news_decomp <- function(dat, threshold, str_target, str_period, str_model, flag_ew = FALSE){
  vintages_all <- sort(unique(dat$vintage))
  dat <- dat |> 
  collapse::fmutate(abs_val = abs(impact)) |> 
  collapse::fsubset(abs_val >= threshold) |>  
  collapse::roworder(-abs_val) |> 
  collapse::fselect(icon, vintage, group, variable, forecast, actual, weight, impact)
  
  vintages <- sort(unique(dat$vintage))

  str_footnote <- paste0("Variable releases with an absolute impact smaller than ", threshold, " have been dropped.", ifelse(length(setdiff(vintages_all, vintages)) == 0, "", paste0(" There were no releases with an absolute impact larger than for the following vintages: ", as.Date(setdiff(vintages_all, vintages)))))

  t <- dat |> 
  gt::gt(groupname_col = "vintage") |>
  row_group_order(groups = rev(as.character(vintages))) |> 
  gt::tab_header(
    title = paste0("News decomposition: ", str_target, " forecasts for ", str_period),
    subtitle = glue::glue("model: ", str_model)
  ) |>
  gt::fmt_number(
    columns = c("forecast", "actual"),
    decimals = 2
  ) |> 
  gt::fmt_number(
    columns = c("weight", "impact"),
    decimals = 3
  ) |> 
  gt::cols_label(
    icon = ""
  ) |> 
  gt::tab_spanner(
    label = "impact = (forecast - actual) x weight",
    columns = c(forecast, actual, weight, impact)
  ) |> 
  gt::fmt_icon(columns = "icon", height = "1em") |>
  gt::cols_align(align = "center", columns = "icon") |>   
  gt::tab_style(
    style = list(
      cell_fill(color = "#C6EFCE"),
      cell_text(color = "#006100", weight = "bold")
    ),
    locations = cells_body(
      columns = impact,
      rows = impact > 0
    )
  ) |> 
  gt::tab_style(
    style = list(
      cell_fill(color = "gray95"),
      cell_text(size = "larger", align = "center", weight = "bold")
    ),
    locations = cells_row_groups(groups = everything())
  ) |> 
  gt::tab_style(
    style = list(
      cell_fill(color = "#FFC7CE"),
      cell_text(color = "#9C0006", weight = "bold")
    ),
    locations = cells_body(
      columns = impact,
      rows = impact < 0
    )
  ) |> 
  tab_footnote(
    footnote = str_footnote,
    location = cells_title(groups = "title")
  ) 
  return(t)
}

# load data ----
df_news <- read.csv(paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/output_csv/news.csv"))
df_news$vintage <- readr::parse_date(df_news$vintage, locale = readr::locale("en"))

# calculate equal-weight pool ----
df_ew <- df_news |> 
  fgroup_by(vintage, period, target, variable, group) |> 
  fsummarise(
    forecast = mean(forecast),
    actual = mean(actual),
    weight = mean(weight),
    impact = mean(impact)
  ) |> 
  fmutate(model = "equal-weight pool")

df_news <- rbind(df_news, df_ew)

# add column with icons ----
icon_map <- c(
  "production"   = "industry",
  "orders"       = "clipboard-list",
  "turnover"     = "money-bill-transfer",
  "prices"       = "euro-sign",
  "labor market" = "people-group",
  "financial"    = "landmark",
  "ifo"      = "pen-to-square",
  "ESI"      = "pen-to-square",
  "national accounts" = "magnifying-glass-chart"
)

df_news <- df_news |> 
  collapse::fmutate(
    icon = icon_map[group]
  )

# loop to generate and save tables ----
models <- unique(df_news$model) 
targets <- unique(df_news$target)
periods <- unique(df_news$period)

m <- "equal-weight pool"
t <- targets[1]
p <- periods[1]

gen_table_news_decomp(
        df_news |> 
          fsubset(target == t & period == p & model == m),
        threshold = 0.01,
        str_target = t, 
        str_period = p, 
        str_model = m
      )

for (t in targets){
  for (p in periods){
    for (m in models){
      gen_table_news_decomp(
        df_news |> 
          fsubset(target == t & period == p & model == m),
        threshold = 0.01,
        str_target = t, 
        str_period = p, 
        str_model = m
      ) |> 
      gtsave(
        ifelse(
          m == "equal-weight pool", 
          paste0(dir_tables, vars$mnemonic[which(vars$name == t)], "_", p, "_", m, ".html"),
          paste0(dir_tables, "models/", vars$mnemonic[which(vars$name == t)], "_", p, "_", m, ".html")
        )
      )

    }
  }
}