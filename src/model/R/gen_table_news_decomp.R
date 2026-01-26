args <- commandArgs(trailingOnly = TRUE)
dir_root <- args[1]
nowcast_year <- args[2]
nowcast_quarter <- args[3]
# for debugging
# dir_root <- "C:/Users/Hauber-P/Documents/dev"
# nowcast_year <- 2025
# nowcast_quarter <- 4

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

gen_table_news_decomp <- function(dat, str_target, str_period, str_model, str_footnote_vintage, str_footnote_model){
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
    icon = "",
    trafo = gt::html(fontawesome::fa("screwdriver-wrench")),
    ref_period = gt::html(fontawesome::fa("calendar-days"))
  ) |> 
  gt::fmt_icon(columns = "icon", height = "1em") |>
  gt::cols_align(align = "center", columns = "icon") |>   
  gt::cols_align(align = "center", columns = "trafo") |> 
  gt::cols_align(align = "center", columns = "ref_period") |>    
  gt::fmt_markdown(columns = trafo) |> 
  gt::tab_style(
    style = list(
      cell_fill(color = "gray95"),
      cell_text(align = "center", weight = "bold")
    ),
    locations = cells_row_groups(groups = everything())
  ) |> 
  gt::tab_style(
    style = cell_text(size = "smaller"),
    locations = cells_body(columns = c("ref_period", "trafo"))
  ) |> 
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
      cell_fill(color = "#FFC7CE"),
      cell_text(color = "#9C0006", weight = "bold")
    ),
    locations = cells_body(
      columns = impact,
      rows = impact < 0
    )
  ) |> 
  gt::tab_footnote(
    footnote = str_footnote_vintage,
    locations = cells_title(groups = "title")
  ) |> 
  gt::tab_footnote(
    footnote = "impact = (forecast - actual) x weight",
    locations = cells_column_labels(columns = "impact")
  ) |>
  gt::tab_footnote(
    footnote = str_footnote_model,
    locations = cells_title(groups = "subtitle")
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

# calculate reference period ----
df_historic <- read.csv(paste0(dir_root, "/Echtzeitdatensatz/vintages/vintages.csv"))
df_historic$vintage <- readr::parse_date(df_historic$vintage)
df_historic$period <- readr::parse_date(df_historic$period)

df_historic <- df_historic |>
  fmutate(bothNA = is.na(raw) & is.na(value)) |>
  fsubset(!bothNA) |> 
  fselect(-bothNA)

df_news <- collapse::join(
  df_news,
  df_historic |> 
  fgroup_by(vintage, variable, group) |> 
  fmutate(is_max_period = period == max(period)) |> 
  fungroup() |> 
  fsubset(is_max_period) |> 
  fmutate(ref_period = paste0(lubridate::year(period), "M", lubridate::month(period))) |> 
  fselect(vintage, group, variable, ref_period),
  on = c("vintage", "variable", "group"),
  how = "left"
)

# add trafo column ----
df_news <- collapse::join(
  df_news, 
  df_historic |> 
    fselect(variable, group, trafo),
  on = c("variable", "group"),
  how = "left"
)
# recode
df_news$trafo[df_news$trafo == "1"] <- "-"
df_news$trafo[df_news$trafo == "2"] <- "$\\Delta$"
df_news$trafo[df_news$trafo == "3"] <- "$\\Delta \\text{log()}$"

# loop to generate and save tables ----
models <- unique(df_news$model) 
n_spec <- length(setdiff(models, "equal-weight pool"))
targets <- unique(df_news$target)
periods <- unique(df_news$period)
threshold_impact <- 0.01

for (t in targets){
  for (p in periods){
    for (m in models){      
      df_tmp <- df_news |> 
        fsubset(target == t & period == p & model == m)

      # generate vintage footnote
      vintages_all <- sort(unique(df_tmp$vintage))
      df_tmp <- df_tmp |> 
        collapse::fmutate(abs_val = abs(impact)) |> 
        collapse::fsubset(abs_val >= threshold_impact) |>  
        collapse::roworder(-abs_val) |> 
        collapse::fselect(icon, vintage, group, variable, ref_period, trafo, forecast, actual, weight, impact)

      vintages <- sort(unique(df_tmp$vintage))
      str_footnote_vintage <- paste0("Variable releases with an absolute impact smaller than ", threshold_impact, " have been dropped.", ifelse(length(setdiff(vintages_all, vintages)) == 0, "", paste0(" There were no releases with an absolute impact larger than ", threshold_impact, " for the following vintages: ", as.Date(setdiff(vintages_all, vintages)))))

      # generate model footnote
      if (m == "equal-weight pool"){
        str_footnote_model <- paste0("Average forecast, weight and impact across ", n_spec, " model specifications")
      } else {
          parts <- base::strsplit(m, "_")[[1]]  
          nr_val <- parts[2]
          np_val <- parts[4]
          nj_val <- parts[6]
          str_footnote_model <- paste0(
            "Model with ", nr_val, " factor(s), ", 
            np_val, " lag(s) in the factor VAR and ", 
            ifelse(
              nj_val == 0, 
              "no auto-correlation in the idiosyncratic components",
            paste0(" AR(", nj_val, ") idiosyncratic components")
            )
          )
      }

      # now we are good to go! 
      gen_table_news_decomp(
        df_tmp,
        str_target = t, 
        str_period = p, 
        str_model = m,
        str_footnote_vintage = str_footnote_vintage,
        str_footnote_model = str_footnote_model
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