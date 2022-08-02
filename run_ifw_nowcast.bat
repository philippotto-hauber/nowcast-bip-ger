@echo off

set DIR_ROOT=C:/Users/Philipp/Desktop
set DIR_REALTIMEDATA=%DIR_ROOT%/Echtzeitdatensatz
ECHO %DIR_REALTIMEDATA%
ECHO Downloading data...
cd "real time data\R\"
Rem Rscript --vanilla download_bbk_rtd.R "%DIR_REALTIMEDATA%/raw data"
Rem Rscript --vanilla download_bbk_financial_data.R "%DIR_REALTIMEDATA%/raw data"
Rem Rscript --vanilla download_esi.R "%DIR_REALTIMEDATA%/raw data"
Rem Rscript --vanilla compile_rtd_gastgewerbe.R "%DIR_REALTIMEDATA%/raw data"
Rem Rscript --vanilla compile_rtd_lkw_maut_index.R "%DIR_REALTIMEDATA%/raw data"

ECHO Constructing real-time vintages...
cd ..\Matlab
matlab -noFigureWindows -batch "construct_realtime_vintages('%DIR_REALTIMEDATA%').m"

ECHO Estimating models...
cd ..\..\model\
matlab -noFigureWindows -batch "compute_nowcasts('%DIR_ROOT%').m"



cd ..\..
cmd /k