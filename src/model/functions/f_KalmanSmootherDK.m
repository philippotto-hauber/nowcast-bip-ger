function ks_output = f_KalmanSmootherDK(data,T,Z,H,R,Q,s0,P0)

% empty matrices to store filtered and smoothed states (as well as their
% respective covariance matrices)
stT = NaN(size(T,1),size(data,2));
PtT = NaN(size(T,1),size(T,1),size(data,2));
a = NaN(size(T,1),size(data,2)+1);
P = NaN(size(T,1),size(T,1),size(data,2)+1);

% -------------------------------- %
% -- forward recursions ---------- %
% -------------------------------- %

% empty cells to store v, F and L
iF = cell(size(data,2),1);
L = NaN(size(T,1),size(T,1),size(data,2));
v = cell(size(data,2),1);

% initialise filter
a(:,1) = s0;
P(:,:,1) = P0;
eye_N = eye(size(data,1)) ;

for t=1:size(data,2)   
    % check for missings 
    missing = isnan(data(:,t)) ;      
    W = eye_N(~missing,:) ;
    WZ = W*Z ; 
    datatemp = data(~missing,t) ; 

    % proceed with recursions
    v{t} = datatemp - WZ*a(:,t);
    F = WZ*P(:,:,t)*WZ' + W*H*W';
    iF{t} = eye(size(F, 1))/(F+eye(size(datatemp,1))*1e-5);
    K = T*P(:,:,t)*WZ' * iF{t};
    L(:,:,t) = T - K*WZ;
    
    % store stt and Ptt (Durbin and Koopman, 2001, p. 68)
    %stt(:,t) = a(:,t) + P(:,:,t)*Z'/F(:,:,t)*v(:,t);
    %Ptt(:,:,t) = P(:,:,t) - P(:,:,t)*Z'/F(:,:,t)*Z*P(:,:,t)';
    
    % update state vector and its covariance matrix
    a(:,t+1) = T*a(:,t) + K*v{ t };
    P(:,:,t+1) = T*P(:,:,t)*L(:,:,t)' + R*Q*R'; 
end

% -------------------------------- %
% -- backward recursions --------- %
% -------------------------------- %
r = zeros(size(T,1),1);
N = NaN(size(T,1),size(T,1),size(data,2)+1);
N(:,:,end) = zeros(size(T,1)) ; 

for t=size(data,2):-1:1   
    % check for missings 
    missing = isnan(data(:,t)) ; 
    W = eye_N(~missing,:) ;
    WZ = W*Z ; 
    
    % compute r
    if isempty(WZ) % all obs are missing => nothing to smooth!
        r = zeros(size(T, 1), 1); 
        stT(:,t) = a(:,t) + P(:,:,t)*r;
        N(:,:,t) = L(:,:,t)'*N(:,:,t+1)*L(:,:,t);
        PtT(:,:,t) = P(:,:,t);
    else
        r = WZ'*iF{t} * v{t} + L(:,:,t)'*r;
        stT(:,t) = a(:,t) + P(:,:,t)*r;
        N(:,:,t) = WZ'*iF{t}*WZ + L(:,:,t)'*N(:,:,t+1)*L(:,:,t);
        PtT(:,:,t) = P(:,:,t) - P(:,:,t)*N(:,:,t)*P(:,:,t);
    end
end

% -------------------------------- %
% -- store output ---------------- %
% -------------------------------- %

ks_output.stT = stT ; 
ks_output.PtT = PtT ; 
ks_output.P = P ; 
ks_output.L = L ; 
ks_output.N = N ; 






