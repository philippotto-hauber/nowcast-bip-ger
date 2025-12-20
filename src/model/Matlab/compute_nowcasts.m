function out = compute_nowcasts(dir_root, year_nowcast, quarter_nowcast, switch_estimatemodels)

    % ----------------------------------------------------------------------- %
    % - This code computes the news decomposition for nowcasts of GDP 
    % - growth 
    % ----------------------------------------------------------------------- %
    % dir_root = 'G:/Geteilte Ablagen/02_Konjunktur/04_Prognose/9_Prognosemodelle/03_DFM';
    % year_nowcast = '2025';
    % quarter_nowcast = '2';
    % switch_estimatemodels = '1';
    dir_data = [dir_root '\Echtzeitdatensatz'];
    dir_nowcast = [dir_root '\Nowcasts\' year_nowcast 'Q' quarter_nowcast] ;
    if exist(dir_nowcast, 'dir') ~= 7;mkdir(dir_nowcast);end 
    
    addpath('functions')

    
    foldername = [dir_nowcast '\output_mat'] ;if exist(foldername, 'dir') ~= 7;mkdir(foldername);end  
    foldername = [dir_nowcast '\output_csv'] ;if exist(foldername, 'dir') ~= 7;mkdir(foldername);end  
    foldername = [dir_nowcast '\graphs'] ;if exist(foldername, 'dir') ~= 7;mkdir(foldername);end  
    foldername = [dir_nowcast '\params'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\docu'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\tables'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\monthlyGDP'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\non gdp forecasts'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end

    str_nowcast = [year_nowcast 'Q' quarter_nowcast]; 
    if strcmp(quarter_nowcast, '4')
        str_forecast = [ num2str(str2double(year_nowcast) + 1) 'Q1'] ; 
    else 
        str_forecast = [ year_nowcast 'Q' quarter_nowcast] ; 
    end

    % ----------------------------------------------------------------------- %
    % - user specified settings --------------------------------------------- %
    % ----------------------------------------------------------------------- %
    
    % vintages
    vintages = importdata('../../../dates_vintages.txt');
    vintage_estim = vintages{1};
        
    % check all vintages are available        
    flag_missing = checkvintages(vintages, dir_data) ;
    if any( flag_missing == 1 )
        disp('Missing vintages. Abort execution')
        return
    end
    
    % check vintage dates are increasing
    for v = 2:length(vintages)
		if datenum(vintages{v}) <= datenum(vintages{v-1})
            disp('Vintage dates are not increasing. Abort execution') 
            return
        end
    end

    % sample starts in ...
    samplestart = 1996 + 1/12 ; 
    
    % dates corresponding to now- and forecast
    date_nowcast = str2double(year_nowcast) + str2double(quarter_nowcast)*3/12 ; 
    if str2double(quarter_nowcast)*3 == 12
        date_forecast = str2double(year_nowcast)+1 + 3/12 ; 
    else
        date_forecast = str2double(year_nowcast) + (str2double(quarter_nowcast)*3+3)/12 ; 
    end
    

    % number of vintages => size(datasets.mat)
    Nvintages = length( vintages ) ;
    
    % model specifications
    Nrs = readmatrix('../../../model_specs_Nrs.csv'); % # number of factors
    Nps = readmatrix('../../../model_specs_Nps.csv'); % # of lags in factor VAR
    Njs = readmatrix('../../../model_specs_Njs.csv'); % # of lags in idiosysncratic component
    
    % switches
    switch_estimatemodels = str2double(switch_estimatemodels); % convert string input to numeric
    
    % list of vars to be removed from the data set 
    list_removevars = determine_vars_remove(dir_data, vintages, samplestart, samplestart:1/12:date_forecast);
    writecell(list_removevars.namegroup, [dir_nowcast, '\list_removed_vars.txt'])
    
    % monthly variables for which we store the forecasts based on the latest available vintages
    names_export = {'Industrie', 'Industrie', 'lkw_maut', 'ifo_lage', 'ifo_erwartung'};
    groups_export = {'production', 'orders', 'production', 'ifo', 'ifo'};
    mnemonic_export = {'ip', 'ord', 'lkwm', 'ifoLage', 'ifoErw'};
    names_news_decomp = {'gross domestic product', 'private consumption', 'private gross fixed capital formation', 'exports'};
    groups_news_decomp = {'national accounts', 'national accounts', 'national accounts', 'national accounts'};
    mnemonic_news_decomp = {'Y', 'C', 'I', 'X'};
    
    if length(names_export) ~= length(groups_export) || length(names_export) ~= length(mnemonic_export)
        error('names, groups and mnemonics vector for non-gdp forecasts must be of the same length!')
    end
    
    if length(names_news_decomp) ~= length(groups_news_decomp) || length(names_news_decomp) ~= length(mnemonic_news_decomp)
        error('names and groups vectors for news decomp must be of the same length!')
    end

    % ----------------------------------------------------------------------- %
    % - estimate models ----------------------------------------------------- %
    % ----------------------------------------------------------------------- %               
                   
    if switch_estimatemodels == 1 
        f_estimatemodels(samplestart,vintage_estim,Nrs,Nps,Njs,list_removevars,dir_nowcast, dir_data) ; 
    end
    
    % ----------------------------------------------------------------------- %
    % - news decomposition -------------------------------------------------- %
    % ----------------------------------------------------------------------- %
    
    % ----------------------------- %
    % - compute a few things ------ %  
    
    Nmodels = length(Nrs) * length(Nps) * length(Njs) ;
    modcounter = 1 ;
    
    
    % ------------------------------------------------------------ %
    % - construct dates and find indices of now- and forecast ---- %
    
    options.dates = samplestart:1/12:date_forecast ; 
    options.index_nowcast = abs(options.dates - date_nowcast)<1e-05 ; 
    options.index_forecast = abs(options.dates - date_forecast)<1e-05 ;
    
    % ----------------------------- %
    % - loop over models ---------- %  

    for Nr = Nrs
        for Np = Nps
            for Nj = Njs
                
                % ------------------------------------ %
                % - store Nr, Np and Nj in options --- %
                
                options.Nr = Nr ; 
                options.Np = Np ; 
                options.Nj = Nj ; 

                results.Nr{modcounter} = Nr;
                results.Np{modcounter} = Np;
                results.Nj{modcounter} = Nj;
                
                % ----------------- %
                % - load params --- %
                
                load([dir_nowcast '\params\params_Nr' num2str(Nr) '_Np' num2str(Np) '_Nj' num2str(Nj) '.mat']) ; 

                % ----------------------------------------------------------------------- %
                % - set up tables to store output for csv-export ------------------------- %
                % ----------------------------------------------------------------------- %

                chunk = 20000; 
                t_fore = table(...
                    NaT(chunk,1), ... 
                    NaT(chunk,1), ... 
                    strings(chunk,1), ...  
                    strings(chunk,1), ...    
                    strings(chunk,1), ...  
                    NaN(chunk, 1), ...
                    'VariableNames', {'vintage', 'period', 'model', 'variable', 'group', 'value'});
                k_fore = 0; 

                t_news = table(...
                    NaT(chunk,1), ... 
                    strings(chunk,1), ...   
                    strings(chunk,1), ...  
                    strings(chunk,1), ...  
                    strings(chunk,1), ...  
                        strings(chunk,1), ...  
                    NaN(chunk, 1), ...
                    NaN(chunk, 1), ...
                    NaN(chunk, 1), ...
                    NaN(chunk, 1), ...
                    'VariableNames', {'vintage', 'period', 'target', 'model', 'variable', 'group', 'forecast', 'actual', 'weight', 'impact'});
                k_news = 0; 
           
           
                % ----------------------------- %
                % - load/construct data set --- %
    
                [dataM, dataQ, options.means, options.stds, ~, options.names, options.groups, ~, results.vintages{1}] = f_constructdataset(dir_data, samplestart,vintages{ 1 },list_removevars,[],[]) ; 
                data = [[dataM; dataQ] NaN(size(dataM,1) + size(dataQ,1) , length(options.dates) - size(dataM,2))] ;
                
                % --------------------------------- %
                % - calculate some more options --- %
                
                [options.index_gdp, options.meangdp, options.stdgdp] = get_index_mean_std(options, 'gross domestic product');
                results.groupnames = unique(options.groups);
                options.groupnames = unique(options.groups);
                options.Nm = size(dataM,1) ;
                options.Nq = size(dataQ,1) ; 
                
                if options.Nj>0
                    options.Ns = 5*(options.Nr+options.Nq) + options.Nm ; 
                else
                    options.Ns = 5*(options.Nr+options.Nq) ;
                end
                
                [T, Z, R, Q, H] = f_statespaceparams_news(params,options) ;
              
                % ------------------------------------------ %
                % - compute first nowcast outside of loop -- %  
                
                s0 = zeros(size(T,1),1) ; 
                P0 = 10 * eye(size(T,1)) ; 
                ks_output_old = f_KalmanSmootherDK(data,T,Z,H,R,Q,s0,P0) ;

                for n = 1:length(names_news_decomp)
                    [i, m, std] = get_index_mean_std(options, names_news_decomp{n}) ;
                    results.nowcast.(mnemonic_news_decomp{n}).varname_long = names_news_decomp{n};
                    results.nowcast.(mnemonic_news_decomp{n}).new(1,1,modcounter) = std * ( Z(i,:) * ks_output_old.stT(:,options.index_nowcast) ) + m ; 
                    results.forecast.(mnemonic_news_decomp{n}).new(1,1,modcounter) = std * ( Z(i,:) * ks_output_old.stT(:,options.index_forecast) ) + m ;
                end

                % rename data as old
                data_old = data ; 
                clearvars dataM dataQ data ; 
			    
			    % ------------------------------------------------- %
                % - now loop over remaining vintages -------------- %  
                
                for v = 2 : Nvintages 
                %for v = Nvintages  
			    
                    disp(['Current model ' num2str( modcounter ) ' of ' num2str( Nmodels ) ] )
                    disp(['Current vintage ' num2str(v - 1 ) ' of ' num2str( Nvintages - 1 ) ] )
				    
                    % ------------------------------------------ %
                    % - load new data -------------------------- % 
                    
                    [dataM_new, dataQ_new, ~, ~, ~, names_temp, groups_temp, ~, results.vintages{v}] = f_constructdataset(dir_data, samplestart,vintages{ v },list_removevars,options.means,options.stds) ;
                    data_new = [[dataM_new;dataQ_new] NaN(size(dataM_new,1) + size(dataQ_new,1) , length(options.dates) - size(dataM_new,2))] ;
                    
                    % ----------------------------------- %
                    % - nowcast with new data ----------- %
                    ks_output_new = f_KalmanSmootherDK(data_new,T,Z,H,R,Q,s0,P0) ;
                    for n = 1:length(names_news_decomp)
                        [i, m, std] = get_index_mean_std(options, names_news_decomp{n}) ;
                        results.nowcast.(mnemonic_news_decomp{n}).new(1,v,modcounter) = std * ( Z(i,:) * ks_output_new.stT(:,options.index_nowcast) ) + m ; 
                        results.forecast.(mnemonic_news_decomp{n}).new(1,v,modcounter) = std * ( Z(i,:) * ks_output_new.stT(:,options.index_forecast) ) + m ;
                    end

                    % calculate monthly m/m and 3m/3m GDP change
                    gdp_mm = Z( options.index_gdp , 1:options.Nr+1 ) * ks_output_new.stT(1:options.Nr+1,:);
                    %gdp_3m3m = options.stdgdp * ( Z( options.index_gdp , : ) * ks_output_new.stT ) + options.meangdp ; 
                    gdp_3m3m = Z( options.index_gdp , : ) * ks_output_new.stT;
                    
                    % export with dates as mat file to folder
                    mean_gdp = options.meangdp;
                    std_gdp = options.stdgdp; 
                    foldername = [dir_nowcast '\monthlyGDP\' vintages{v}] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
                    dates_converted = f_convertdates(options.dates); 
                    gdp_realizations = options.stdgdp * data_new(options.index_gdp, :) + options.meangdp; 
                    results.monthly_gdp.gdp_mm{:, v, modcounter} = gdp_mm;
                    results.monthly_gdp.gdp_3m3m{:, v, modcounter} = gdp_3m3m;
                    results.monthly_gdp.dates{:, v} = dates_converted;
                    results.monthly_gdp.gdp_realizations{:, v} = gdp_realizations;
                    results.monhtly_gdp.mean_gdp{v, 1} = mean_gdp;
                    results.monhtly_gdp.std_gdp{v, 1} = std_gdp;   

                    % store forecasts for all variables    
                    [t_fore, k_fore] = write_forecasts_to_table(...
                        t_fore, k_fore, chunk, ...
                        data_new, Z, ks_output_new, ...
                        dates_converted, ...
                        vintages{v}, ...
                        ['Nr_' num2str(Nr) '_Np_' num2str(Np) '_Nj_' num2str(Nj)], ...
                        options.names, options.groups, options.means, options.stds);

                    % ----------------------------- %
                    % - index of new obs ---------- %                    
                                   
                    newobs = ~isnan(data_new) & isnan(data_old);
                    % check that we have no more than one new obs!
                    if any(sum(newobs,2) > 1 & sum(newobs, 2) < 12) % restrict comparision to past year as for some variables, e.g. hospitality, earlier values may sometimes become available  
                        disp('The following series have more than one new observations published at once. Remove from data set!')
                        groups_temp{sum(newobs,2)>1};
                        names_temp{sum(newobs,2)>1}
                    end
                               
                    % indices of new obs                
                    [js, tjs] = find(newobs == 1) ; 
                    
                    % ------------------------------- %
                    % - news decomposition ---------- %
                    

                    tks_nowcast = find(options.index_nowcast == 1) ;    
                    tks_forecast = find(options.index_forecast == 1) ;    
                    
                    % for n = 1 : length(names_news_decomp)
                    %     [i, ~, std] = get_index_mean_std(options, names_news_decomp{n}) ;
                    %     [results.nowcast.(mnemonic_news_decomp{n}).impact_by_group(:,v,modcounter), ...
                    %         results.nowcast.(mnemonic_news_decomp{n}).details(v,modcounter).impacts, ...
                    %         results.nowcast.(mnemonic_news_decomp{n}).details(v,modcounter).actuals, ...
                    %         results.nowcast.(mnemonic_news_decomp{n}).details(v,modcounter).forecasts, ...
                    %         results.nowcast.(mnemonic_news_decomp{n}).details(v,modcounter).weights, ...
                    %         results.nowcast.(mnemonic_news_decomp{n}).details(v,modcounter).varnames ] = f_newsdecomp(js,tjs,tks_nowcast,data_new,ks_output_old,params,options, i, std) ;
                    % end

                    for n = 1:length(names_news_decomp)

                        [i, ~, std] = get_index_mean_std(options, names_news_decomp{n});

                        % nowcasts
                        [tmp_impact_by_group, tmp_impacts, tmp_actuals, tmp_forecasts, tmp_weights, tmp_varnames, tmp_groupnames] = ...
                            f_newsdecomp(js,tjs,tks_nowcast,data_new,ks_output_old,params,options, i, std);

                        key = mnemonic_news_decomp{n};                        
                        results.nowcast.(key).impact_by_group(:, v, modcounter) = tmp_impact_by_group;
                        results.nowcast.(key).details(v, modcounter).impacts   = tmp_impacts;
                        results.nowcast.(key).details(v, modcounter).actuals   = tmp_actuals;
                        results.nowcast.(key).details(v, modcounter).forecasts = tmp_forecasts;
                        results.nowcast.(key).details(v, modcounter).weights   = tmp_weights;
                        results.nowcast.(key).details(v, modcounter).varnames  = strcat(tmp_varnames, ' (', tmp_groupnames, ')');
                        
                        [t_news, k_news] = write_news_to_table(...
                            t_news, k_news, chunk, ...
                            tmp_weights, tmp_actuals, tmp_forecasts, tmp_impacts, tmp_varnames, tmp_groupnames, ...
                            str_nowcast, ...
                            vintages{v}, ...
                             ['Nr_' num2str(Nr) '_Np_' num2str(Np) '_Nj_' num2str(Nj)], ...
                             names_news_decomp{n});

                        % forecasts
                        [tmp_impact_by_group, tmp_impacts, tmp_actuals, tmp_forecasts, tmp_weights, tmp_varnames, tmp_groupnames] = ...
                            f_newsdecomp(js,tjs,tks_forecast,data_new,ks_output_old,params,options, i, std);
                        
                        key = mnemonic_news_decomp{n};                        
                        results.forecast.(key).impact_by_group(:, v, modcounter) = tmp_impact_by_group;
                        results.forecast.(key).details(v, modcounter).impacts   = tmp_impacts;
                        results.forecast.(key).details(v, modcounter).actuals   = tmp_actuals;
                        results.forecast.(key).details(v, modcounter).forecasts = tmp_forecasts;
                        results.forecast.(key).details(v, modcounter).weights   = tmp_weights;
                        results.forecast.(key).details(v, modcounter).varnames  = strcat(tmp_varnames, ' (', tmp_groupnames, ')');

                        [t_news, k_news] = write_news_to_table(...
                            t_news, k_news, chunk, ...
                            tmp_weights, tmp_actuals, tmp_forecasts, tmp_impacts, tmp_varnames, tmp_groupnames, ...
                            str_forecast, ...
                            vintages{v}, ...
                             ['Nr_' num2str(Nr) '_Np_' num2str(Np) '_Nj_' num2str(Nj)], ...
                             names_news_decomp{n});
                    end

                    % for n = 1 : length(names_news_decomp)
                    %     [i, ~, std] = get_index_mean_std(options, names_news_decomp{n}) ;
                    %     [results.forecast.(mnemonic_news_decomp{n}).impact_by_group(:,v,modcounter), ...
                    %         results.forecast.(mnemonic_news_decomp{n}).details(v,modcounter).impacts, ...
                    %         results.forecast.(mnemonic_news_decomp{n}).details(v,modcounter).actuals, ...
                    %         results.forecast.(mnemonic_news_decomp{n}).details(v,modcounter).forecasts, ...
                    %         results.forecast.(mnemonic_news_decomp{n}).details(v,modcounter).weights, ...
                    %         results.forecast.(mnemonic_news_decomp{n}).details(v,modcounter).varnames ] = f_newsdecomp(js,tjs,tks,data_new,ks_output_old,params,options, i, std) ;
                    % end

                    for n = 1 : length(names_news_decomp)
                        results.nowcast.(mnemonic_news_decomp{n}).revised_data(1,v,modcounter) = results.nowcast.(mnemonic_news_decomp{n}).new(1,v,modcounter) - sum(results.nowcast.(mnemonic_news_decomp{n}).impact_by_group( : , v , modcounter ) ) ; 
                        results.forecast.(mnemonic_news_decomp{n}).revised_data(1,v,modcounter) = results.forecast.(mnemonic_news_decomp{n}).new(1,v,modcounter) - sum(results.forecast.(mnemonic_news_decomp{n}).impact_by_group( : , v , modcounter ) ) ; 
                    end

                    % - "update" data Kalman smoother output --------- %
                    ks_output_old = ks_output_new ;  
                    data_old = data_new ; 
                end
                
                modcounter = modcounter + 1 ;
                
                t_fore = t_fore(1:k_fore, :);
                writetable(t_fore, [dir_nowcast '\output_csv\' 'out_forecasts_' num2str(Nr) '_Np_' num2str(Np) '_Nj_' num2str(Nj) '.csv']);      
                
                t_news = t_news(1:k_news, :);
                writetable(t_news, [dir_nowcast '\output_csv\' 'out_news_' num2str(Nr) '_Np_' num2str(Np) '_Nj_' num2str(Nj) '.csv']);      
            end
        end
    end

    save([dir_nowcast '\output_mat\' 'results.mat'], 'results')    
    disp('Done generating nowcasts!')
    quit(0)
end
