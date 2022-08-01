function params = f_Mstep_lambdaMz(stT,PtT,data,params,options)

% --------------------------------------------------
% - extract a few things and define identifiers
% --------------------------------------------------
id_Nmz = options.Nmx+1:options.Nmx+options.Nmz ; 
id_f = 1:options.Npmax*options.Nr ; 
f = stT(id_f,:) ; 

if options.Nj>0
    id_eMz = options.Nr*options.Npmax + (options.Nj+1)*options.Nmx + 1 : options.Nr*options.Npmax + (options.Nj+1)*options.Nmx + options.Nmz ;
    e_Mz = stT(id_eMz,:) ; 
end

% --------------------------------------------------
% - lambdaMz
% --------------------------------------------------
denom = zeros(12*options.Nr*options.Nmz,12*options.Nr*options.Nmz) ; 
numer = zeros(options.Nmz,12*options.Nr) ;
f_f_R = zeros(12*options.Nr*options.Nmz,12*options.Nr*options.Nmz) ; 

if options.Nj>0
    for t = 1 : options.Nt 
        datatemp = data(id_Nmz,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ; 
        denom = denom + kron( f(:,t) * f(:,t)' + PtT(id_f,id_f,t) , Wt) ; 
        f_f_R = f_f_R + kron( f(:,t) * f(:,t)' + PtT(id_f,id_f,t) , diag(params.SigMz) ) ;
        numer = numer + Wt*datatemp * f(:,t)'  - (Wt*e_Mz(:,t)*f(:,t)' + PtT(id_eMz,id_f,t)) ;  
    end 
else
    for t = 1 : options.Nt 
        datatemp = data(id_Nmz,t) ; 
        Wt = diag(~isnan(datatemp)) ;
        datatemp(isnan(datatemp)) = 0 ; 
        denom = denom + kron( f(:,t) * f(:,t)' + PtT(id_f,id_f,t) , Wt) ; 
        f_f_R = f_f_R + kron( f(:,t) * f(:,t)' + PtT(id_f,id_f,t) , diag(params.SigMz) ) ;
        numer = numer + Wt*datatemp * f(:,t)' ;
    end
end

vec_lambdaMz_u = denom\numer(:) ; 

% --------------------------------------------------
% - impose restrictions
% --------------------------------------------------

H_lam = kron( [eye(options.Nmz) -eye(options.Nmz) zeros(options.Nmz,10*options.Nmz); 
               eye(options.Nmz) zeros(options.Nmz,1*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,9*options.Nmz);
               eye(options.Nmz) zeros(options.Nmz,2*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,8*options.Nmz);
               eye(options.Nmz) zeros(options.Nmz,3*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,7*options.Nmz);
               eye(options.Nmz) zeros(options.Nmz,4*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,6*options.Nmz);
               eye(options.Nmz) zeros(options.Nmz,5*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,5*options.Nmz);
               eye(options.Nmz) zeros(options.Nmz,6*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,4*options.Nmz); 
               eye(options.Nmz) zeros(options.Nmz,7*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,3*options.Nmz);
               eye(options.Nmz) zeros(options.Nmz,8*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,2*options.Nmz); 
               eye(options.Nmz) zeros(options.Nmz,9*options.Nmz) -eye(options.Nmz) zeros(options.Nmz,1*options.Nmz); 
               eye(options.Nmz) zeros(options.Nmz,10*options.Nmz) -eye(options.Nmz)] , eye(options.Nr)) ;  


kappa_lam = zeros(size(H_lam,1),1) ; 
vec_lambdaMz_r = vec_lambdaMz_u + f_f_R * H_lam' * inv(H_lam*f_f_R*H_lam')*(kappa_lam - H_lam*vec_lambdaMz_u) ; 

lambdaMz_temp = reshape(vec_lambdaMz_r,options.Nmz,options.Nr*12) ; 

params.lambdaMz = lambdaMz_temp(:,1:options.Nr) ; 

