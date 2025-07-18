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
    
    % ----------------------------------------------------------------------- %
    % - add functions ------------------------------------------------------- %
    % ----------------------------------------------------------------------- %
    addpath('functions')
    
    % ----------------------------------------------------------------------- %
    % - make sure graphs and params folders exist --------------------------- %
    % ----------------------------------------------------------------------- %
    
    foldername = [dir_nowcast '\graphs'] ;if exist(foldername, 'dir') ~= 7;mkdir(foldername);end  
    foldername = [dir_nowcast '\params'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\docu'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\tables'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\monthlyGDP'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    foldername = [dir_nowcast '\non gdp forecasts'] ; if exist(foldername, 'dir') ~= 7;mkdir(foldername);end
    
    % ----------------------------------------------------------------------- %
    % - user specified settings --------------------------------------------- %
    % ----------------------------------------------------------------------- %
    
    % vintages
    vintages = importdata('../../dates_vintages.txt');
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
    Nrs = readmatrix('../../model_specs_Nrs.csv'); % # number of factors
    Nps = readmatrix('../../model_specs_Nps.csv'); % # of lags in factor VAR
    Njs = readmatrix('../../model_specs_Njs.csv'); % # of lags in idiosysncratic component
    
    % switches
    switch_estimatemodels = str2double(switch_estimatemodels); % convert string input to numeric
    switch_savetables = 1; % 1 = yes!
    switch_savegraphs = 1 ; % 1 = yes!
    switch_savedocus = 1 ; % 1 = yes!
    
    % list of vars to be removed from the data set 
    list_removevars = determine_vars_remove(dir_data, vintages, samplestart, samplestart:1/12:date_forecast);
    writecell(list_removevars.namegroup, [dir_nowcast, '\list_removed_vars.txt'])
    
    % monthly variables for which we store the forecasts based on the latest available vintages
    names_export = {'Industrie', 'Industrie', 'lkw_maut', 'ifo_lage', 'ifo_erwartung'};
    groups_export = {'production', 'orders', 'production', 'ifo', 'ifo'};
    mnemonic_export = {'ip', 'ord', 'lkwm', 'ifoLage', 'ifoErw'};
    
    if length(names_export) ~= length(groups_export) || length(names_export) ~= length(mnemonic_export)
        error('names, groups and mnemonics vector must be of the same length!')
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
    
    Nmodels = length(Nrs) * length(Nps) * length(Njs) ; % # of models
    modcounter = 1 ; % set model counter to 1 
    
    
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
                
                % ----------------- %
                % - load params --- %
                
                load([dir_nowcast '\params\params_Nr' num2str(Nr) '_Np' num2str(Np) '_Nj' num2str(Nj) '.mat']) ; 
           
                % ----------------------------- %
                % - load/construct data set --- %
    
                [dataM, dataQ, options.means, options.stds, ~, options.names, options.groups, ~, results.vintages{1}] = f_constructdataset(dir_data, samplestart,vintages{ 1 },list_removevars,[],[]) ; 
                data = [[dataM; dataQ] NaN(size(dataM,1) + size(dataQ,1) , length(options.dates) - size(dataM,2))] ;
                
                % --------------------------------- %
                % - calculate some more options --- %
                
                options.index_gdp = strcmp(options.names,'gross domestic product') ; 
                options.groupnames = unique(options.groups);
                options.meangdp = options.means(options.index_gdp) ; % DO I NEED THIS?
                options.stdgdp = options.stds(options.index_gdp) ; % DO I NEED THIS?
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
                
                results.nowcast.new(1,1,modcounter) = options.stdgdp * ( Z(options.index_gdp,:) * ks_output_old.stT(:,options.index_nowcast) ) + options.meangdp ; 
                results.forecast.new(1,1,modcounter) = options.stdgdp * ( Z(options.index_gdp,:) * ks_output_old.stT(:,options.index_forecast) ) + options.meangdp ;
                
             
                % rename data as old
                data_old = data ; 
                clearvars dataM dataQ data ; 
			    
			    % ------------------------------------------ %
                % - now loop over 2:Nvintages -------------- %  
                
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
                    results.nowcast.new(1,v,modcounter) = options.stdgdp * ( Z(options.index_gdp,:) * ks_output_new.stT(:,options.index_nowcast == 1) ) + options.meangdp ;
                    results.forecast.new(1,v,modcounter) = options.stdgdp * ( Z(options.index_gdp,:) * ks_output_new.stT(:,options.index_forecast == 1) ) + options.meangdp ;
                    
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
                    save([dir_nowcast '\monthlyGDP\' vintages{v} '\monthlyGDP_Nr' num2str(options.Nr) '_Np' num2str(options.Np) '_Nj' num2str(options.Nj) '.mat'], 'gdp_mm', 'gdp_3m3m', 'dates_converted', 'gdp_realizations', 'mean_gdp', 'std_gdp');
                    
                    
                    % calculate forecasts for specific monthly variables
                    if v == Nvintages
                        for i = 1:length(names_export)
                            ind = find(strcmp(options.names, names_export{i}) & strcmp(options.groups, groups_export{i}));
                            out.dat = options.stds(ind)* data_new(ind, :) + options.means(ind);
                            out.xi = options.stds(ind)* (Z(ind,:) * ks_output_new.stT) + options.means(ind);
                            save([dir_nowcast '\non gdp forecasts\' mnemonic_export{i} '_fore_model_' num2str(modcounter), '_v_' results.vintages{v}, '.mat'], 'out'); 
                        end
                        save([dir_nowcast '\non gdp forecasts\dates.mat'], 'dates_converted'); 
                    end
                    
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
                    
                    % nowcast
                    tks = find(options.index_nowcast == 1) ;    
                    
                    [results.nowcast.impact_by_group(:,v,modcounter), ...
                     results.nowcast.details(v,modcounter).impacts, ...
                     results.nowcast.details(v,modcounter).actuals, ...
                     results.nowcast.details(v,modcounter).forecasts, ...
                     results.nowcast.details(v,modcounter).weights, ...
                     results.nowcast.details(v,modcounter).varnames ] = f_newsdecomp_v2(js,tjs,tks,data_new,ks_output_old,params,options) ;
                   
                    % forecast
                    tks = find(options.index_forecast == 1) ; 
                    [results.forecast.impact_by_group(:,v,modcounter), ...
                     results.forecast.details(v,modcounter).impacts, ...
                     results.forecast.details(v,modcounter).actuals, ...
                     results.forecast.details(v,modcounter).forecasts, ...
                     results.forecast.details(v,modcounter).weights, ...
                     results.forecast.details(v,modcounter).varnames ] = f_newsdecomp_v2(js,tjs,tks,data_new,ks_output_old,params,options) ;
                    
                 
                    % compute nowcast due to data revisions
                    results.nowcast.revised_data(1,v,modcounter) = results.nowcast.new(1,v,modcounter) - sum(results.nowcast.impact_by_group( : , v , modcounter ) ) ; 
                    results.forecast.revised_data(1,v,modcounter) = results.forecast.new(1,v,modcounter) - sum(results.forecast.impact_by_group( : , v , modcounter ) ) ;
                    
                    % ------------------------------------------------ %
                    % - "update" data Kalman smoother output --------- %
                    ks_output_old = ks_output_new ;  
                    data_old = data_new ; 
                end
    
                % --------------------------------------------------------------- %
                % - plot nowcast & forecast evolution for current model --------- %
                
                if options.dates(options.index_nowcast) == floor(options.dates(options.index_nowcast)) % Q4
                    str_nowcast = [ num2str(floor(options.dates(options.index_nowcast)) - 1 ) 'Q4' ] ; 
                else 
                    str_nowcast = [ num2str(floor(options.dates(options.index_nowcast))) 'Q' num2str((options.dates(options.index_nowcast) - floor(options.dates(options.index_nowcast)))*12/3) ] ; 
                end
                
                titlename = ['nowcasts '  str_nowcast ' (Nr = ' num2str(options.Nr) ', Np = ' num2str(options.Np) ', Nj = ' num2str(options.Nj) ')'] ;
                savename = ['nowcasts_' str_nowcast '_Nr' num2str(options.Nr) '_Np' num2str(options.Np) '_Nj' num2str(options.Nj)] ;
                f_graphnowcastevolve(squeeze(results.nowcast.new(1,:,modcounter)),...
                                     squeeze(results.nowcast.impact_by_group(:,:,modcounter)),...
                                     [0 (squeeze(results.nowcast.revised_data(1,2:end,modcounter)) - squeeze(results.nowcast.new(1,1:end-1,modcounter)) ) ],...
                                     titlename,results.vintages,options.groupnames) ;
                if switch_savegraphs == 1
                    print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage')
                end
                close            
                
                if options.dates(options.index_forecast) == floor(options.dates(options.index_forecast)) % Q4
                    str_forecast = [ num2str(floor(options.dates(options.index_forecast)) - 1 ) 'Q4' ] ; 
                else 
                    str_forecast = [ num2str(floor(options.dates(options.index_forecast))) 'Q' num2str((options.dates(options.index_forecast) - floor(options.dates(options.index_forecast)))*12/3) ] ; 
                end
                
                titlename = ['nowcasts ' str_forecast ' (Nr = ' num2str(options.Nr) ', Np = ' num2str(options.Np) ', Nj = ' num2str(options.Nj) ')'] ;
                savename = ['nowcasts_' str_forecast '_Nr' num2str(options.Nr) '_Np' num2str(options.Np) '_Nj' num2str(options.Nj)] ;
                f_graphnowcastevolve(squeeze(results.forecast.new(1,:,modcounter)),...
                                     squeeze(results.forecast.impact_by_group(:,:,modcounter)),...
                                     [0 (squeeze(results.forecast.revised_data(1,2:end,modcounter)) - squeeze(results.forecast.new(1,1:end-1,modcounter)) ) ],...
                                     titlename,results.vintages,options.groupnames) ;
                if switch_savegraphs == 1
                    print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage') 
                end
                close
                
                % --------------------------------------------------------------- %
                % - assemble forecast revision docu and store as txt-file ------- %
                
                if switch_savedocus == 1
                    flag_ewpool = 0 ; 
                    threshold = 0.02 ; 
                    % nowcasts
                    savename = ['nowcasts_' str_nowcast '_Nr' num2str(options.Nr) '_Np' num2str(options.Np) '_Nj' num2str(options.Nj)] ;
                    f_docu(squeeze(results.nowcast.new(1,:,modcounter)), ...
                           results.vintages, ...
                           results.nowcast.details(:,modcounter), ...
                           options, ...
                           savename, ...
                           flag_ewpool, ...
                           threshold,...
                           dir_nowcast) ;               
    
                    % forecasts
                    savename = ['nowcasts_' str_forecast '_Nr' num2str(options.Nr) '_Np' num2str(options.Np) '_Nj' num2str(options.Nj)] ;
                    f_docu(squeeze(results.forecast.new(1,:,modcounter)), ...
                           results.vintages, ...
                           results.forecast.details(:,modcounter), ...
                           options, ...
                           savename, ...
                           flag_ewpool, ...
                           threshold, ...
                           dir_nowcast) ; 
                end
                
                % ----------------------------------------- %
                % - export tables to xls ------------------ %
    
                if switch_savetables == 1    
                    %varnames = {'Prognose', options.groupnames{:}, 'Revision'};
                    % nowcast
                    savename =  ['nowcasts_' str_nowcast '_Nr' num2str(options.Nr) '_Np' num2str(options.Np) '_Nj' num2str(options.Nj)] ;
                    f_table(results.nowcast.new( 1 , : , modcounter ), ...
                        [0 results.nowcast.revised_data(1,2:end,modcounter) - results.nowcast.new(1,1:end-1,modcounter)] , ...
                        results.nowcast.impact_by_group( : , : , modcounter ), ...
                        results.vintages, ...
                        savename, ...
                        options.groupnames, ...
                        dir_nowcast)
    
                    % forecast
                    savename =  ['nowcasts_' str_forecast '_Nr' num2str(options.Nr) '_Np' num2str(options.Np) '_Nj' num2str(options.Nj)] ;
                    f_table(results.forecast.new( 1 , : , modcounter ), ...
                        [0 results.forecast.revised_data(1,2:end,modcounter) - results.forecast.new(1,1:end-1,modcounter)],...
                        mean(results.forecast.impact_by_group,3), ...
                        results.vintages, ...
                        savename, ...
                        options.groupnames,...
                        dir_nowcast)
                end
                
                % --------------------------------------------------------------- %
                % - update model counter ---------------------------------------- %
                
                modcounter = modcounter + 1 ;
                
            end
        end
    end
    
    % ------------------------------------------------------------------- %
    % - plot nowcast & forecast evolution for equal-weigth pool --------- %
    
    titlename = ['nowcasts ' str_nowcast ' (equal-weight pool)'] ;
    savename = ['nowcasts_' str_nowcast '_equalweightpool'] ;
    f_graphnowcastevolve(mean(results.nowcast.new(1,:,:),3),...
                         mean(results.nowcast.impact_by_group(:,:,:),3),...
                         [0 (mean(results.nowcast.revised_data(1,2:end,:),3) - mean(results.nowcast.new(1,1:end-1,:),3) ) ],...
                         titlename,results.vintages,options.groupnames) ;
    
    if switch_savegraphs == 1
        print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage') 
    end
    close
    
    titlename = ['nowcasts ' str_forecast ' (equal-weight pool)'] ;
    savename = ['nowcasts_' str_forecast '_equalweightpool'] ;
    f_graphnowcastevolve(mean(results.forecast.new(1,:,:),3),...
                         mean(results.forecast.impact_by_group(:,:,:),3),...
                         [0 (mean(results.forecast.revised_data(1,2:end,:),3) - mean(results.forecast.new(1,1:end-1,:),3) ) ],...
                         titlename,results.vintages,options.groupnames) ;
    
    if switch_savegraphs == 1
        print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage') 
    end
    close
    
    % ------------------------------------------------------------------- %
    % - plot fan charts ------------------------------------------------- %
    
    figure
    fig = gcf;
    fig.PaperOrientation = 'landscape';
    subplot(2,1,1)
    nametitle = [' fan chart, nowcasts ' str_nowcast] ;
    f_plotfanchart(squeeze(results.nowcast.new(1,:,:)),nametitle,results.vintages)
    subplot(2,1,2)
    nametitle = [' fan chart, nowcasts ' str_forecast] ;
    f_plotfanchart(squeeze(results.forecast.new(1,:,:)),nametitle,results.vintages)
    
    if switch_savegraphs == 1
        print([dir_nowcast '\graphs\fancharts'],'-dpdf','-fillpage') 
    end
    close
    
    % --------------------------------------------------------------- %
    % - assemble forecast revision docu and store as txt-file ------- %
    
    if switch_savedocus == 1
        flag_ewpool = 1 ; 
        threshold = 0.02 ; 
        
        % nowcasts
        ew_pool_details = [] ;
        
        for v = 2 : Nvintages
            temp_forecasts = [] ; 
            temp_weights = [] ; 
            temp_impacts = [] ; 
            for m = 1 : Nmodels
                temp_forecasts(:,m) = results.nowcast.details(v,m).forecasts ; 
                temp_weights(:,m) = results.nowcast.details(v,m).weights ;
                temp_impacts(:,m) = results.nowcast.details(v,m).impacts ;
                if m == 1
                    ew_pool_details(v,1).varnames = results.nowcast.details(v,m).varnames ; 
                    ew_pool_details(v,1).actuals = results.nowcast.details(v,m).actuals ; 
                end
            end
            ew_pool_details(v,1).forecasts = mean(temp_forecasts,2) ; 
            ew_pool_details(v,1).weights = mean(temp_weights,2) ; 
            ew_pool_details(v,1).impacts = mean(temp_impacts,2) ; 
        end
        
        savename = ['nowcasts_' str_nowcast '_equalweightpool'] ;
        f_docu(mean(results.nowcast.new(1,:,:),3), ...
               results.vintages, ...
               ew_pool_details, ...
               options, ...
               savename, ...
               flag_ewpool, ...
               threshold, ...
               dir_nowcast) ; 
           
        f_docuII(mean(results.nowcast.new(1,:,:),3), ...
                 results.vintages, ...
                 ew_pool_details, ...
                 options, ...
                 savename, ...
                 flag_ewpool, ...
                 dir_nowcast)   
    
        % forecasts
        ew_pool_details = [] ; 
        
        for v = 2 : Nvintages
            temp_forecasts = [] ; 
            temp_weights = [] ; 
            temp_impacts = [] ; 
            for m = 1 : Nmodels
                temp_forecasts(:,m) = results.forecast.details(v,m).forecasts ; 
                temp_weights(:,m) = results.forecast.details(v,m).weights ;
                temp_impacts(:,m) = results.forecast.details(v,m).impacts ;
                if m == 1
                    ew_pool_details(v,1).varnames = results.forecast.details(v,m).varnames ; 
                    ew_pool_details(v,1).actuals = results.forecast.details(v,m).actuals ; 
                end
            end
            ew_pool_details(v,1).forecasts = mean(temp_forecasts,2) ; 
            ew_pool_details(v,1).weights = mean(temp_weights,2) ; 
            ew_pool_details(v,1).impacts = mean(temp_impacts,2) ; 
        end
        
        savename = ['nowcasts_' str_forecast '_equalweightpool'] ;
        f_docu(mean(results.forecast.new(1,:,:),3), ...
               results.vintages, ...
               ew_pool_details, ...
               options, ...
               savename, ...
               flag_ewpool, ...
               threshold,...
               dir_nowcast) ; 
           
        f_docuII(mean(results.forecast.new(1,:,:),3), ...
                 results.vintages, ...
                 ew_pool_details, ...
                 options, ...
                 savename, ...
                 flag_ewpool, ...
                 dir_nowcast)   
    end
    
    % --------------------------------------------------------------- %
    % - export tables to xls ---------------------------------------- %
    
    if switch_savetables == 1    
        %varnames = {'Prognose', options.groupnames{:}, 'Revision'};
        % nowcast
        savename = ['nowcasts_' str_nowcast '_equalweightpool'] ;
        f_table(mean(results.nowcast.new,3), ...
            [0 mean(results.nowcast.revised_data(1,2:end,:),3) - mean(results.nowcast.new(1,1:end-1,:),3)] , ...
            mean(results.nowcast.impact_by_group,3), ...
            results.vintages, ...
            savename, ...
            options.groupnames, ...
            dir_nowcast)
        
        % forecast
        savename = ['nowcasts_' str_forecast '_equalweightpool'] ;
        f_table(mean(results.forecast.new,3), ...
            [0 mean(results.forecast.revised_data(1,2:end,:),3) - mean(results.forecast.new(1,1:end-1,:),3)],...
            mean(results.forecast.impact_by_group,3), ...
            results.vintages, ...
            savename, ...
            options.groupnames, ...
            dir_nowcast)
    end
    disp('Done generating nowcasts!')
    out = [];
end
