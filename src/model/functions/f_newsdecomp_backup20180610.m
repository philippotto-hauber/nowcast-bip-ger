function [nowcast_new,nowcast_new_revonly,news,impact,groupcontrib] = f_newsdecomp(js,tjs,tks,data_new,data_new_revonly,Nr,Np,Nm,Nq,params,index_gdp,groupnames,groups_new)

maxcorr = max([abs(max(tjs) - min(tks)),abs(min(tjs) - max(tks)),abs(max(tjs) - min(tjs))]) ; 
[T, Z, R, Q, H] = f_statespaceparams_news(params,Nr,Np,Nm,Nq,maxcorr) ;
s0 = zeros(size(T,1),1) ; 
P0 = 10 * eye(size(T,1)) ; 
[stt,Ptt,sttminusone,Pttminusone,stT,PtT,~,~] = f_KalmanSmootherv2(data_new_revonly,T,Z,H,R,Q,s0,P0) ;
%ks_output = f_KalmanSmootherDK(data_new_revonly,T,Z,H,R,Q,s0,P0) ;
nowcast_new_revonly = Z(index_gdp,:) * stT(:,tks) ;
%nowcast_new_revonly = Z(index_gdp,:) * ks_output.stT(:,tks) ;

% ---------------------- %
% - news decomposition - %
Ns = 5*(Nr+Nq) ; 
E_II = NaN(length(js)) ; 
E_ykI = NaN(1,length(js)) ;
news = NaN(length(js),1) ; 
actual = NaN(length(js),1) ; 
for j = 1 : length(js)    
    x_fore = Z(js(j),:) * stT(:,tjs(j)) ; 
    x_actual = data_new(js(j),tjs(j)) ; 
    news(j) = x_actual - x_fore ; 
    actual(j) = x_actual ; 
    for l = 1 : length(js)
        diff_t = abs(tjs(j)-tjs(l)) ; 
        if tjs(j) < tjs(l)
            E_II(j,l) = Z(js(j),1:Ns) * PtT((Nr+Nq)*diff_t+[1:Ns],1:Ns,tjs(l)) * Z(js(l),1:Ns)' + H(js(j),js(l)) ;
        else
            E_II(j,l) = Z(js(j),1:Ns) * PtT(1:Ns,(Nr+Nq)*diff_t+[1:Ns],tjs(j)) * Z(js(l),1:Ns)' + H(js(j),js(l)) ;
        end        
    end

    diff_t = abs(tks-tjs(j)) ; 
    if tks < tjs(j)
    %E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1(1:Ns,(Nr+Nq)*k+[1:Ns],max(tks,tjs(j))) * Z(js(j),1:Ns)' ; 
    %E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1(1:Ns,(Nr+Nq)*k+[1:Ns],tks) * Z(js(j),1:Ns)' ; 
        E_ykI(j) = Z(index_gdp,1:Ns) * PtT((Nr+Nq)*diff_t+[1:Ns],1:Ns,tjs(j)) * Z(js(j),1:Ns)' ; 
        %E_ykI(j) = Z(index_gdp,1:(Nr+1)) * PtT((Nr+Nq)*diff_t+[1:(Nr+1)],1:(Nr+1),tjs(j)) * Z(js(j),1:(Nr+1))' ; 
    else
        E_ykI(j) = Z(index_gdp,1:Ns) * PtT(1:Ns,(Nr+Nq)*diff_t+[1:Ns],tks) * Z(js(j),1:Ns)' ;
        %E_ykI(j) = Z(index_gdp,1:(Nr+1)) * PtT(1:(Nr+1),(Nr+Nq)*diff_t+[1:(Nr+1)],tks) * Z(js(j),1:(Nr+1))' ;
    end

end

weights =  E_ykI/E_II ;
impact = weights' .* news ; 
varindex = js ; 
temp = groups_new(varindex) ; 
for g = 1 : length(groupnames)     
    indexgroup = strcmp(temp,groupnames{g}) ; 
    groupcontrib(g,1) = sum(impact(indexgroup)) ; 
end 


% ------------------------- %
% - nowcast with new data - %

[~,~,~,~,stT,~,~,~] = f_KalmanSmootherv2(data_new,T,Z,H,R,Q,s0,P0) ;

nowcast_new = Z(index_gdp,:) * stT(:,tks) ;
