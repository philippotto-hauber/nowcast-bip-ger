plt_forecastrange <- function(df_fore, vintages, str_title, include_bottomup){
  if (include_bottomup){
    df_fore$variable[df_fore$variable == "gross domestic product"] <- "top-down"
    df_fore$variable[df_fore$variable == "gross domestic product (bottom up)"] <- "bottom-up"
    
    df_plt <- df_fore |> 
      fgroup_by(vintage, variable) |> 
      fsummarise(fore_min = min(value), fore_max = max(value), fore_mean = mean(value))
    
    p <- df_plt |> 
      ggplot(aes(x = vintage))+
      geom_ribbon(aes(ymin = fore_min, ymax = fore_max, group = variable, fill = variable), alpha = 0.3) +
      geom_line(aes(y = fore_mean, group = variable, color = variable), linewidth = 1.2, linetype = "dashed")+
      scale_x_date(breaks = vintages, date_labels = "%b %d", limits = c(min(vintages) - lubridate::days(7), max(vintages) + lubridate::days(7)))+ 
      scale_y_continuous(labels = function(x) format(x, nsmall = 2))+
      scale_fill_manual(values = c("#EFAC00", "#9C55E3"), name = NULL)+
      scale_color_manual(values = c("#EFAC00", "#9C55E3"), name = NULL)+
      labs(
        title = str_title,
        subtitle = "Range of forecasts",
        caption = "Dashed line=average forecast.",
        x = "", y = "%"
      )+
      theme_minimal()+
      theme(
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.text=element_text(size=6)
      )
  } else {
  df_plt <- df_fore |> 
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
  }
  return(p)
}