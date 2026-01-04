library(collapse)
library(ggplot2)

# load data ----
df_fore <- read.csv("C:/Users/Hauber-P/Documents/dev/Nowcasts/2025Q4/output_csv/forecasts.csv")
df_fore$vintage <- readr::parse_date(df_fore$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))
df_fore$period <- readr::parse_date(df_fore$period, format = "%d-%b-%Y", locale = readr::locale("en"))

df_news <- read.csv("C:/Users/Hauber-P/Documents/dev/Nowcasts/2025Q4/output_csv/news.csv")
df_news$vintage <- readr::parse_date(df_news$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))

# plot evolution of nowcasts ----

flt_period <- "2025-12-01"
flt_variable <- "gross domestic product"

df_plt <- df_fore |> 
  fsubset(period == flt_period  & variable == flt_variable )
df_ew_pool <- df_plt |> 
  fgroup_by(vintage) |> 
  fsummarise(ew_pool = mean(value))

df_plt |> ggplot()+
  geom_point(aes(x = vintage, y = value), size = 0.9, alpha = 0.5)+
  geom_line(
    mapping = aes(x = vintage, y = ew_pool), 
    data = df_ew_pool,
    linewidth = 1.1
  )+
  geom_label(
    mapping = aes(x = vintage, y = ew_pool, label = round(ew_pool, 2)), 
    data = df_ew_pool, 
    size = 3
  )+
  scale_x_date(breaks = unique(df_plt$vintage), date_labels = "%b %d")+ 
  labs(
    title = paste0("Nowcast ", lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) /3), ": ", flt_variable),
    x = "", y = "%"
  )

# plot news decomposition ----

df_plt <- df_news |> 
  fsubset(target == flt_variable & period == paste0(lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) / 3))) |>
  fselect(model, vintage, group, impact) |>
  fgroup_by(vintage, group, model) |>
  fsummarise(sum_model = sum(impact)) |>
  fgroup_by(vintage, group) |>
  fsummarise(impact_ew_pool = mean(sum_model))

df_plt |> 
  ggplot(aes(x = vintage, y = impact_ew_pool, group = group, fill = group))+
  geom_bar(position = "stack", stat="identity")+
  scale_x_date(breaks = unique(df_plt$vintage), date_labels = "%b %d")+ 
  labs(
    title = paste0("News decomposition ", lubridate::year(flt_period), "Q", ceiling(lubridate::month(flt_period) /3), ": ", flt_variable),
    x = "", y = "percentage points"
  )

# TO-DO ----

# wo ist der ifo? 

# encoding issue mit Straßenbau noch da. Gesamte pipeline nochmal laufen lassen und sehen, ob es dann noch da ist!

# Abbildung forecast evolution und news in eine packen (mit gemeinsamer x-Achse?!)


