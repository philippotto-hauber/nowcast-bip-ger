function params = f_Mstep_rhoQ_flow_SigQ_flow(stT,PtT,params,options)

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
        params.rhoQ_Flow(i,1) = denom\numer ; 
    
        % SigMx
        e_Q_flow = stT(id_eQ_flow(i),:) ; 
        e_Q_flow_lags = stT(id_eQ_flow_lags(i),:) ; 
        temp = (e_Q_flow*e_Q_flow' + sum(PtT(id_eQ_flow(i),id_eQ_flow(i),:),3)) - ...
                params.rhoQ_flow(i,1) * (e_Q_flow*e_Q_flow_lags' + sum(PtT(id_eQ_flow(i),id_eQ_flow_lags(i),:),3)); 
        params.SigQ_flow(i,1) = 1/options.Nt * temp ; 
    end
else
    id_eQ_flow = options.Nr*options.Npmax + 1 : options.Nr*options.Npmax + options.Nq_flow ; 
    %Zq_flow = [kron([1 2 3 2 1],params.lambdaQ_flow) kron([1 2 3 2 1],eye(options.Nr))]; 
    e_Q_flow = stT(id_eQ_flow,:) ; 
    params.SigQ_flow = diag(1/options.Nt * (e_Q_flow*e_Q_flow' + sum(PtT(id_eQ_flow,id_eQ_flow,:),3))) ; 
    params.rhoQ_flow = [] ; 
end


