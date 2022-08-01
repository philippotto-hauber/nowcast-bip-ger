function [T, Z, R, Q, H] = f_statespaceparams_news(params,Nr,Nm,Nq,maxcorr)


Ns = 5*(Nr+Nq) ; 
%maxcorr = max([abs(max(tjs) - min(tks)),abs(min(tjs) - max(tks)),abs(max(tjs) - min(tjs))]) ; 
phitemp = zeros(Nr+Nq) ; 
phitemp(1:Nr,1:Nr) = params.A ; 

T = [phitemp zeros(Nr+Nq,4*(Nr+Nq)) zeros(Nr+Nq,maxcorr*(Nr + Nq));
    eye(Ns + (maxcorr-1)*(Nr + Nq)) zeros(Ns + (maxcorr-1)*(Nr + Nq),Nr+Nq)] ; 

Q = zeros(Nr+Nq) ; 
Q(1:Nr,1:Nr) = params.Omeg ; 
Q(Nr+1:Nr+Nq,Nr+1:Nr+Nq) = diag(params.SigQ_flow) ; 

R = [eye(Nr+Nq) ; 
    zeros(4*(Nr+Nq),Nr+Nq)
    zeros(maxcorr*(Nr + Nq),Nr+Nq)];

RQR = R*Q*R' ;

Z = [params.lambdaMx zeros(Nm,Nq) zeros(Nm, 4*(Nr+Nq)) zeros(Nm, maxcorr*(Nr + Nq)) ;
    kron([1 2 3 2 1],[params.lambdaQ_flow eye(Nq)]) zeros(Nq, maxcorr*(Nr + Nq))]; 

H = zeros(Nm+Nq) ; 
H(1:Nm,1:Nm) = diag(params.SigMx) ; 

