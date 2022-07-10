%clear; close all; clc
%dirname = 'C:\Users\Philipp\Desktop\Echtzeitdatensatz\vintages\' ;
if exist(dirname, 'dir') ~= 7;mkdir(dirname);end  
vintages = {
    '30-Jan-2022', '15-Feb-2022',...
    '28-Feb-2022', '15-Mar-2022',...
    '30-Mar-2022', '15-April-2022',...
    '30-Apr-2022', '15-May-2022',...
    '30-May-2022', '15-Jun-2022',...
    '30-Jun-2022'}; 

for v = 1 : length(vintages)
    %dataset.data_ifo = f_load_ifo(vintages{v}) ;
    %toc
    dataset.data_ESIBCI = f_load_ESIBCI(vintages{v}) ;
    %toc
    dataset.data_BuBaRTD = f_load_BuBaRTD(vintages{v}) ;
    % toc
    %dataset.data_BuBaRTD = f_load_turnover_hospitality(dataset.data_BuBaRTD, vintages{v});
    % toc
    %dataset.data_BuBaRTD = f_load_lkw_maut_index(dataset.data_BuBaRTD, vintages{v});
    %toc
    dataset.data_financial = f_load_financial(vintages{v}) ;
    %toc
    dataset.vintagedate = vintages{v} ; 
    % save dataset to mat
    save([ dirname 'dataset_' num2str(year(vintages{v})) '_' num2str(month(vintages{v})) '_' num2str(day(vintages{v}))],'dataset');

    clear dataset
end

disp('Done constructing real-time vintages!')

    