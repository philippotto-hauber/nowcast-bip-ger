plt_nowcast_and_news <- function(df_fore, df_news, vintages, str_title, ew_pool = FALSE, include_bottomup = FALSE){
  # nowcasts 
  if (include_bottomup){
    df_fore$variable[df_fore$variable == "gross domestic product"] <- "top-down"
    df_fore$variable[df_fore$variable == "gross domestic product (bottom up)"] <- "bottom-up"
    
    df_ew_pool <- df_fore |> 
      fgroup_by(vintage, variable) |> 
      fsummarise(ew_pool = mean(value))
    
    plt_fore <- df_fore |> 
      fsubset(vintage %in% vintages) |> 
      ggplot(aes(x = vintage, group = variable, color = variable))+
      geom_point(aes(, y = value), size = 0.9, alpha = 0.5)+
      geom_line(
        mapping = aes(y = ew_pool, linetype = variable), 
        data = df_ew_pool |> fsubset(vintage %in% vintages),
        linewidth = 1.1
      )+
      geom_label(
        mapping = aes(y = ew_pool, label = sprintf("%.2f", ew_pool), vjust = variable), 
        data = df_ew_pool |> fsubset(vintage %in% vintages), 
        size = 3,
        show.legend = FALSE
      )+
      guides(point = "none", label = "none", linetype = "none")+
      scale_x_date(breaks = vintages, date_labels = "%b %d", limits = c(min(vintages) - lubridate::days(7), max(vintages) + lubridate::days(7)))+ 
      scale_y_continuous(labels = function(x) format(x, nsmall = 2))+
      scale_color_manual(values = c("top-down" = "#1B1B1B", "bottom-up" = "#007A7C"), name = NULL)+
      scale_linetype_manual(values = c("top-down" = "solid", "bottom-up" = "dashed"))+
      geomtextpath::scale_vjust_manual(values = c("top-down" = -0.5, "bottom-up" = 1.5))+
      labs(
        title = str_title,
        subtitle = "Nowcasts",
        caption = if(ew_pool) "Dots represent forecasts of different model specifications, the line and labels indicate the equally-weighted pool." else NULL,
        x = "forecast date", y = "%"
      )+
      theme_minimal()+
      theme(
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.text=element_text(size=6),
        plot.caption=element_text(size = 6),
        axis.text.x = element_text(angle = 60, vjust = 0.5)
      )+
      coord_cartesian(clip = "off")
  } else {
    df_ew_pool <- df_fore |> 
      fgroup_by(vintage) |> 
      fsummarise(ew_pool = round(mean(value), 2))
    
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
      scale_y_continuous(labels = function(x) format(x, nsmall = 2))+
      labs(
        title = str_title,
        subtitle = "Nowcasts",
        caption = if(ew_pool) "Dots represent forecasts of different model specifications, the line and labels indicate the equally-weighted pool." else NULL,
        x = "forecast date", y = "%"
      )+
      theme_minimal()+
      theme(
        plot.caption=element_text(size = 6)
      )
  }
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
  if (include_bottomup){
    df_ew_pool <- fsubset(df_ew_pool, variable == "top-down") # no news decomp for bottom-up forecasts! 
  }

  df_rev <- df_plt_news |> fgroup_by(vintage) |> fsummarise(sum_impact = sum(impact_ew_pool))
  df_rev$delta <- diff(df_ew_pool$ew_pool)
  df_rev$revision <- df_rev$delta - df_rev$sum_impact
  df_plt_news <- rbind(
    df_plt_news, 
    data.frame(
      vintage = df_rev$vintage, 
      group = "revisions", 
      impact_ew_pool = df_rev$revision
    )
  )
  
  if(ew_pool & include_bottomup) {
    str_caption = "Average impacts across different model specifications. News decomposition refers to the top-down forecast."
  }  else if (ew_pool){
    str_caption = "Average impacts across different model specifications."
  } else {
    str_caption = NULL
  }

  plt_news <- df_plt_news |> 
    ggplot(aes(x = vintage, y = impact_ew_pool, group = group, fill = group))+
    geom_bar(position = "stack", stat="identity", width = 6)+
    scale_x_date(breaks = vintages, date_labels = "%b %d", limits = c(min(vintages) - lubridate::days(7), max(vintages) + lubridate::days(7)))+ 
    scale_y_continuous(labels = function(x) format(x, nsmall = 2))+
    labs(
      subtitle = "News decomposition", 
      caption = str_caption,
      x = "forecast date", y = "ppts"
    )+
    theme_minimal()+
    theme(
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text=element_text(size=6),
      plot.caption=element_text(size = 6),
      legend.key.size = unit(0.3, "cm"),
      axis.text.x = element_text(angle = 60, vjust = 0.5)
    )+
    scale_fill_manual(values = npg_modified)
  
  # combined plots
  plt <- ggpubr::ggarrange(plt_fore, plt_news, ncol = 1, nrow = 2, heights = c(1, 1))
  return(plt)
}