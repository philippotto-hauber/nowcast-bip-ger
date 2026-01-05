library(collapse)
library(ggplot2)

# load data ----
df_fore <- read.csv("C:/Users/Hauber-P/Documents/dev/Nowcasts/2025Q4/output_csv/forecasts.csv")
df_fore$vintage <- readr::parse_date(df_fore$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))
df_fore$period <- readr::parse_date(df_fore$period, format = "%d-%b-%Y", locale = readr::locale("en"))

df_news <- read.csv("C:/Users/Hauber-P/Documents/dev/Nowcasts/2025Q4/output_csv/news.csv")
df_news$vintage <- readr::parse_date(df_news$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))

df_news$group[df_news$group == "ifo" | df_news$group == "ESI"] <- "surveys"

vintages <- unique(df_news$vintage) 

# plot evolution of nowcasts ----

plt_nowcast_and_news <- function(df_fore, df_news, vintages, str_title, ew_pool = FALSE){
  # nowcasts 
  df_ew_pool <- df_fore |> 
    fgroup_by(vintage) |> 
    fsummarise(ew_pool = mean(value))
  
  plt_fore <- df_fore |> 
    fsubset(vintage %in% vintages) |> 
    ggplot()+
    geom_point(aes(x = vintage, y = value), size = 0.9, alpha = 0.5)+
    geom_line(
      mapping = aes(x = vintage, y = ew_pool), 
      data = df_ew_pool |> fsubset(vintage %in% vintages),
      linewidth = 1.1
    )+
    geom_label(
      mapping = aes(x = vintage, y = ew_pool, label = round(ew_pool, 2)), 
      data = df_ew_pool |> fsubset(vintage %in% vintages), 
      size = 3
    )+
    scale_x_date(breaks = vintages, date_labels = "%b %d", limits = c(min(vintages) - lubridate::days(7), max(vintages) + lubridate::days(7)))+ 
    labs(
      title = str_title,
      subtitle = "Nowcasts",
      caption = if(ew_pool) "Dots represent forecasts of different model specifications, the line and labels indicate the equally-weighted pool." else NULL,
      x = "", y = "%"
    )+
    theme_minimal()
  
  # news
  npg_modified <- c(
    "production"      = "#8B0000", 
    "surveys" = "#E65100", 
    "orders" = "#FFB300", 
    "turnover"      = "#4DBBD5FF", 
    "national accounts"      = "#00A087FF", 
    "prices"      = "#3C5488FF", 
    "labor market"      = "#845EC2", 
    "financial"      = "#8491B4FF",
    "revisions" = "#1B1B1B"
  )
  
  df_plt_news <- df_news |> 
    fselect(model, vintage, group, impact) |>
    fgroup_by(vintage, group, model) |>
    fsummarise(sum_model = sum(impact)) |>
    fgroup_by(vintage, group) |>
    fsummarise(impact_ew_pool = mean(sum_model))
  
  # add impact of revisions (i.e. change in forecast not explained by variable impacts!)
  df_rev <- df_plt_news |> fgroup_by(vintage) |> fsummarise(sum_impact = sum(impact_ew_pool))
  df_rev$delta <- diff(df_ew_pool$ew_pool)
  df_rev$revision <- df_rev$delta - df_rev$sum_impact
  df_plt_news <- rbind(df_plt_news, data.frame(vintage = df_rev$vintage, group = "revisions", impact_ew_pool = df_rev$revision))
  
  plt_news <- df_plt_news |> 
    ggplot(aes(x = vintage, y = impact_ew_pool, group = group, fill = group))+
    geom_bar(position = "stack", stat="identity", width = 6)+
    scale_x_date(breaks = vintages, date_labels = "%b %d", limits = c(min(vintages) - lubridate::days(7), max(vintages) + lubridate::days(7)))+ 
    labs(
      subtitle = "News decomposition", 
      caption = if(ew_pool) "Average impacts across different model specifications." else NULL,
      x = "", y = "percentage points"
    )+
    theme_minimal()+
    theme(
      legend.position = "bottom",
      legend.title = element_blank()
    )+
    scale_fill_manual(values = npg_modified)
  
  # combined plots
  plt <- ggpubr::ggarrange(plt_fore, plt_news, ncol = 1, nrow = 2, heights = c(1, 2))
  return(plt)
}

clean_up_model_name <- function(x){
  # 1. Replace the first underscore in each pair with " = "
  # Matches an underscore followed by a digit
  res <- gsub("_(\\d)", " = \\1", x)
  
  # 2. Replace the remaining underscores with ", "
  # Matches an underscore followed by a letter
  res <- gsub("_([A-Za-z])", ", \\1", res)
  
  return(res)
}


flt_period <- "2025-12-01"
flt_variable <- "gross domestic product"

plt_nowcast_and_news(
  fsubset(df_fore, period == flt_period  & variable == flt_variable),
  fsubset(df_news, period == paste0(lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) / 3))  & target == flt_variable),
  vintages,
  paste0(flt_variable, " (", lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) /3), "): equal-weight pool"),
  ew_pool = TRUE
)

flt_model = "Nr_5_Np_3_Nj_1"
plt_nowcast_and_news(
  fsubset(df_fore, period == flt_period  & variable == flt_variable & model == flt_model),
  fsubset(df_news, period == paste0(lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) / 3))  & target == flt_variable & model == flt_model),
  vintages,
  paste0(flt_variable, " (", lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) /3), "): ", clean_up_model_name(flt_model))
)







