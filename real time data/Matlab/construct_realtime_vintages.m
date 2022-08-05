function out = construct_realtime_vintages(dir_realtimedata)
    dir_rawdata = [dir_realtimedata, '/raw data'];
    dir_vintages = [dir_realtimedata, '/vintages'];
    vintages = importdata('../../dates_vintages.txt');
    for v = 1 : length(vintages)
        dataset.data_ifo = f_load_ifo(vintages{v}, dir_rawdata) ;
        %toc
        dataset.data_ESIBCI = f_load_ESIBCI(vintages{v}, dir_rawdata) ;
        %toc
        dataset.data_BuBaRTD = f_load_BuBaRTD(vintages{v}, dir_rawdata) ;
        % toc
        dataset.data_BuBaRTD = f_load_turnover_hospitality(dataset.data_BuBaRTD, vintages{v}, dir_rawdata);
        % toc
        dataset.data_BuBaRTD = f_load_lkw_maut_index(dataset.data_BuBaRTD, vintages{v}, dir_rawdata);
        %toc
        dataset.data_financial = f_load_financial(vintages{v}, dir_rawdata) ;
        %toc
        dataset.vintagedate = vintages{v} ; 
        % save dataset to mat
        save([ dir_vintages, '/dataset_', num2str(year(vintages{v})), '_' num2str(month(vintages{v})), '_', num2str(day(vintages{v})), '.mat'],'dataset');

        clear dataset
    end

    disp('Done constructing real-time vintages!')
    out = [];
end

    