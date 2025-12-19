function [impact_by_group, impacts_restand, actuals_restand, forecasts_restand, weights_restand, varnames] = f_newsdecomp(js,tjs,tks,data_new,ks_output_old,params,options, index_target, std_target)
% this function computes the news in a different way!
% First, given the unrevised data and new observations, compute the news. 
% Then, run the Kalman smoother on the new data to 
% get the new forecast which includes revisions!!!!!!

% ----------------------------------- %
% - news decomposition -------------- %

% state space params
[T, Z, R, Q, H] = f_statespaceparams_news(params,options) ;

% empty mats to store results
E_II = NaN(length(js)) ; 
E_ykI = NaN(1,length(js)) ;
news = NaN(length(js),1) ; 
actuals = NaN(length(js),1) ; 
forecasts = NaN(length(js),1) ; 

% loop over js
for j = 1 : length(js)    
    x_fore = Z(js(j),:) * ks_output_old.stT(:,tjs(j)) ; 
    x_actual = data_new(js(j),tjs(j)) ; 
    news(j) = x_actual - x_fore ; 
    actuals(j) = x_actual ; 
    forecasts(j) = x_fore ; 
    
    % second loop over js
    for l = 1 : length(js)
        if tjs(j) < tjs(l)
            covarPtT = ks_output_old.P(:,:,tjs(j)) ;
            for t = tjs(j):tjs(l)-1
                  covarPtT = covarPtT * ks_output_old.L(:,:,t)' ; 
            end
            covarPtT = covarPtT * (eye(options.Ns) - ks_output_old.N(:,:,tjs(l)) * ks_output_old.P(:,:,tjs(l))) ; 
            
            E_II(j,l) = Z(js(j),:) * covarPtT * Z(js(l),:)' + H(js(j),js(l)) ;
        else
            covarPtT = ks_output_old.P(:,:,tjs(l)) ;
            for t = tjs(l):tjs(j)-1
                   covarPtT = covarPtT * ks_output_old.L(:,:,t)' ; 
            end
            covarPtT = covarPtT * (eye(options.Ns) - ks_output_old.N(:,:,tjs(j)) * ks_output_old.P(:,:,tjs(j))) ; 
            
            E_II(j,l) = Z(js(j),:) * covarPtT' * Z(js(l),:)' + H(js(j),js(l)) ;
        end        
    end

    if tks < tjs(j)
        covarPtT = ks_output_old.P(:,:,tks) ;
        for t = tks:tjs(j)-1
              covarPtT = covarPtT * ks_output_old.L(:,:,t)' ; 
        end
        covarPtT = covarPtT * (eye(options.Ns) - ks_output_old.N(:,:,tjs(j)) * ks_output_old.P(:,:,tjs(j))) ; 

        E_ykI(j) =  Z(index_target,:) * covarPtT  * Z(js(j),1:options.Ns)' ;
    else
        covarPtT = ks_output_old.P(:,:,tjs(j)) ;
        for t = tjs(j):tks-1
              covarPtT = covarPtT * ks_output_old.L(:,:,t)' ; 
        end
        covarPtT = covarPtT * (eye(options.Ns) - ks_output_old.N(:,:,tks) * ks_output_old.P(:,:,tks)) ; 

        E_ykI(j) = Z(index_target,:) * covarPtT'  * Z(js(j),:)' ;
    end
end

% weights and impact
weights =  E_ykI/E_II ;
impacts =  (weights' .* news) ; 
impacts_restand = std_target * impacts ; 

% ----------------------------------------------------------------------- %
% - store names and also re-standardize actuals, forecasts & weights ---- %
for j = 1 : length(js)
    % store name => name + group
    varnames{j,1} = [options.names{js(j)} ' (' options.groups{js(j)} ')'] ; 
    actuals_restand(j,1) = actuals(j)*options.stds(js(j)) + options.means(js(j)) ;
    forecasts_restand(j,1) = forecasts(j)*options.stds(js(j)) + options.means(js(j)) ;
    weights_restand(j,1) = weights(j) * options.stds(index_target)/options.stds(js(j)) ; 
end


% ----------------------------------- %
% - impact by groups ---------------- %

varindex = js ; 
temp = options.groups(varindex) ; 
for g = 1 : length(options.groupnames)     
    indexgroup = strcmp(temp,options.groupnames{g}) ; 
    impact_by_group(g,1) = sum(impacts_restand(indexgroup)) ; 
end 


