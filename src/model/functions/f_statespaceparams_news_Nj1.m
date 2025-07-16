function [T, Z, R, Q, H] = f_statespaceparams_news_Nj1(params,Nr,Np,Nm,Nq,maxcorr)
% state vector is [factors_t u^Q_t u^M_t factors_t-1 u^Q_t-1 .... factors_t-4 u^Q_t-4]

Ns = 5*(Nr+Nq)+Nm ; 
phi_temp = [] ; 
for p = 1 : Np
    if p == 1 
        phi_temp = [phi_temp params.A(1:Nr,(p-1)*Nr+1:p*Nr) zeros(Nr,Nq+Nm)] ;
    else
        phi_temp = [phi_temp params.A(1:Nr,(p-1)*Nr+1:p*Nr) zeros(Nr,Nq)] ;
    end
end 

phi_temp = [phi_temp; 
            zeros(Nq,Nr) diag(params.rhoQ_flow) zeros(Nq,Nm) zeros(Nq,(Np-1)*(Nq+Nr));
            zeros(Nm,Nr+Nq) diag(params.rhoMx) zeros(Nm,(Np-1)*(Nq+Nr))] ;  

T = [phi_temp zeros(Nr+Nq+Nm,(5-Np)*((Nr+Nq)));
     eye(Ns - (Nr + Nq + Nm)) zeros(Ns -(Nr + Nq + Nm),Nr+Nq+Nm)] ; 

Q = zeros(Nr+Nq+Nm) ; 
Q(1:Nr,1:Nr) = params.Omeg ; 
Q(Nr+1:Nr+Nq,Nr+1:Nr+Nq) = diag(params.SigQ_flow) ; 
Q(Nr+Nq+1:Nr+Nq+Nm,Nr+Nq+1:Nr+Nq+Nm) = diag(params.SigMx) ; 

R = [eye(Nr+Nq+Nm) ; 
    zeros(4*(Nr+Nq),Nr+Nq+Nm)];

Z = [params.lambdaMx zeros(Nm,Nq) eye(Nm) zeros(Nm, 4*(Nr+Nq)) ;
     params.lambdaQ_flow eye(Nq) zeros(Nq,Nm) kron([2 3 2 1],[params.lambdaQ_flow eye(Nq)])]; 

kappa = 1e-10 ; 
H = kappa * eye(Nm+Nq) ;
%H(1:Nm,1:Nm) = diag(params.SigMx) ; 

