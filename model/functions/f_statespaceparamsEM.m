function [T, Z, R, Q, H] = f_statespaceparamsEM(params,options)
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% - model is y_t = Z * a_t + e_t; e_t ~ N(0,H) 
% -          a_t = T * a_t + R*u_t; u_t ~ N(0,Q) 
% ----------------------------------------------------------------------- %
% - Case distinction:
% - If options.Nmz>0 => include 11 lags of the factors in state vector,
% - i.e. a_t = [f_t, ..., f_t-12, e^Q_t, ..., e^Q_t-4]
% - else a_t = [f_t, ..., f_t-4, e^Q_t, ..., e^Q_t-4] to allow for I(1)
% - flow variables such as GDP.
% - If options.Nj>0, then we also include e^x and e^z in
% - the state vector, i.e. a_t = [f_t, ..., f_t-12, e^x_t,...,e^x_t-(Nj+1),e^z_t,...,e^z_t-(Nj+1),e^Q_t, ..., e^Q_t-4]
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% - COMMENTS
% - 2018-5-5: currently only options.Np = 1 supported. Need to fix that. 
% - 2018-5-13: include e^x_t and e^x_t-1 in state vector if options.Nj=1 => need
% -            for estimation of rho 
% - 2018-05-15: change code to model XXXXXXXXXXXXXX
% ----------------------------------------------------------------------- %

% -------
% - Q ---
% -------
if options.Nj>0
    Q = zeros(options.Nr+options.Nmx+options.Nmz+options.Nq) ;
    Q(1:options.Nr,1:options.Nr) = params.Omeg ;
    Q(options.Nr+1:options.Nr+options.Nmx,options.Nr+1:options.Nr+options.Nmx) = diag(params.SigMx) ; 
    Q(options.Nr+options.Nmx+1:options.Nr+options.Nm,options.Nr+options.Nmx+1:options.Nr+options.Nm) = diag(params.SigMz) ; 
    Q(options.Nr+options.Nm+1:end,options.Nr+options.Nm+1:end) = [diag(params.SigQ_flow) zeros(options.Nq_flow,options.Nq_stock); zeros(options.Nq_stock,options.Nq_flow) diag(params.SigQ_stock)] ; 
else
    Q = zeros(options.Nr+options.Nq) ;
    Q(1:options.Nr,1:options.Nr) = params.Omeg ;
    Q(options.Nr+1:end,options.Nr+1:end) = [diag(params.SigQ_flow) zeros(options.Nq_flow,options.Nq_stock); zeros(options.Nq_stock,options.Nq_flow) diag(params.SigQ_stock)] ; 
end

% -------
% - R ---
% -------
if options.Nj>0
    R = zeros(options.Nstates,options.Nr+options.Nmx+options.Nmz+options.Nq) ; 
    R(1:options.Nr,1:options.Nr) = eye(options.Nr) ; 
    R(options.Npmax*options.Nr+1:options.Npmax*options.Nr+options.Nmx,options.Nr+1:options.Nr+options.Nmx) = eye(options.Nmx) ; 
    R(options.Npmax*options.Nr+(options.Nj+1)*options.Nmx+1:options.Npmax*options.Nr+(options.Nj+1)*options.Nmx + options.Nmz,options.Nr+options.Nmx+1:options.Nr+options.Nm) = eye(options.Nmz) ; 
    R(options.Npmax*options.Nr+(options.Nj+1)*(options.Nmx+options.Nmz)+1:options.Npmax*options.Nr+(options.Nj+1)*(options.Nmx+options.Nmz)+options.Nq,options.Nr+options.Nm+1:end) = eye(options.Nq) ; 
else
    R = zeros(options.Nstates,options.Nr+options.Nq) ; 
    R(1:options.Nr,1:options.Nr) = eye(options.Nr) ; 
    R(options.Npmax*options.Nr+1:options.Npmax*options.Nr+options.Nq,options.Nr+1:end) = eye(options.Nq) ; 
end

% -------
% - T ---
% -------

if options.Nj>0   
    Tr = [params.A zeros(options.Nr,options.Nstates-options.Nr*options.Np) ; 
          eye(options.Nr*(options.Npmax-1)) zeros(options.Nr*(options.Npmax-1),options.Nr) zeros(options.Nr*(options.Npmax-1),(options.Nj+1)*(options.Nmx + options.Nmz) + 5*options.Nq)] ;
  
    Tez_temp = [diag(params.rhoMz) zeros(options.Nmz,options.Nmz*options.Nj) ;
                eye(options.Nmz*options.Nj) zeros(options.Nmz*options.Nj,options.Nmz)] ;  

    Tez = [zeros((options.Nj+1)*options.Nmz,size(Tr,1)) zeros((options.Nj+1)*options.Nmz,(options.Nj+1)*options.Nmx) Tez_temp zeros((options.Nj+1)*options.Nmz,5*options.Nq)] ;  

    Teq_temp = [diag([params.rhoQ_flow;params.rhoQ_stock]) zeros(options.Nq,options.Nq*4) ;
                eye(4*options.Nq) zeros(4*options.Nq,options.Nq)] ; 
            
    Teq = [zeros(5*options.Nq,options.Nstates - 5*options.Nq) Teq_temp ] ; 
    
    Tex = [zeros(options.Nmx,size(Tr,1)) diag(params.rhoMx) zeros(options.Nmx,options.Nj*options.Nmx) zeros(options.Nmx,options.Nstates-(size(Tr,1)+ (options.Nj+1)*options.Nmx));
           zeros(options.Nj*options.Nmx,size(Tr,1)) eye(options.Nj*options.Nmx) zeros(options.Nj*options.Nmx,options.Nmx) zeros(options.Nj*options.Nmx,options.Nstates-(size(Tr,1) + (options.Nj+1)*options.Nmx))] ; 
    
    T = [Tr ; Tex; Tez ; Teq ] ; 

else
    Tr = [params.A zeros(options.Nr,options.Nstates-options.Nr*options.Np) ; 
          eye(options.Nr*(options.Npmax-1)) zeros(options.Nr*(options.Npmax-1),options.Nr) zeros(options.Nr*(options.Npmax-1), 5*options.Nq)] ;

      Teq_temp = [zeros(options.Nq) zeros(options.Nq,options.Nq*4) ;
                eye(4*options.Nq) zeros(4*options.Nq,options.Nq)] ;  
            
    Teq = [zeros(5*options.Nq,options.Nstates - 5*options.Nq) Teq_temp ] ;    
    
    T = [Tr ;  Teq ] ; 
end

% -------
% - Z ---
% -------

if options.Nj>0
    Zmx = [params.lambdaMx zeros(options.Nmx,(options.Npmax-1)*options.Nr) eye(options.Nmx) zeros(options.Nmx,options.Nj*options.Nmx) zeros(options.Nmx,options.Nstates-options.Npmax*options.Nr-(options.Nj+1)*options.Nmx)] ; 
    Zmz = [kron(ones(1,12),params.lambdaMz) zeros(options.Nmz,(options.Nj+1)*options.Nmx) eye(options.Nmz) zeros(options.Nmz,options.Nstates-12*(options.Nr) -(options.Nj+1)*options.Nmx - options.Nmz)] ;
    %Zq_flow = [kron([1/3 2/3 3/3 2/3 1/3],params.lambdaQ_flow) zeros(options.Nq_flow,options.Npmax*options.Nr +(options.Nj+1)*(options.Nmx+options.Nmz)-5*options.Nr) kron([1/3 2/3 3/3 2/3 1/3],[eye(options.Nq_flow) zeros(options.Nq_flow,options.Nq_stock)])] ; 
    Zq_flow = [kron([1 2 3 2 1],params.lambdaQ_flow) zeros(options.Nq_flow,options.Npmax*options.Nr +(options.Nj+1)*(options.Nmx+options.Nmz)-5*options.Nr) kron([1 2 3 2 1],[eye(options.Nq_flow) zeros(options.Nq_flow,options.Nq_stock)])] ; 
    %Zq_stock = [kron([1 1 1],params.lambdaQ_stock) zeros(options.Nq_stock,options.Npmax*(options.Nr+options.Nmz)+(options.Nj+1)*options.Nmx-3*options.Nr) kron([1 1 1],[zeros(options.Nq_stock,options.Nq_flow) eye(options.Nq_stock)]) zeros(options.Nq_stock,5*options.Nq - 3*options.Nq)] ;

    
    %Z = [Zmx; Zmz; Zq_flow; Zq_stock] ;  
    if options.Nmz == 0 
        Z = [Zmx;Zq_flow] ; 
    else
        Z = [Zmx;Zmz;Zq_flow] ; 
    end
else
    Zmx = [params.lambdaMx zeros(options.Nmx,options.Nstates-options.Nr)] ; 
    Zmz = [kron(ones(1,12),params.lambdaMz) zeros(options.Nmz,options.Nstates-12*options.Nr)] ;
    %Zq_flow = [kron([1/3 2/3 3/3 2/3 1/3],params.lambdaQ_flow) zeros(options.Nq_flow,(options.Npmax-5)*options.Nr) kron([1/3 2/3 3/3 2/3 1/3],[eye(options.Nq_flow) zeros(options.Nq_flow,options.Nq_stock)])] ; 
    Zq_flow = [kron([1 2 3 2 1],params.lambdaQ_flow) zeros(options.Nq_flow,(options.Npmax-5)*options.Nr) kron([1 2 3 2 1],[eye(options.Nq_flow) zeros(options.Nq_flow,options.Nq_stock)])] ; 
    %Zq_stock = [kron([1 1 1],params.lambdaQ_stock) zeros(options.Nq_stock,options.Npmax*(options.Nr+options.Nmz)-3*options.Nr) kron([1 1 1],[zeros(options.Nq_stock,options.Nq_flow) eye(options.Nq_stock)]) zeros(options.Nq_stock,5*options.Nq - 3*options.Nq)] ;

    %Z = [Zmx; Zmz; Zq_flow; Zq_stock] ; 
    if options.Nmz == 0 
        Z = [Zmx;Zq_flow] ; 
    else
        Z = [Zmx;Zmz;Zq_flow] ; 
    end
end

% -------
% - H ---
% -------

kappa = 1e-8 ; 
if options.Nj>0
    H = diag(kappa*ones(options.Nm+options.Nq,1)) ; 
else
    H = diag([params.SigMx; params.SigMz; kappa*ones(options.Nq,1)]) ; 
end
