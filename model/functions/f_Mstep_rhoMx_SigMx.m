function params = f_Mstep_rhoMx_SigMx(stT,PtT,data,params,options)

% --------------------------------------------------
% - extract a few things and define identifiers
% --------------------------------------------------

id_Nmx = 1 : options.Nmx ;
id_eMx = options.Npmax*options.Nr + 1 : options.Npmax*options.Nr + options.Nmx ;
id_eMx_lags = options.Npmax*options.Nr + options.Nmx + 1 : options.Npmax*options.Nr + options.Nmx * (options.Nj+1) ; 
id_f = 1 : options.Nr ; 
temp = zeros(options.Nmx) ; 
f = stT(id_f,:) ; 

% -------------------------------------------------
% - rhoMx & SigMx
% -------------------------------------------------

if options.Nj>0
     for i = 1 : options.Nmx
        % rhoMx
        numer = stT(id_eMx(i):id_eMx(i),:)*stT(id_eMx_lags(i):id_eMx_lags(i),:)' + sum(PtT(id_eMx(i),id_eMx_lags(i),:),3) ; 
        denom = stT(id_eMx_lags(i),:)*stT(id_eMx_lags(i),:)' + sum(PtT(id_eMx_lags(i),id_eMx_lags(i),:),3) ; 
        params.rhoMx(i,1) = denom\numer ; 
    
        % SigMx
        e_Mx = stT(id_eMx(i),:) ; 
        e_Mx_minusone = stT(id_eMx_lags(i),:) ; 
        temp = (e_Mx*e_Mx' + sum(PtT(id_eMx(i),id_eMx(i),:),3)) - ...
                params.rhoMx(i,1) * (e_Mx*e_Mx_minusone' + sum(PtT(id_eMx_lags(i),id_eMx(i),:),3)); 
        params.SigMx(i,1) = 1/options.Nt * temp ; 
    end
else    
    for t = 1 : options.Nt 
        datatemp = data(id_Nmx,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ;   
        temp = temp + Wt*(datatemp*datatemp')*Wt' - Wt*datatemp*f(:,t)'*params.lambdaMx'*Wt - ...
               Wt*params.lambdaMx*f(:,t)*datatemp' + ...
               Wt*params.lambdaMx * (f(:,t)*f(:,t)' + PtT(id_f,id_f,t)) * params.lambdaMx' * Wt + ...
               (eye(options.Nmx) - Wt) * diag(params.SigMx) * (eye(options.Nmx) - Wt) ; 
    end
    params.SigMx = diag(1/options.Nt * temp) ;
    params.rhoMx = [] ; 
end