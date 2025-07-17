function [nowcast_new,nowcast_new_revonly,news,impact,groupcontrib] = f_newsdecomp(js,tjs,tks,data_new,data_new_revonly,Nr,Np,Nj,Nm,Nq,params,index_gdp,groupnames,groups_new)

%maxcorr = max([abs(max(tjs) - min(tks)),abs(min(tjs) - max(tks)),abs(max(tjs) - min(tjs))]) ; 
maxcorr = 0 ;
if Nj > 0
    [T, Z, R, Q, H] = f_statespaceparams_news_Nj1(params,Nr,Np,Nm,Nq,maxcorr) ;
else
    [T, Z, R, Q, H] = f_statespaceparams_news(params,Nr,Np,Nm,Nq,maxcorr) ;
end

%[stt,Ptt,sttminusone,Pttminusone,stT,PtT,~,~] = f_KalmanSmootherv2(data_new_revonly,T,Z,H,R,Q,s0,P0) ;
%nowcast_new_revonly = Z(index_gdp,:) * stT(:,tks) ;
%maxcorr = 0 ; 
%[T2, Z2, R2, Q2, H2] = f_statespaceparams_news(params,Nr,Np,Nm,Nq,maxcorr) ;
s0 = zeros(size(T,1),1) ; 
P0 = 10 * eye(size(T,1)) ;
ks_output = f_KalmanSmootherDK(data_new_revonly,T,Z,H,R,Q,s0,P0) ;
nowcast_new_revonly = Z(index_gdp,:) * ks_output.stT(:,tks) ;

% ---------------------- %
% - news decomposition - %
if Nj>0
    Ns = 5*(Nr+Nq) + Nm ; 
else
    Ns = 5*(Nr+Nq) ;
end

E_II = NaN(length(js)) ; 
E_ykI = NaN(1,length(js)) ;
news = NaN(length(js),1) ; 
actual = NaN(length(js),1) ; 
for j = 1 : length(js)    
    x_fore = Z(js(j),:) * ks_output.stT(:,tjs(j)) ; 
    x_actual = data_new(js(j),tjs(j)) ; 
    news(j) = x_actual - x_fore ; 
    actual(j) = x_actual ; 
    for l = 1 : length(js)
        diff_t = abs(tjs(j)-tjs(l)) ; 
        if tjs(j) < tjs(l)
            %E_II(j,l) = Z(js(j),1:Ns) * PtT((Nr+Nq)*diff_t+[1:Ns],1:Ns,tjs(l)) * Z(js(l),1:Ns)' + H(js(j),js(l)) ;
            covarPtT = ks_output.P(:,:,tjs(j)) ;
            for t = tjs(j):tjs(l)-1
                  covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
            end
            covarPtT = covarPtT * (eye(Ns) - ks_output.N(:,:,tjs(l)) * ks_output.P(:,:,tjs(l))) ; 
            
            E_II(j,l) = Z(js(j),:) * covarPtT * Z(js(l),:)' + H(js(j),js(l)) ;
        else
            %E_II(j,l) = Z(js(j),1:Ns) * PtT(1:Ns,(Nr+Nq)*diff_t+[1:Ns],tjs(j)) * Z(js(l),1:Ns)' + H(js(j),js(l)) ;
            covarPtT = ks_output.P(:,:,tjs(l)) ;
            for t = tjs(l):tjs(j)-1
                   covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
            end
            covarPtT = covarPtT * (eye(Ns) - ks_output.N(:,:,tjs(j)) * ks_output.P(:,:,tjs(j))) ; 
            
            E_II(j,l) = Z(js(j),:) * covarPtT' * Z(js(l),:)' + H(js(j),js(l)) ;
        end        
    end

    diff_t = abs(tks-tjs(j)) ; 
    if tks < tjs(j)
    %E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1(1:Ns,(Nr+Nq)*k+[1:Ns],max(tks,tjs(j))) * Z(js(j),1:Ns)' ; 
    %E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1(1:Ns,(Nr+Nq)*k+[1:Ns],tks) * Z(js(j),1:Ns)' ; 
        %E_ykI(j) = Z(index_gdp,1:Ns) * PtT((Nr+Nq)*diff_t+[1:Ns],1:Ns,tjs(j)) * Z(js(j),1:Ns)' ; 
        %E_ykI(j) = Z(index_gdp,1:(Nr+1)) * PtT((Nr+Nq)*diff_t+[1:(Nr+1)],1:(Nr+1),tjs(j)) * Z(js(j),1:(Nr+1))' ; 
        covarPtT = ks_output.P(:,:,tks) ;
        for t = tks:tjs(j)-1
              covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
        end
        covarPtT = covarPtT * (eye(Ns) - ks_output.N(:,:,tjs(j)) * ks_output.P(:,:,tjs(j))) ; 

        E_ykI(j) =  Z(index_gdp,:) * covarPtT  * Z(js(j),1:Ns)' ;
    else
        %E_ykI(j) = Z(index_gdp,1:Ns) * PtT(1:Ns,(Nr+Nq)*diff_t+[1:Ns],tks) * Z(js(j),1:Ns)' ;
        %E_ykI(j) = Z(index_gdp,1:(Nr+1)) * PtT(1:(Nr+1),(Nr+Nq)*diff_t+[1:(Nr+1)],tks) * Z(js(j),1:(Nr+1))' ;
                covarPtT = ks_output.P(:,:,tjs(j)) ;
        for t = tjs(j):tks-1
              covarPtT = covarPtT * ks_output.L(:,:,t)' ; 
        end
        covarPtT = covarPtT * (eye(Ns) - ks_output.N(:,:,tks) * ks_output.P(:,:,tks)) ; 

        E_ykI(j) = Z(index_gdp,:) * covarPtT'  * Z(js(j),:)' ;
    end

end

weights =  E_ykI/E_II ;
%weights2 = E_ykI2/E_II2 ;
impact = weights' .* news ; 
%impact2 = weights2' .* news ; 
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
