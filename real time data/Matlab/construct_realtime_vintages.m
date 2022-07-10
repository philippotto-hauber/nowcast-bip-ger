function out = construct_realtime_vintages(dir_root)
    dir_rawdata = [dir_root, '/raw data'];
    dir_vintages = [dir_root, '/vintages'];
    vintages = importdata('../../dates_vintages.txt');
%     vintages = {
%         '30-Jan-2022', '15-Feb-2022',...
%         '28-Feb-2022', '15-Mar-2022',...
%         '30-Mar-2022', '15-Apr-2022',...
%         '30-Apr-2022', '15-May-2022',...
%         '30-May-2022', '15-Jun-2022',...
%         '30-Jun-2022'}; 

    for v = 1 : length(vintages)
        %dataset.data_ifo = f_load_ifo(vintages{v}) ;
        %toc
        dataset.data_ESIBCI = f_load_ESIBCI(vintages{v}, dir_rawdata) ;
        %toc
        %dataset.data_BuBaRTD = f_load_BuBaRTD(vintages{v}, dir_rawdata) ;
        % toc
        %dataset.data_BuBaRTD = f_load_turnover_hospitality(dataset.data_BuBaRTD, vintages{v}, dir_rawdata);
        % toc
        %dataset.data_BuBaRTD = f_load_lkw_maut_index(dataset.data_BuBaRTD, vintages{v}, dir_rawdata);
        %toc
        %dataset.data_financial = f_load_financial(vintages{v}, dir_rawdata) ;
        %toc
        dataset.vintagedate = vintages{v} ; 
        % save dataset to mat
        %save([ dir_vintages, '/dataset_', num2str(year(vintages{v})), '_' num2str(month(vintages{v})), '_', num2str(day(vintages{v})), '.mat'],'dataset');

        clear dataset
    end

    disp('Done constructing real-time vintages!')
    out = [];
end

    