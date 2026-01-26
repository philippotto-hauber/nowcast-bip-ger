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

source(here::here("src", "model", "R", "reverse_trafos.R"))

# load data and forecasts ----
df_historic <- read.csv(paste0(dir_root, "/Echtzeitdatensatz/vintages/vintages.csv"))
df_historic$vintage <- readr::parse_date(df_historic$vintage)
df_historic$period <- readr::parse_date(df_historic$period)

df_historic <- df_historic |>
  fmutate(bothNA = is.na(raw) & is.na(value)) |>
  fsubset(!bothNA) |> 
  fselect(-bothNA)

# load forecasts
df_fore <- read.csv(paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/output_csv/forecasts.csv"))
df_fore$vintage <- readr::parse_date(df_fore$vintage, locale = readr::locale("en"))
df_fore$period <- readr::parse_date(df_fore$period,  locale = readr::locale("en"))

df_fore <- fsubset(df_fore, !grepl("bottom up", variable))

df_fore_natacc <- df_fore |> 
  fsubset(group == "national accounts") |>
  fmutate(month = lubridate::month(period)) |> 
  fsubset(month %in% c(3, 6, 9, 12)) |> 
  fselect(-month)

# calculate forecast of level of nominal GDP components ----
models <- unique(df_fore_natacc$model)
vintages <- unique(df_fore_natacc$vintage)

df_preds <- data.frame()
for (var in unique(df_fore_natacc$variable)[grepl("(nominal)", unique(df_fore_natacc$variable))]){
  for (v in vintages){
    v <- as.Date(v) # don't know why this is necessary! 
    tmp_historic <- fsubset(
      df_historic, 
      variable == var & vintage == v
    ) |> 
      fmutate(raw = round(raw, 1))
    
    for (m in models){
      # add last historic value so that we can get weights for first forecast! 
      df_preds <- rbind(
        df_preds, 
        data.frame(
          vintage = v, 
          period = max(tmp_historic$period),
          model = m, 
          variable = var, 
          pred_orig = tmp_historic$raw[tmp_historic$period == max(tmp_historic$period)]
        )
      )
      
      tmp_fore <- fsubset(
        df_fore_natacc, 
        variable == var & vintage == v & model == m
      )
      

      df_preds <- rbind(
        df_preds, 
        data.frame(
          vintage = v,
          period = tmp_fore$period,
          model = m, 
          variable = var,
          pred_orig = reverse_trafo(
            start_value = tmp_historic$raw[tmp_historic$period == max(tmp_historic$period)], 
            trafo = tmp_historic$trafo[1],
            values = tmp_fore$value
          )
        )
      )
    }
  }
}

# calculate nominal share of gdp ----
df_gdp <- fsubset(df_preds, variable == "gross domestic product (nominal)")|>
  frename(pred_orig = nominal_gdp) |>
  fselect(-variable)

df_shares <- fsubset(
  df_preds, 
  variable != "gross domestic product (nominal)"
) |> collapse::join(
  df_gdp, 
  on = c("vintage", "model", "period"),
  how = "left"
) |> 
  fmutate(share_gdp = pred_orig / nominal_gdp) |>
  fselect(
    vintage, period, model, variable, share_gdp
) 

# calculate contributions to growth ---- 
df_shares$variable <- gsub(" \\(nominal\\)", "", df_shares$variable)
df_shares$period <- df_shares$period + base::months(3) # shift period forward by one quarter so that weights match growth rate! 

df_contrib <- collapse::join(
  fsubset(df_fore_natacc, variable %in% unique(df_shares$variable)), df_shares,
  on = c("vintage", "period", "model", "variable"),
  how = "left"
) |> 
  fmutate(contrib = value * share_gdp) |>
  fselect(vintage, period, model, variable, contrib)

# calculate bottom-up forecast ----
df_contrib$contrib[df_contrib$variable == "imports"] <- df_contrib$contrib[df_contrib$variable == "imports"] * (-1) # flip sign of imports contribution so that I can simply add them up to get GDP 

df_bottomup <- rbind(
  df_contrib,
  df_fore_natacc |> 
    fsubset(variable == "inventories (contr. to growth)") |>
    fselect(vintage, period, model, variable, contrib = value)
) |>
  fgroup_by(
    c("vintage", "model", "period")
) |>
  fsummarise(
    gdp_bottomup = sum(contrib)
)

# export ----  
df_bottomup |> 
  fmutate(variable = "gross domestic product (bottom up)") |>
  fmutate(group = "national accounts") |>
  fselect(vintage, period, model, value = gdp_bottomup, variable, group) |> 
  rbind(df_fore) |>
  write.csv(paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/output_csv/forecasts.csv"), row.names = FALSE)