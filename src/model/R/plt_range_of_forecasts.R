plt_forecastrange <- function(df_fore, vintages, str_title){
  df_plt <- df_fore |> 
    fsubset(variable == flt_variable & period == flt_period) |>
    fgroup_by(vintage) |> 
    fsummarise(fore_min = min(value), fore_max = max(value), fore_mean = mean(value))
  
  p <- df_plt |> 
    ggplot(aes(x = vintage))+
    geom_ribbon(aes(ymin = fore_min, ymax = fore_max), fill = "grey70") +
    geom_line(aes(y = fore_mean), linewidth = 1.2, linetype = "dashed")+
    scale_x_date(breaks = vintages, date_labels = "%b %d", limits = c(min(vintages) - lubridate::days(7), max(vintages) + lubridate::days(7)))+ 
    scale_y_continuous(labels = function(x) format(x, nsmall = 2))+
    labs(
      title = str_title,
      subtitle = "Range of forecasts",
      caption = "Dashed line=average forecast.",
      x = "", y = "%"
    )+
    theme_minimal()
  return(p)
}