function yQ_m = f_interpolateyQ(yQ)

R = [1; 0 ; 0 ] ; 
H = 0 ;
T = [1 0 0; 1 0 0; 0 1 0] ; 
Z = 1/3 * ones(1,size(T,1)) ; 
s0 = zeros(size(T,1),1) ; 
P0 = 10 * eye(size(T,1)) ; 

for i = 1 : size(yQ,1) 
    Q = 1/3 * nanvar(yQ(i,:)) ; 
    [stT,~,~] = f_KS_DK_logL(yQ(i,:),T,Z,H,R,Q,s0,P0) ;
    yQ_m(i,:) = stT(1,:) ; 
end



