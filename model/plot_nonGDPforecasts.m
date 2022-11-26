function out = plot_nonGDPforecasts(dir_root, year_nowcast, quarter_nowcast) 
    dir_nongdp_forecasts = [dir_root '\Nowcasts\' year_nowcast 'Q' quarter_nowcast, '\non gdp forecasts\'] ;
    
    % models
    Nrs = readmatrix('../model_specs_Nrs.csv'); % # number of factors
    Nps = readmatrix('../model_specs_Nps.csv'); % # of lags in factor VAR
    Njs = readmatrix('../model_specs_Njs.csv'); % # of lags in idiosysncratic component
    
    Nmodels = length(Nrs) * length(Nps) * length(Njs);
    
    % vintage
    vintages = importdata('../dates_vintages.txt');
    vintage = vintages{end};  
    
    vars = {'ip', 'to_hosp', 'ord', 'lkwm'};
    str_titles = {'Industrieproduktion, m/m', 'Umsatz Gastgewerbe, m/m', 'Auftragseingänge, m/m', 'LKW-Fahrleistungsindex, m/m'};
    Nvars = length(vars);
    load([dir_nongdp_forecasts, 'dates.mat'])
    date_start = dates_converted{end-11};
    Nobs = length(dates_converted);
    
    %---------------------------------------%
    %- Plot 
    %---------------------------------------%
    
    
    ys = NaN(1, Nobs, Nvars);
    xis = NaN(Nmodels, Nobs, Nvars);
    
    fig = figure;
    fig.PaperOrientation = 'portrait';
    
    for i = 1:Nvars    
        for m = 1:Nmodels
            load([dir_nongdp_forecasts, vars{i}, '_fore_model_' num2str(m), '_v_', vintage, '.mat'])
            ys(1, :, i) = out.dat;
            xis(m, :, i) = out.xi; 
        end
        subplot(Nvars,1,i)
        plot_forecasts(squeeze(ys(1, :, i)), squeeze(xis(:, :, i)), dates_converted, date_start, str_titles{i})
    end
    
    print([dir_nongdp_forecasts 'forecasts', strjoin(vars, '_')],'-dpdf','-fillpage')

    disp('Done plotting non GDP forecasts')
    out = [];
end
function plot_forecasts(y, xi, dates, date_start, str_title)
    % y - M x T matrix of data with NaN (M = different model specs)
    % xi - M x T matrix of the common component or forecast
    % dates - cell vector of dates in format YYYY-(M)M, e.g. 2020-1 for January 2020
    % date_start - plot starts from here
    % str_title - title of plot
    med_xi = mean(xi, 1);
    upper_xi = prctile(xi, 95, 1);
    lower_xi = prctile(xi, 5, 1);
    
    n_start = find(strcmp(date_start, dates)); 
    n_obs = sum(~isnan(y(1,n_start:end))); % number of non-missing observations
    
    dates_plot = dates(n_start:end);
    
    plot(y(1,n_start:end), 'b-')
    hold on
    plot([y(1,n_start:n_start-1+n_obs), med_xi(1, n_start+n_obs:end)], 'b--')
    plot([y(1,n_start:n_start-1+n_obs), upper_xi(1, n_start+n_obs:end)], 'b:')
    plot([y(1,n_start:n_start-1+n_obs), lower_xi(1, n_start+n_obs:end)], 'b:')
    xticks(1:3:length(med_xi(1, n_start+1:end)));
    xticklabels(dates_plot(1:3:end))
    title(str_title)
end



