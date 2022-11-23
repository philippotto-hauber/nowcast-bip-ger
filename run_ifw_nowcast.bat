@echo off
ECHO Set year and quarter of nowcast (also produces forecast for the next quarter)!
set /p YEAR="Year: "
set /p QUARTER="Quarter: "


set DIR_ROOT=C:/Users/Philipp/Desktop
set DIR_REALTIMEDATA=%DIR_ROOT%/Echtzeitdatensatz


set /A switch_download_data = 1
IF %switch_download_data%==1 (
    ECHO Downloading data...
    cd "real time data\R\"
    Rscript --vanilla download_bbk_rtd.R "%DIR_REALTIMEDATA%/raw data"
    Rscript --vanilla download_bbk_financial_data.R "%DIR_REALTIMEDATA%/raw data"
    Rscript --vanilla download_esi.R "%DIR_REALTIMEDATA%/raw data"
    Rscript --vanilla compile_rtd_gastgewerbe.R "%DIR_REALTIMEDATA%/raw data"
    Rscript --vanilla compile_rtd_lkw_maut_index.R "%DIR_REALTIMEDATA%/raw data"
) ELSE (
    ECHO "Switch set to 0. Do not download data"
)

set /A switch_construct_vintages = 0
IF %switch_construct_vintages%==1 (
    ECHO Constructing real-time vintages...    
    cd ..\Matlab
    matlab -noFigureWindows -batch "construct_realtime_vintages('%DIR_REALTIMEDATA%').m"
) ELSE (
    ECHO "Switch set to 0. Do not construct vintages"
)

set /A switch_estimate_models = 0
IF %switch_estimate_models%==1 (
    ECHO Estimating models...
    cd ..\..\model\
    matlab -noFigureWindows -batch "compute_nowcasts('%DIR_ROOT%', '%YEAR%', '%QUARTER%').m"
    cd ..
    cmd /k
) ELSE (
    ECHO "Switch set to 0. Do not estimate models"
)
