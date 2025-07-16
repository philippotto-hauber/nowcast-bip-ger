function params = f_EMalgorithm(data_m,data_q,options)

% ----------------------------------------------------------------------- %
% - specify some more options
% ----------------------------------------------------------------------- %

options.Nq_flow = size(data_q,1) ; 
options.Nmx = size(data_m,1) ; 
options.Nmz = 0 ; 
options.Nq_stock = 0 ;      
options.Nm = options.Nmx + options.Nmz ;
options.Nq = options.Nq_flow + options.Nq_stock ; 
options.Nt = size(data_m,2) ; 
% ----------------------------------------------------------------------- %
% - calculate a few additional options
% ----------------------------------------------------------------------- %
if options.Nmz>0 
    options.Npmax = max(12,options.Np+1) ; % => need lagged factors in state as well for A's M-step!!!!! 
elseif options.Nq_flow >0
    options.Npmax = max(5,options.Np+1) ; 
else
    options.Npmax = max(3,options.Np+1) ; 
end

if options.Nj>0
    options.Nstates =  options.Npmax * (options.Nr) + 5 * options.Nq + (options.Nj+1)*(options.Nmx + options.Nmz) ; 
else
    options.Nstates =  options.Npmax * (options.Nr) + 5 * options.Nq ; 
end

% ----------------------------------------------------------------------- %
% - starting values
% ----------------------------------------------------------------------- %
data_mx = data_m ; 
data_mz = [] ; 
data_q_flow = data_q ; 
data = [data_mx;data_mz; data_q_flow] ; 
params = f_startingvalues(data_mx,data_mz,data_q_flow,options) ;

% ----------------------------------------------------------------------- %
% - EM algorithm
% ----------------------------------------------------------------------- %

maxiter = 100 ; 
iter = 0 ; 
LL_prev = -999999 ; 
%tic
for iter = 1 : maxiter 
    % ------------------------------------------------------------------- %
    % - E-Step ---------------------------------------------------------- %
    % ------------------------------------------------------------------- %

    % - state space formulation
    % ---------------------------
    [T, Z, R, Q, H] = f_statespaceparamsEM(params,options) ;

    % - Kalman Smoother
    % ---------------------------    
    s0 = zeros(size(T,1),1) ; 
    P0 = 1 * eye(size(T,1)) ; 
    [stT,PtT,LL] = f_KS_DK_logL(data,T,Z,H,R,Q,s0,P0) ;
    
    % - check convergence
    % ---------------------------  
    cLL = (LL - LL_prev)/(abs(LL)/2 + abs(LL_prev)/2) ; 
    if iter>1 && cLL < 1e-03; break; end    
    LL_prev = LL ; 

    % ------------------------------------------------------------------- %
    % - M-Step ---------------------------------------------------------- %
    % ------------------------------------------------------------------- %

    % - A & Omeg
    % ------------------
    params = f_Mstep_A_Omeg(stT,PtT,params,options) ;

    % - lambdaMx
    % ------------------
    params = f_Mstep_lambdaMx(stT,PtT,data,params,options) ;

    % - rhoMx & SigMx
    % ------------------
    params = f_Mstep_rhoMx_SigMx(stT,PtT,data,params,options) ;

    if options.Nq_flow>0    
        % - lambdaQ_flow
        % ------------------
        params = f_Mstep_lambdaQ_flow(stT,PtT,data,params,options) ;

        % - rhoQ_flow & SigQ_flow
        % ------------------
        params = f_Mstep_rhoQ_flow_SigQ_flow_v2(data,stT,PtT,params,options) ;
    end

    if options.Nmz>0
        % - lambdaMz
        % ------------------
        params = f_Mstep_lambdaMz(stT,PtT,data,params,options) ;

        % - rhoMz & SigMz
        % ------------------
        params = f_Mstep_rhoMz_SigMz(stT,PtT,data,params,options) ;
    end
end
if iter == maxiter
    disp('% ------------------------------------------------ %')
    disp(['% EM algorithm failed to converge after ' num2str(iter) ' iterations'])
    disp('% ------------------------------------------------ %')
else    
    disp('% ------------------------------------------------ %')
    disp(['% EM algorithm converged after ' num2str(iter) ' iterations'])
    disp('% ------------------------------------------------ %')
end
