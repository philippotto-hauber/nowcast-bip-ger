function params = f_Mstep_lambdaMx(stT,PtT,data,params,options)

% --------------------------------------------------
% - extract a few things and define identifiers
% --------------------------------------------------

id_Nmx = 1 : options.Nmx ;
id_eMx = options.Nr*options.Npmax + 1 : options.Nr*options.Npmax + options.Nmx ;
id_f = 1 : options.Nr ;  

f = stT(id_f,:) ; 

denom = zeros(options.Nr*options.Nmx,options.Nr*options.Nmx) ; 
numer = zeros(options.Nmx,options.Nr) ;

% -------------------------------------------------
% - lambdaMx
% -------------------------------------------------
if options.Nj>0
    e_Mx = stT(id_eMx,:) ; 
    for t = 1 : options.Nt 
        datatemp = data(id_Nmx,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ;  
        denom = denom + kron( f(:,t) * f(:,t)' + PtT(id_f,id_f,t) , Wt ) ; % see Watson and Engle (1982, eqn. 16) for the precise formula (sum of squared smoothed factors + smoothed covariance) 
        numer = numer + Wt*datatemp * f(:,t)' - (Wt*e_Mx(:,t)*f(:,t)' + PtT(id_eMx,id_f,t)) ;
    end    
else
    for t = 1 : options.Nt 
        datatemp = data(id_Nmx,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ;  
        denom = denom + kron( f(:,t) * f(:,t)' + PtT(id_f,id_f,t) , Wt ) ; % see Watson and Engle (1982, eqn. 16) for the precise formula (sum of squared smoothed factors + smoothed covariance) 
        numer = numer + Wt*datatemp * f(:,t)' ;
    end    
end

params.lambdaMx = reshape(denom\numer(:),options.Nmx,options.Nr) ; 
