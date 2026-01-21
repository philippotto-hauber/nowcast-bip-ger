library(collapse)
library(ggplot2)
library(gt)

# load data ----
df_news <- read.csv("C:/Users/Hauber-P/Documents/dev/Nowcasts/2025Q4/output_csv/news.csv")
df_news$vintage <- readr::parse_date(df_news$vintage, locale = readr::locale("en"))

vintages <- unique(df_news$vintage) 

models <- unique(df_news$model) 
targets <- unique(df_news$target)
periods <- unique(df_news$period)

gen_table_news_decomp <- function(dat, threshold, str_target, str_period, str_model){
  vintages_all <- sort(unique(dat$vintage))
  dat <- dat |> 
  collapse::fmutate(abs_val = abs(impact)) |> 
  collapse::fsubset(abs_val >= threshold) |>  
  collapse::roworder(-abs_val) |> 
  collapse::fselect(vintage, group, variable, forecast, actual, weight, impact)
  
  vintages <- sort(unique(dat$vintage))

  str_footnote <- paste0("Variable releases with an absolute impact smaller than ", threshold, " have been dropped. There were no releases with an absolute impact larger than for the following vintages: ", as.Date(setdiff(vintages_all, vintages)))

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
    decimals = 4
  ) |> 
  gt::tab_spanner(
    label = "impact = (forecast - actual) x weight",
    columns = c(forecast, actual, weight, impact)
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
  tab_footnote(
    footnote = str_footnote,
    location = cells_title(groups = "title"),
    placement = "right"
  )
  return(t)
}

t = "private consumption"
p = "2026Q1"
m = "Nr_2_Np_1_Nj_0"

dat_test <- df_news |> 
    fsubset(target == t & model == m & period == p)

# dat_test <- dat_test |> 
#   collapse::fmutate(abs_val = abs(impact)) |> 
#   collapse::fsubset(abs_val >= 0.0001) |>  
#   collapse::roworder(-abs_val) |> 
#   collapse::fselect(vintage, group, variable, forecast, actual, weight, impact) 

# dat_test |> 
#   gt(groupname_col = "vintage") |> 
#   row_group_order(groups = rev(as.character(vintages)))


#   t <- dat |> 
#   collapse::fmutate(abs_val = abs(impact)) |> 
#   collapse::fsubset(abs_val >= threshold) |>  
#   collapse::roworder(-abs_val) |> 
#   collapse::fselect(vintage, group, variable, forecast, actual, weight, impact) |>     
#   gt::gt(groupname_col = vintage) |>
#   row_group_order(groups = rev(as.character(unique(dat$vintage))))

gen_table_news_decomp(
  dat_test,
  threshold = 0.005,
  str_target = t, 
  str_period = p, 
  str_model = m
)

for (t in targets){
  for (p in periods){
    for (m in models){
      for (v in vintages){
        gen_table_news_decomp(
          df_news |> 
            fsubset(target == t & period == p & vintage == v & model == m),
          str_target = t, 
          str_period = p, 
          str_vintage = v,
          str_model = m
        )
      }
    }
  }
}

# Example data
df <- head(mtcars)

gt_table <- df |>
  gt() |>
  # Set a container height for scrolling
  tab_options(
    container.height = px(200)
  ) |>
  # Apply sticky CSS for headers and stub column
  opt_css(
    css = "
      .gt_col_heading { position: sticky; top: 0; }
      .gt_stub { position: sticky; left: 0; }
      thead th:first-child { left: 0; z-index: 2; }
      .gt_table { border-collapse: separate; border-spacing: 0; }
    "
  )

gt_table


tmp <- df_news |> 
  fsubset(target == "gross domestic product" & period == "2025Q4" & vintage == max(vintages) & model == models[1]) |> 
  fselect(group, variable, forecast, actual, weight, impact)





tmp |> 
  fmutate(abs_val = abs(impact)) |> 
  roworder(-abs_val) |> 
  fselect(-abs_val) |> 
  gt() |>
  tab_header(
    title = "News decomposition: 2025Q4",
    subtitle = glue::glue("GDP, 2026-01-15")
  ) |>
  fmt_number(
    columns = c("forecast", "actual"),
    decimals = 2
  ) |> 
  fmt_number(
    columns = c("weight", "impact"),
    decimals = 4
  ) |> 
  tab_spanner(
    label = "impact = (forecast - actual) x weight",
    columns = c(
      forecast, actual, weight, impact
    )
  ) |> 
  tab_style(
    style = list(
      cell_fill(color = "#C6EFCE"), # Light Green
      cell_text(color = "#006100", weight = "bold") # Dark Green Bold Text
    ),
    locations = cells_body(
      columns = impact,
      rows = impact > 0
    )
  ) |> 
  tab_style(
    style = list(
      cell_fill(color = "#FFC7CE"), # Light Red
      cell_text(color = "#9C0006", weight = "bold") # Dark Red Bold Text
    ),
    locations = cells_body(
      columns = impact,
      rows = impact < 0
    )
  ) |> 
  gtsave("test.html")



  