function out = plot_monthlyGDP(dir_root, year_nowcast, quarter_nowcast)    
    dir_monthly_gdp = [dir_root '\Nowcasts\' year_nowcast 'Q' quarter_nowcast, '\monthlyGDP'] ;
    
    % model specifications
    Nrs = readmatrix('../../model_specs_Nrs.csv'); % # number of factors
    Nps = readmatrix('../../model_specs_Nps.csv'); % # of lags in factor VAR
    Njs = readmatrix('../../model_specs_Njs.csv'); % # of lags in idiosysncratic component
    
    % specs
    specs = {};
    for Nr = Nrs
        for Np = Nps
            for Nj = Njs
                specs = [specs, ['Nr', num2str(Nr), '_Np', num2str(Np), '_Nj', num2str(Nj)]];
            end
        end
    end
    
    % vintages
    vintages = importdata('../../dates_vintages.txt');
    vintage = vintages{end};  
    
    % get data
    gdp_m_cumul = [];
    for s = 1:length(specs)
        load([dir_monthly_gdp '\' vintage '\monthlyGDP_' specs{s} '.mat']) 
        gdp_mms(:,s) = gdp_mm'; 
        gdp_3m3ms(:,s) = (std_gdp * gdp_3m3m + mean_gdp)'; 
    end
    
    % plot m/m
    
    gdp_mm_avg = mean(gdp_mms, 2); 
    figure(1)
    subplot(2,1,1)
    plot(gdp_mm_avg, 'b-')
    xticks(13:24:size(gdp_mm_avg, 1))
    xticklabels(dates_converted(13:24:end))
    title('GDP m/m, corresponding to standardized q/q growth rate, mean over all specifications')
    
    
    ind_last12m = length(gdp_mm_avg)-11:length(gdp_mm_avg);
    
    subplot(2,1,2)
    bar(gdp_mm_avg(ind_last12m,:))
    xticklabels(dates_converted(ind_last12m))
    xtickangle(30)
    title('GDP m/m last 12 months, corresponding to standardized q/q growth rate, mean over all specifications')
    
    fig=gcf;                                    
    fig.PaperOrientation='landscape';
    print([dir_monthly_gdp '\Monats_BIP_mm'],'-dpdf','-fillpage')

    % plot 3m/3m
    gdp_3m3m_avg = mean(gdp_3m3ms, 2); 
    figure(2)
    subplot(2,1,1)
    plot(gdp_3m3m_avg, 'b-')
    hold on
    plot(gdp_realizations, 'bo')
    xticks(13:24:size(gdp_3m3m_avg, 1))
    xticklabels(dates_converted(13:24:end))
    title('GDP monthly q/q, mean over all specifications')
    
    subplot(2,1,2)
    gdp_3m3m_avg_short = gdp_3m3m_avg(ind_last12m,:);
    dates_short = dates_converted(ind_last12m);
    ind_eoq = contains(dates_short, '-3') | contains(dates_short, '-6') | contains(dates_short, '-9') | contains(dates_short, '-12');
    tmp = [gdp_3m3m_avg_short, gdp_3m3m_avg_short];
    tmp(ind_eoq, 1) = NaN;
    tmp(~ind_eoq, 2) = NaN;
    bar(tmp, 'stacked')
    xticklabels(dates_short)
    xtickangle(30)
    title('GDP monthly q/q last 12 months')
    
    fig=gcf;                                    
    fig.PaperOrientation='landscape';
    print([dir_monthly_gdp '\Monats_BIP_qq'],'-dpdf','-fillpage')

    disp('Done plotting monthly GDP')
    out = [];
end
