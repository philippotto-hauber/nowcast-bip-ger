function [T, Z, R, Q, H] = f_statespaceparams_news(params,options)

if options.Nj == 0
    % -------------------------------- %    
    % state vector is [factors_t
    %                  u^Q_t
    %                  factors_t-1
    %                  u^Q_t-1
    %                  ...
    %                  factors_t-4
    %                  u^Q_t-4]
    % -------------------------------- %

    phi_temp = [] ; 
    for p = 1 : options.Np
        phi_temp = [phi_temp params.A(1:options.Nr,(p-1)*options.Nr+1:p*options.Nr) zeros(options.Nr,options.Nq)] ;
    end 

    phi_temp = [phi_temp; zeros(options.Nq,(options.Nr+options.Nq)*options.Np)] ; 

    T = [phi_temp zeros(options.Nr+options.Nq,(5-options.Np)*(options.Nr+options.Nq)) ;
        eye(4*(options.Nr+options.Nq)) zeros(4*(options.Nr+options.Nq),options.Nr+options.Nq)] ; 

    Q = zeros(options.Nr+options.Nq) ; 
    Q(1:options.Nr,1:options.Nr) = params.Omeg ; 
    Q(options.Nr+1:options.Nr+options.Nq,options.Nr+1:options.Nr+options.Nq) = diag(params.SigQ_flow) ; 

    R = [eye(options.Nr+options.Nq) ; 
        zeros(4*(options.Nr+options.Nq),options.Nr+options.Nq)] ; 

    Z = [params.lambdaMx zeros(options.Nm,options.Nq) zeros(options.Nm, 4*(options.Nr+options.Nq)) ;
        kron([1 2 3 2 1],[params.lambdaQ_flow eye(options.Nq)])]; 
    
    kappa = 1e-14 ; 
    %H = zeros(options.Nm+options.Nq) ; 
    H = kappa * eye(options.Nm+options.Nq) ; 
    H(1:options.Nm,1:options.Nm) = diag(params.SigMx) ; 
else
    if options.Nj>1
        disp('code currently only supports Nj=1. Should crash....')
    end
    
    % -------------------------------- %    
    % state vector is [factors_t
    %                  u^Q_t
    %                  u^M_t
    %                  factors_t-1
    %                  u^Q_t-1
    %                  ...
    %                  factors_t-4
    %                  u^Q_t-4]
    % -------------------------------- %

    phi_temp = [] ; 
    for p = 1 : options.Np
        if p == 1 
            phi_temp = [phi_temp params.A(1:options.Nr,(p-1)*options.Nr+1:p*options.Nr) zeros(options.Nr,options.Nq+options.Nm)] ;
        else
            phi_temp = [phi_temp params.A(1:options.Nr,(p-1)*options.Nr+1:p*options.Nr) zeros(options.Nr,options.Nq)] ;
        end
    end 

    phi_temp = [phi_temp; 
                zeros(options.Nq,options.Nr) diag(params.rhoQ_flow) zeros(options.Nq,options.Nm) zeros(options.Nq,(options.Np-1)*(options.Nq+options.Nr));
                zeros(options.Nm,options.Nr+options.Nq) diag(params.rhoMx) zeros(options.Nm,(options.Np-1)*(options.Nq+options.Nr))] ;  

%     T = [phi_temp zeros(options.Nr+options.Nq+options.Nm,(5-options.Np)*((options.Nr+options.Nq)));
%          eye(options.Ns - (options.Nr + options.Nq + options.Nm)) zeros(options.Ns -(options.Nr + options.Nq + options.Nm),options.Nr+options.Nq+options.Nm)] ; 
%     
%     T1 = [phi_temp zeros(options.Nr+options.Nq+options.Nm,(5-options.Np)*((options.Nr+options.Nq)))];
%     T2 =  [eye(options.Ns - (options.Nr + options.Nq + options.Nm)) zeros(options.Ns -(options.Nr + options.Nq + options.Nm),options.Nr+options.Nq+options.Nm)] ; 
%     T2(options.Nr+options.Nq+1:options.Nq+options.Nr+options.Nm,:) = 0 ; 
%     T = [T1; T2] ; 
    
    T = [phi_temp zeros(options.Nr+options.Nq+options.Nm,(5-options.Np)*((options.Nr+options.Nq))) ;
        eye(options.Nr+options.Nq) zeros(options.Nr+options.Nq,options.Ns-(options.Nr+options.Nq)) ; 
        zeros(3*(options.Nr+options.Nq),options.Nr+options.Nq+options.Nm) eye(3*(options.Nr+options.Nq)) zeros(3*(options.Nr+options.Nq),options.Nr+options.Nq)] ; 
    
     
    Q = zeros(options.Nr+options.Nq+options.Nm) ; 
    Q(1:options.Nr,1:options.Nr) = params.Omeg ; 
    Q(options.Nr+1:options.Nr+options.Nq,options.Nr+1:options.Nr+options.Nq) = diag(params.SigQ_flow) ; 
    Q(options.Nr+options.Nq+1:options.Nr+options.Nq+options.Nm,options.Nr+options.Nq+1:options.Nr+options.Nq+options.Nm) = diag(params.SigMx) ; 

    R = [eye(options.Nr+options.Nq+options.Nm) ; 
        zeros(4*(options.Nr+options.Nq),options.Nr+options.Nq+options.Nm)];

    Z = [params.lambdaMx zeros(options.Nm,options.Nq) eye(options.Nm) zeros(options.Nm, 4*(options.Nr+options.Nq)) ;
         params.lambdaQ_flow eye(options.Nq) zeros(options.Nq,options.Nm) kron([2 3 2 1],[params.lambdaQ_flow eye(options.Nq)])]; 

    kappa = 1e-08 ; 
    H = kappa * eye(options.Nm+options.Nq) ;    
end
    
    
