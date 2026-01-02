@echo off
ECHO "Set year and quarter of nowcast (also produces forecast for the next quarter)!"
SET /p YEAR="Year: "
SET /p QUARTER="Quarter: "

SET DIR_REPO=%CD%
SET DIR_ROOT="C:\Users\Hauber-P\Documents\dev"
SET DIR_REALTIMEDATA=%DIR_ROOT%\Echtzeitdatensatz

SET /A switch_download_data = 0
CD "src\real time data\R\"
IF %switch_download_data%==1 (
    ECHO Downloading data...    
    Rscript --vanilla download_bbk_rtd.R "%DIR_REALTIMEDATA%/raw data"
    Rscript --vanilla download_bbk_financial_data.R "%DIR_REALTIMEDATA%/raw data"
    Rscript --vanilla download_esi.R "%DIR_REALTIMEDATA%/raw data"    
    Rscript --vanilla download_ifo.R "%DIR_REALTIMEDATA%/raw data"
    Rscript --vanilla compile_rtd_lkw_maut_index.R "%DIR_REALTIMEDATA%\raw data" "%DIR_REPO%"
    Rscript --vanilla compile_rtd_gastgewerbe.R "%DIR_REALTIMEDATA%\raw data" "%DIR_REPO%"
    Rscript --vanilla postprocess_Bbk_vintages.R "%DIR_REALTIMEDATA%/raw data"
) ELSE (
    ECHO "Switch set to 0. Do not download data"
)

SET /A switch_construct_vintages = 1
CD "..\Matlab"
IF %switch_construct_vintages%==1 (
    ECHO Constructing real-time vintages...     
    Rem matlab -noFigureWindows -batch "construct_realtime_vintages('%DIR_REALTIMEDATA%', '%DIR_REPO%').m" 
    CD "..\R"
    Rscript --vanilla convert_mat_vintages_to_csv.R "%DIR_REALTIMEDATA%/vintages"   
) ELSE (
    ECHO "Switch set to 0. Do not construct vintages"
)

CD "..\..\model\Matlab"
SET /A switch_compute_nowcasts = 0
SET /A switch_estimate_models = 0
IF %switch_compute_nowcasts%==1 (
    ECHO Computing nowcasts...
    matlab -noFigureWindows -batch "compute_nowcasts('%DIR_ROOT%', '%YEAR%', '%QUARTER%', '%switch_estimate_models%').m"
    matlab -noFigureWindows -batch "plot_nowcast_evolution('%DIR_ROOT%', '%YEAR%', '%QUARTER%').m"
    matlab -noFigureWindows -batch "print_news_docu('%DIR_ROOT%', '%YEAR%', '%QUARTER%').m"
    CD "..\R"
    Rscript --vanilla combine_csv_files.R "%DIR_ROOT%" "%YEAR%" "%QUARTER%"
) ELSE (
    ECHO "Switch set to 0. Do not compute nowcasts"
)

CD ../../..
CMD /k
