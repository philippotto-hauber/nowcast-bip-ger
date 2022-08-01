function [nowcast_new, nowcast_new_revonly, impact_by_group, impacts_restand, actuals_restand, forecasts_restand, weights_restand, varnames] = f_newsdecomp(js,tjs,tks,data_new,data_new_revonly,params,options)

% actuals_sorted = [] ; 
% forecasts_sorted = [] ; 
% weights_sorted = [] ; 
% impacts_sorted = [] ; 
% names_sorted = [] ; 

% --------------------------------------------- %
% - run Kalman smoother over revised data ----- %

[T, Z, R, Q, H] = f_statespaceparams_news(params,options) ;

s0 = zeros(size(T,1),1) ; 
P0 = 10 * eye(size(T,1)) ;

ks_output = f_KalmanSmootherDK(data_new_revonly,T,Z,H,R,Q,s0,P0) ;
nowcast_new_revonly = options.stdgdp * ( Z(options.index_gdp,:) * ks_output.stT(:,tks) ) + options.meangdp ;

% ----------------------------------- %
% - news decomposition -------------- %

% empty mats to store results
E_II = NaN(length(js)) ; 
E_ykI = NaN(1,length(js)) ;
news = NaN(length(js),1) ; 
actuals = NaN(length(js),1) ; 
forecasts = NaN(length(js),1) ; 

% loop over js
for j = 1 : length(js)    
    x_fore = Z(js(j),:) * ks_output.stT(:,tjs(j)) ; 
    x_actual = data_new(js(j),tjs(j)) ; 
    news(j) = x_actual - x_fore ; 
    actuals(j) = x_actual ; 
    forecasts(j) = x_fore ; 
    
    % second loop over js
    for l = 1 : length(js)
        if tjs(j) < tjs(l)
            covarPtT = ks_output.P(:,:,tjs(j)) ;
            for t = tjs(j):tjs(l)-1
                  covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
            end
            covarPtT = covarPtT * (eye(options.Ns) - ks_output.N(:,:,tjs(l)) * ks_output.P(:,:,tjs(l))) ; 
            
            E_II(j,l) = Z(js(j),:) * covarPtT * Z(js(l),:)' + H(js(j),js(l)) ;
        else
            covarPtT = ks_output.P(:,:,tjs(l)) ;
            for t = tjs(l):tjs(j)-1
                   covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
            end
            covarPtT = covarPtT * (eye(options.Ns) - ks_output.N(:,:,tjs(j)) * ks_output.P(:,:,tjs(j))) ; 
            
            E_II(j,l) = Z(js(j),:) * covarPtT' * Z(js(l),:)' + H(js(j),js(l)) ;
        end        
    end

    if tks < tjs(j)
        covarPtT = ks_output.P(:,:,tks) ;
        for t = tks:tjs(j)-1
              covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
        end
        covarPtT = covarPtT * (eye(options.Ns) - ks_output.N(:,:,tjs(j)) * ks_output.P(:,:,tjs(j))) ; 

        E_ykI(j) =  Z(options.index_gdp,:) * covarPtT  * Z(js(j),1:Ns)' ;
    else
        covarPtT = ks_output.P(:,:,tjs(j)) ;
        for t = tjs(j):tks-1
              covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
        end
        covarPtT = covarPtT * (eye(options.Ns) - ks_output.N(:,:,tks) * ks_output.P(:,:,tks)) ; 

        E_ykI(j) = Z(options.index_gdp,:) * covarPtT'  * Z(js(j),:)' ;
    end
end

% weights and impact
weights =  E_ykI/E_II ;
impacts =  (weights' .* news) ; 
impacts_restand = options.stdgdp * impacts ; 

% new nowcast as the sum of the nowcast with revised data and the summed impact
nowcast_new = nowcast_new_revonly + sum(impacts_restand) ; 

% ----------------------------------------------------------------------- %
% - store names and also re-standardize actuals, forecasts & weights ---- %
for j = 1 : length(js)
    % store name => name + group
    varnames{j,1} = [options.names{js(j)} ' (' options.groups{js(j)} ')'] ; 
    actuals_restand(j,1) = actuals(j)*options.stds(js(j)) + options.means(js(j)) ;
    forecasts_restand(j,1) = forecasts(j)*options.stds(js(j)) + options.means(js(j)) ;
    weights_restand(j,1) = weights(j) * options.stds(options.index_gdp)/options.stds(js(j)) ; 
end


% ----------------------------------- %
% - impact by groups ---------------- %

varindex = js ; 
temp = options.groups(varindex) ; 
for g = 1 : length(options.groupnames)     
    indexgroup = strcmp(temp,options.groupnames{g}) ; 
    impact_by_group(g,1) = sum(impacts_restand(indexgroup)) ; 
end 



% ----------------------------------- %
% - nowcast with new data ----------- %
ks_output = f_KalmanSmootherDK(data_new,T,Z,H,R,Q,s0,P0) ;

nowcast_new_check = options.stdgdp * ( Z(options.index_gdp,:) * ks_output.stT(:,tks) ) + options.meangdp ;
if abs(nowcast_new - nowcast_new_check)>1e-04
    disp('Summed impacts and revised forecast do not add up to new one!')
    disp(['Difference is ' num2str( nowcast_new_check - nowcast_new ) ] )
end

