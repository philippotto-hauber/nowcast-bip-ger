function out = plot_nowcast_evolution(dir_root, year_nowcast, quarter_nowcast)
    dir_nowcast = [dir_root '\Nowcasts\' year_nowcast 'Q' quarter_nowcast] ;
    load([dir_nowcast '\output_mat\results.mat'])

    Nrs = readmatrix('../../model_specs_Nrs.csv'); % # number of factors
    Nps = readmatrix('../../model_specs_Nps.csv'); % # of lags in factor VAR
    Njs = readmatrix('../../model_specs_Njs.csv'); % # of lags in idiosysncratic component

    str_nowcast = [year_nowcast 'Q' quarter_nowcast]; 
    
    if strcmp(quarter_nowcast, '4')
        str_forecast = [ num2str(str2double(year_nowcast) + 1) 'Q1'] ; 
    else 
        str_forecast = [ year_nowcast 'Q' quarter_nowcast] ; 
    end

    addpath('functions')

    vars = fieldnames(results.nowcast);

    % loop over vars
    for k = 1:numel(vars)
        var = vars{k};

        % loop over models
        modcounter = 1;
        for Nr = Nrs
            for Np = Nps
                for Nj = Njs
                    % --------------------------------------------------------------- %
                    % - plot nowcast & forecast evolution for current model --------- %                

                    titlename = [var ': nowcasts '  str_nowcast ' (Nr = ' num2str(Nr) ', Np = ' num2str(Np) ', Nj = ' num2str(Nj) ')'] ;
                    savename = ['nowcasts_' var '_' str_nowcast '_Nr' num2str(Nr) '_Np' num2str(Np) '_Nj' num2str(Nj)] ;
                    f_graphnowcastevolve(squeeze(results.nowcast.(var).new(1,:,modcounter)),...
                                        squeeze(results.nowcast.(var).impact_by_group(:,:,modcounter)),...
                                        [0 (squeeze(results.nowcast.(var).revised_data(1,2:end,modcounter)) - squeeze(results.nowcast.(var).new(1,1:end-1,modcounter)) ) ],...
                                        titlename,results.vintages,results.groupnames) ;
                    print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage')
                    close                      
                
                    titlename = [var ': forecasts ' str_forecast ' (Nr = ' num2str(Nr) ', Np = ' num2str(Np) ', Nj = ' num2str(Nj) ')'] ;
                    savename = ['forecasts_' var '_' str_forecast '_Nr' num2str(Nr) '_Np' num2str(Np) '_Nj' num2str(Nj)] ;
                    f_graphnowcastevolve(squeeze(results.forecast.(var).new(1,:,modcounter)),...
                                        squeeze(results.forecast.(var).impact_by_group(:,:,modcounter)),...
                                        [0 (squeeze(results.forecast.(var).revised_data(1,2:end,modcounter)) - squeeze(results.forecast.(var).new(1,1:end-1,modcounter)) ) ],...
                                        titlename,results.vintages,results.groupnames) ;
                    print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage') 
                    close
                    modcounter = modcounter + 1;
                end
            end
        end

        % ------------------------------------------------------------------- %
        % - plot nowcast & forecast evolution for equal-weigth pool --------- %
    
        titlename = [var ': nowcasts ' str_nowcast ' (equal-weight pool)'] ;
        savename = ['nowcasts_' var '_' str_nowcast '_equalweightpool'] ;
        f_graphnowcastevolve(mean(results.nowcast.(var).new(1,:,:),3),...
                            mean(results.nowcast.(var).impact_by_group(:,:,:),3),...
                            [0 (mean(results.nowcast.(var).revised_data(1,2:end,:),3) - mean(results.nowcast.(var).new(1,1:end-1,:),3) ) ],...
                            titlename,results.vintages,results.groupnames) ;
        
        print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage') 
        close
        
        titlename = [var ': forecasts ' str_forecast ' (equal-weight pool)'] ;
        savename = ['forecasts_' var '_' str_forecast '_equalweightpool'] ;
        f_graphnowcastevolve(mean(results.forecast.(var).new(1,:,:),3),...
                            mean(results.forecast.(var).impact_by_group(:,:,:),3),...
                            [0 (mean(results.forecast.(var).revised_data(1,2:end,:),3) - mean(results.forecast.(var).new(1,1:end-1,:),3) ) ],...
                            titlename,results.vintages,results.groupnames) ;
        
        print([dir_nowcast '\graphs\' savename],'-dpdf','-fillpage') 
        close
        
        % ------------------------------------------------------------------- %
        % - plot fan charts ------------------------------------------------- %
        
        figure
        fig = gcf;
        fig.PaperOrientation = 'landscape';
        subplot(2,1,1)
        nametitle = [' fan chart, nowcasts ' str_nowcast ': ' var] ;
        f_plotfanchart(squeeze(results.nowcast.(var).new(1,:,:)),nametitle,results.vintages)
        subplot(2,1,2)
        nametitle = [' fan chart, nowcasts ' str_forecast ': ' var] ;
        f_plotfanchart(squeeze(results.forecast.(var).new(1,:,:)),nametitle,results.vintages)
        
        print([dir_nowcast '\graphs\forecasts_' var '_fancharts'],'-dpdf','-fillpage') 
        close
    end
    disp('Done plotting nowcast evolution!')
    out = [];
end