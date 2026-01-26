function params = f_Mstep_A_Omeg(stT,PtT,params,options)

% --------------------------------------------------
% - extract a few things and define identifiers
% --------------------------------------------------

id_f = 1 : options.Nr ;
id_f_lags = options.Nr + 1 : options.Nr*(options.Np+1) ;  

f = stT(id_f,:) ; 
f_lags = stT(id_f_lags,:) ; 

% --------------------------
% - A 
% --------------------------
params.A = (f*f_lags' + sum(PtT(id_f,id_f_lags,:),3))/(f_lags*f_lags' + sum(PtT(id_f_lags,id_f_lags,:),3)) ; 

% --------------------------
% - Omeg
% --------------------------
params.Omeg = 1/options.Nt * ((f*f' + sum(PtT(id_f,id_f,:),3))  - params.A * (f*f_lags' + sum(PtT(id_f,id_f_lags,:),3))') ; 


