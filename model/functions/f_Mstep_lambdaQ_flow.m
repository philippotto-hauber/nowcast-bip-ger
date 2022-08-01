function params = f_Mstep_lambdaQ_flow(stT,PtT,data,params,options)

% --------------------------------------------------
% - extract a few things and define identifiers
% --------------------------------------------------

id_Nq_flow = options.Nmx + options.Nmz + 1 : options.Nmx + options.Nmz + options.Nq_flow ; 
id_f = 1:5*options.Nr ; 
f_lags = stT(id_f,:) ; 
if options.Nj>0
    if options.Nmz>0
        id_eQ_flow = options.Nr*options.Npmax + (options.Nj+1)*options.Nmx + (options.Nj+1)*options.Nmz + 1 : options.Nr*options.Npmax + (options.Nj+1)*options.Nmx + (options.Nj+1)*options.Nmz + options.Nq_flow ; 
    else
        id_eQ_flow = options.Nr*options.Npmax + (options.Nj+1)*options.Nmx + 1 : options.Nr*options.Npmax + (options.Nj+1)*options.Nmx + options.Nq_flow ; 
    end
    e_Q_flow = stT(id_eQ_flow,:) ; 
end

denom = zeros(5*options.Nr*options.Nq_flow,5*options.Nr*options.Nq_flow) ; 
numer = zeros(options.Nq_flow,5*options.Nr) ;
f_f_R = zeros(5*options.Nr*options.Nq_flow,5*options.Nr*options.Nq_flow) ; 

if options.Nj>0
    for t = 1 : options.Nt 
        datatemp = data(id_Nq_flow,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ; 
        denom = denom + kron( f_lags(:,t) * f_lags(:,t)' + PtT(id_f,id_f,t) , Wt) ; 
        f_f_R = f_f_R + kron( f_lags(:,t) * f_lags(:,t)' + PtT(id_f,id_f,t) , diag(params.SigQ_flow) ) ;
        numer = numer + Wt * datatemp * f_lags(:,t)' - (Wt*e_Q_flow(:,t)*f_lags(:,t)' + PtT(id_eQ_flow,id_f,t)) ; 
    end
else
    for t = 1 : options.Nt 
        datatemp = data(id_Nq_flow,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ; 
        denom = denom + kron( f_lags(:,t) * f_lags(:,t)' + PtT(id_f,id_f,t) , Wt) ; 
        f_f_R = f_f_R + kron( f_lags(:,t) * f_lags(:,t)' + PtT(id_f,id_f,t) , diag(params.SigQ_flow) ) ;
        numer = numer + Wt * datatemp * f_lags(:,t)' ;
    end
end

vec_lambdaQ_flow_u = denom\numer(:) ; 

% --------------------------------------------------
% - impose restrictions
% --------------------------------------------------

H_lam = kron( [2*eye(options.Nq_flow) -eye(options.Nq_flow) zeros(options.Nq_flow,3*options.Nq_flow); 
               3*eye(options.Nq_flow) zeros(options.Nq_flow,1*options.Nq_flow) -eye(options.Nq_flow) zeros(options.Nq_flow,2*options.Nq_flow);
               2*eye(options.Nq_flow) zeros(options.Nq_flow,2*options.Nq_flow) -eye(options.Nq_flow) zeros(options.Nq_flow,1*options.Nq_flow);
               eye(options.Nq_flow) zeros(options.Nq_flow,3*options.Nq_flow) -eye(options.Nq_flow)] , eye(options.Nr)) ; 

        
kappa_lam = zeros(size(H_lam,1),1) ; 

%vec_lambdaQ_flow_r = vec_lambdaQ_flow_u + f_f_R * H_lam' * inv(H_lam*f_f_R*H_lam')*(kappa_lam - H_lam*vec_lambdaQ_flow_u) ; 
vec_lambdaQ_flow_r = vec_lambdaQ_flow_u + (f_f_R\ H_lam' / (H_lam/f_f_R*H_lam'))*(kappa_lam - H_lam*vec_lambdaQ_flow_u) ; 

lambdaQ_flow_temp = reshape(vec_lambdaQ_flow_r,options.Nq_flow,options.Nr*5) ; 
params.lambdaQ_flow = lambdaQ_flow_temp(:,1:options.Nr) ; 

