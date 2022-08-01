function params = f_Mstep_rhoMz_SigMz(stT,PtT,data,params,options)

% --------------------------
% - rhoMz & SigMz
% --------------------------

if options.Nj>0
    id_eMz = options.Npmax*options.Nr+(options.Nj+1)*options.Nmx + 1 : options.Npmax*options.Nr+(options.Nj+1)*options.Nmx + options.Nmz  ;
    id_eMz_lags = options.Npmax*options.Nr+(options.Nj+1)*options.Nmx + options.Nmz + 1 : options.Npmax*options.Nr+(options.Nj+1)*options.Nmx + options.Nmz*(options.Nj+1) ;
    for i = 1 : options.Nmz
        % rhoMx
        numer = stT(id_eMz(i),:)*stT(id_eMz_lags(i),:)' + sum(PtT(id_eMz(i),id_eMz_lags(i),:),3) ; 
        denom = stT(id_eMz_lags(i),:)*stT(id_eMz_lags(i),:)' + sum(PtT(id_eMz_lags(i),id_eMz_lags(i),:),3) ; 
        params.rhoMz(i,1) = denom\numer ; 
    
        % SigMx
        temp = (stT(id_eMz(i),:)*stT(id_eMz(i),:)' + sum(PtT(id_eMz(i),id_eMz(i),:),3)) - ...
                params.rhoMz(i,1) * (stT(id_eMz(i),:)*stT(id_eMz_lags(i),:)' + sum(PtT(id_eMz(i),id_eMz_lags(i),:),3)); 
        params.SigMz(i,1) = 1/options.Nt * temp ; 
    end
else
    id_Nmz = options.Nmx+1 : options.Nmx+options.Nmz ; 
    id_f = 1:options.Npmax*options.Nr ; 
    f = stT(id_f,:) ; 
    temp = zeros(options.Nmz) ; 
    for t = 1 : options.Nt 
        datatemp = data(id_Nmz,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ;   
        temp = temp + Wt*(datatemp*datatemp')*Wt' - Wt*datatemp*f(:,t)'*kron(ones(1,12),params.lambdaMz)'*Wt - ...
               Wt*kron(ones(1,12),params.lambdaMz)*f(:,t)*datatemp' + ...
               Wt*kron(ones(1,12),params.lambdaMz) * (f(:,t)*f(:,t)' + PtT(id_f,id_f,t)) * kron(ones(1,12),params.lambdaMz)' * Wt + ...
               (eye(options.Nmz) - Wt) * diag(params.SigMz) * (eye(options.Nmz) - Wt) ; 
    end
    params.SigMz = diag(1/options.Nt * temp) ;
    params.rhoMz = [] ; 
end
