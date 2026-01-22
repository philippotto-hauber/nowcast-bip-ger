@echo off
ECHO "Set year and quarter of nowcast (also produces forecast for the next quarter)!"
SET /p YEAR="Year: "
SET /p QUARTER="Quarter: "

SET DIR_REPO=%CD%
SET DIR_ROOT="C:\Users\Hauber-P\Documents\dev"
SET DIR_REALTIMEDATA=%DIR_ROOT%\Echtzeitdatensatz

SET /A switch_download_data = 0
IF %switch_download_data%==1 (
    ECHO Downloading data...    
    Rscript --no-save --no-restore "./src/real time data/R/download_bbk_rtd.R" "%DIR_REALTIMEDATA%/raw data"
    Rscript --no-save --no-restore "./src/real time data/R/download_bbk_financial_data.R" "%DIR_REALTIMEDATA%/raw data"
    Rscript --no-save --no-restore "./src/real time data/R/download_esi.R" "%DIR_REALTIMEDATA%/raw data"    
    Rscript --no-save --no-restore "./src/real time data/R/download_ifo.R" "%DIR_REALTIMEDATA%/raw data"
    Rscript --no-save --no-restore "./src/real time data/R/compile_rtd_lkw_maut_index.R" "%DIR_REALTIMEDATA%\raw data" "%DIR_REPO%"
    Rscript --no-save --no-restore "./src/real time data/R/compile_rtd_gastgewerbe.R" "%DIR_REALTIMEDATA%\raw data" "%DIR_REPO%"
    Rscript --no-save --no-restore "./src/real time data/R/postprocess_Bbk_vintages.R" "%DIR_REALTIMEDATA%/raw data"
) ELSE (
    ECHO "Switch set to 0. Do not download data"
)

SET /A switch_construct_vintages = 1
IF %switch_construct_vintages%==1 (
    ECHO Constructing real-time vintages...     
    matlab -noFigureWindows -batch "addpath('./src/real time data/Matlab'); construct_realtime_vintages('%DIR_REALTIMEDATA%', '%DIR_REPO%').m" 
    Rscript --no-save --no-restore "./src/real time data/R/convert_mat_vintages_to_csv.R" "%DIR_REALTIMEDATA%/vintages"   
) ELSE (
    ECHO "Switch set to 0. Do not construct vintages"
)

SET /A switch_compute_nowcasts = 1
SET /A switch_estimate_models = 0
IF %switch_compute_nowcasts%==1 (
    ECHO Computing nowcasts...
    matlab -noFigureWindows -batch "addpath('./src/model/Matlab'); addpath('./src/model/Matlab/functions');compute_nowcasts('%DIR_ROOT%', '%YEAR%', '%QUARTER%', '%switch_estimate_models%').m"
    Rscript --no-save --no-restore "./src/model/R/combine_csv_files.R" "%DIR_ROOT%" "%YEAR%" "%QUARTER%"
    Rscript --no-save --no-restore "./src/model/R/calculate_bottom_up_forecast.R" "%DIR_ROOT%" "%YEAR%" "%QUARTER%"
    Rscript --no-save --no-restore "./src/model/R/gen_plts.R" "%DIR_ROOT%" "%YEAR%" "%QUARTER%"
    Rscript --no-save --no-restore "./src/model/R/gen_table_news_decomp.R" "%DIR_ROOT%" "%YEAR%" "%QUARTER%"
) ELSE (
    ECHO "Switch set to 0. Do not compute nowcasts"
)
CMD /k
