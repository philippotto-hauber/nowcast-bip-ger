function [decomp, nowcast_new, nowcast_old] = f_computenewsdecomp(params,vintages,tks,newobs,revobs)

% --------------------------- %
% - get Nm, Nq, Nr and Np
% --------------------------- %

[Nm, Nr] = size(params.lambdam) ; 
Nq = size(params.lambdaq,1) ; 
Np = size(params.phi_eta,2)/Nr ; 


% --------------------------- %
% - js and tjs
% --------------------------- %

[js_newobs, tjs_newobs] = find(newobs == 1) ; 
[js_revobs, tjs_revobs] = find(revobs == 1) ; 

js = [js_revobs; js_newobs] ;
tjs = [tjs_revobs; tjs_newobs] ; 
decomp.flag_revised = [ones(length(js_revobs),1) ; zeros(length(js_newobs),1)] ; 
decomp.varindex = js ; 

% ----------------------------------------------------------------------- %
% - state space params
% ----------------------------------------------------------------------- %

Ns = 5*(Nr+Nq) ; 
maxcorr = max([abs(max(tjs) - min(tks)),abs(min(tjs) - max(tks)),abs(max(tjs) - min(tjs))]) ; 
phitemp = zeros(Nr+Nq) ; 
phitemp(1:Nr,1:Nr) = params.phi_eta ; 

T = [phitemp zeros(Nr+Nq,4*(Nr+Nq)) zeros(Nr+Nq,maxcorr*(Nr + Nq));
    eye(Ns + (maxcorr-1)*(Nr + Nq)) zeros(Ns + (maxcorr-1)*(Nr + Nq),Nr+Nq)] ; 

Q = zeros(Nr+Nq) ; 
Q(1:Nr,1:Nr) = params.Omega_upsilon ; 
Q(Nr+Nq,Nr+Nq) = params.Omega_u(end-Nq+1:end) ; 

R = [eye(Nr+Nq) ; 
    zeros(4*(Nr+Nq),Nr+Nq)
    zeros(maxcorr*(Nr + Nq),Nr+Nq)];

RQR = R*Q*R' ;

Z = [params.lambdam zeros(Nm,Nq) zeros(Nm, 4*(Nr+Nq)) zeros(Nm, maxcorr*(Nr + Nq)) ;
     kron([1/3 2/3 3/3 2/3 1/3],[params.lambdaq ones(Nq,1)]) zeros(Nq, maxcorr*(Nr + Nq))]; 

H = zeros(Nm+Nq) ; 
H(1:Nm,1:Nm) = params.Omega_u(1:Nm,1:Nm) ; 

% ----------------------------------------------------------------------- %
% - run Kalman filter/smoother
% ----------------------------------------------------------------------- %

% first vintage
s0 = zeros(size(T,1),1) ; 
vecRQR = RQR(:) ;
%vecP0 = (eye(size(T,1)^2) - kron(T,T))\vecRQR ; 
%P0 = reshape(vecP0,size(T,1),size(T,1)) ; 
P0 = 10 * eye(size(T,1)) ; 
[stt_1,Ptt_1,sttminusone_1,Pttminusone_1,stT_1,PtT_1,news_1,Kalmangain_1] = f_KalmanSmootherv2(vintages.old,T,Z,H,R,Q,s0,P0) ; 

nowcast_old = Z(end-Nq+1:end,:) * stT_1(:,tks) ; 

% compute news => don't need to run Kalman filter again!!
E_II = NaN(length(js)) ; 
E_ykI = NaN(1,length(js)) ;
decomp.news = NaN(length(js),1) ; 
decomp.actual = NaN(length(js),1) ; 
for j = 1 : length(js)    
    x_fore = Z(js(j),:) * stT_1(:,tjs(j)) ; 
    x_actual = vintages.new(js(j),tjs(j)) ; 
    decomp.news(j) = x_actual - x_fore ; 
    decomp.actual(j) = x_actual ; 
    for l = 1 : length(js)
        diff_t = abs(tjs(j)-tjs(l)) ; 
        if tjs(j) < tjs(l)
            E_II(j,l) = Z(js(j),1:Ns) * PtT_1((Nr+Nq)*diff_t+[1:Ns],1:Ns,tjs(l)) * Z(js(l),1:Ns)' + H(js(j),js(l)) ;
        else
            E_II(j,l) = Z(js(j),1:Ns) * PtT_1(1:Ns,(Nr+Nq)*diff_t+[1:Ns],tjs(j)) * Z(js(l),1:Ns)' + H(js(j),js(l)) ;
        end        
    end
    
    diff_t = abs(tks-tjs(j)) ; 
    if tks < tjs(j)
    %E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1(1:Ns,(Nr+Nq)*k+[1:Ns],max(tks,tjs(j))) * Z(js(j),1:Ns)' ; 
    %E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1(1:Ns,(Nr+Nq)*k+[1:Ns],tks) * Z(js(j),1:Ns)' ; 
        E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1((Nr+Nq)*diff_t+[1:Ns],1:Ns,tjs(j)) * Z(js(j),1:Ns)' ; 
    else
        E_ykI(j) = Z(end-Nq+1:end,1:Ns) * PtT_1(1:Ns,(Nr+Nq)*diff_t+[1:Ns],tks) * Z(js(j),1:Ns)' ; 
    end
        
end

decomp.weights =  E_ykI/E_II ;
decomp.impact = decomp.weights' .* decomp.news ; 
%forecastrevision_news = sum(impact) ; 

% second vintage
[stt_2,Ptt_2,sttminusone_2,Pttminusone_2,stT_2,PtT_2,news_2,Kalmangain_2] = f_KalmanSmootherv2(vintages.new,T,Z,H,R,Q,s0,P0) ; 

nowcast_new = Z(end-Nq+1:end,:) * stT_2(:,tks) ; 
% disp('summed impact ....')
% sum(decomp.impact)
% disp('.... vs forecast revision')
% nowcast_new-nowcast_old
%tjs





