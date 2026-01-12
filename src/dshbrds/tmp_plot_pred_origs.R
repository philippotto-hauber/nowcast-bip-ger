dir_root <- "C:/Users/Hauber-P/Documents/dev"
nowcast_year <- 2025
nowcast_quarter <- 4

library(collapse)
library(ggplot2)

# load data
df_historic <- read.csv(paste0(dir_root, "/Echtzeitdatensatz/vintages/vintages.csv"))
df_historic$vintage <- readr::parse_date(df_historic$vintage)
df_historic$period <- readr::parse_date(df_historic$period)

df_historic <- df_historic |>
  fmutate(bothNA = is.na(raw) & is.na(value)) |>
  fsubset(!bothNA) |> 
  fselect(-bothNA)

# load forecasts
df_fore <- read.csv(paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/output_csv/forecasts.csv"))
df_fore$vintage <- readr::parse_date(df_fore$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))
df_fore$period <- readr::parse_date(df_fore$period, format = "%d-%b-%Y", locale = readr::locale("en"))

models <- unique(df_fore$model)
vintages <- unique(df_fore$vintage)

df_preds <- data.frame()
flt_variable <- "Wohnungsbau"
flt_group <- "orders"
tmp_historic <- fsubset(
  df_historic, 
  variable == flt_variable & group == flt_group & vintage == max(vintages)
)

tmp_historic$raw <- round(tmp_historic$raw, 1)

for (m in models){
  # add last historic value so that line plots look nicer! 
  df_preds <- rbind(
    df_preds, 
    data.frame(
      model = m, 
      period = max(tmp_historic$period), 
      pred_orig = tmp_historic$raw[tmp_historic$period == max(tmp_historic$period)]
    )
  )
  
  tmp_fore <- fsubset(
    df_fore, 
    variable == flt_variable & group == flt_group & vintage == max(vintages) & model == m
  )
  
  if (flt_group == "national accounts"){
    tmp_fore$month = lubridate::month(tmp_fore$period)
    tmp_fore <- tmp_fore |> 
      fmutate(month = lubridate::month(period)) |> 
      fsubset(month %in% c(3, 6, 9, 12)) |> 
      fselect(-month)
  }
  
  df_preds <- rbind(
    df_preds, 
    data.frame(
      model = m, 
      period = tmp_fore$period,
      pred_orig = reverse_trafo(
        start_value = tmp_historic$raw[tmp_historic$period == max(tmp_historic$period)], 
        trafo = tmp_historic$trafo[1],
        values = tmp_fore$value
      ) 
    )
  )
}

df_preds$pred_orig <- round(df_preds$pred_orig, 1)

p <- ggplot()+
  geom_line(
    mapping = aes(x = period, y = raw), 
    data = fsubset(tmp_historic, period >= "2025-01-01"),
    color = "black"
  )+
  geom_point(
    mapping = aes(x = period, y = raw), 
    data = fsubset(tmp_historic, period >= "2025-01-01"),
    color = "black", size = 2.5
  )+
  geom_line(
    mapping = aes(x = period, y = pred_orig, group = model),
    data = df_preds,
    color = "darkorange",
    linetype = "dotted"
  )+
  geom_line(
    mapping = aes(x = period, y = ew_pool),
    data = df_preds |> 
      fgroup_by(period) |>
      fsummarise(ew_pool = round(mean(pred_orig), 1)),
    color = "darkorange3",
    linetype = "dashed", linewidth = 1.2
  )+
  geom_point(
    mapping = aes(x = period, y = ew_pool),
    data = df_preds |> 
      fgroup_by(period) |>
      fsummarise(ew_pool = round(mean(pred_orig), 1)) |> 
      fsubset(period > min(period)), # gets rid of the last historic observation which is only needed so that the line plots look nice
    color = "darkorange3", size = 2.5
  )+
  scale_x_date(date_labels = "%b %y")+ 
  scale_y_continuous(labels = function(x) format(x, nsmall = 1))+
  labs(title = paste0(flt_variable, " (", flt_group, ")"), x = "Date", y = "Index")+
  theme_minimal()


plotly::ggplotly(p)

