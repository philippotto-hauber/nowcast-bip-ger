function params = f_Mstep_rhoQ_flow_SigQ_flow_v2(data,stT,PtT,params,options)

% --------------------------
% - rhoQ_flow & SigQ_flow
% --------------------------

if options.Nj>0
    id_eQ_flow = options.Nr*options.Npmax + (options.Nj+1)*(options.Nmx+options.Nmz) + 1 : options.Nr*options.Npmax + (options.Nj+1)*(options.Nmx + options.Nmz) + options.Nq_flow ; 
    id_eQ_flow_lags = options.Nr*options.Npmax + (options.Nj+1)*(options.Nmx+options.Nmz) + options.Nq_flow + 1 : options.Nr*options.Npmax + (options.Nj+1)*(options.Nmx+options.Nmz) + (options.Nj+1)*options.Nq_flow ; 
    for i = 1 : options.Nq_flow
        % rhoMx
        numer = stT(id_eQ_flow(i),:)*stT(id_eQ_flow_lags(i),:)' + sum(PtT(id_eQ_flow(i),id_eQ_flow_lags(i),:),3) ; 
        denom = stT(id_eQ_flow_lags(i),:)*stT(id_eQ_flow_lags(i),:)' + sum(PtT(id_eQ_flow_lags(i),id_eQ_flow_lags(i),:),3) ; 
        params.rhoQ_flow(i,1) = denom\numer ; 
    
        % SigMx
        e_Q_flow = stT(id_eQ_flow(i),:) ; 
        e_Q_flow_lags = stT(id_eQ_flow_lags(i),:) ; 
        temp = (e_Q_flow*e_Q_flow' + sum(PtT(id_eQ_flow(i),id_eQ_flow(i),:),3)) - ...
                params.rhoQ_flow(i,1) * (e_Q_flow*e_Q_flow_lags' + sum(PtT(id_eQ_flow(i),id_eQ_flow_lags(i),:),3)); 
        params.SigQ_flow(i,1) = 1/options.Nt * temp ; 
    end
else
    id_Nq_flow = options.Nmx+options.Nmz+1:options.Nmx+options.Nmz+options.Nq_flow ; 
    Zq_flow = [kron([1 2 3 2 1],params.lambdaQ_flow) kron([1 2 3 2 1],eye(options.Nq_flow))];
    temp = zeros(options.Nq_flow) ; 
    for t = 1 : options.Nt 
        datatemp = data(id_Nq_flow,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ;   
        temp = temp + Wt*(datatemp*datatemp')*Wt' - Wt*datatemp*stT(:,t)'*Zq_flow'*Wt - ...
               Wt*Zq_flow*stT(:,t)*datatemp' + ...
               Wt*Zq_flow * (stT(:,t)*stT(:,t)' + PtT(:,:,t)) * Zq_flow' * Wt + ...
               (eye(options.Nq_flow) - Wt) * diag(params.SigQ_flow) * (eye(options.Nq_flow) - Wt) ; 
    end
    params.SigQ_flow = diag(1/options.Nt * temp) ;
    params.rhoMx = [] ; 
end


