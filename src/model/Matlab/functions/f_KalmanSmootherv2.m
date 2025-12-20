function [stt,Ptt,sttminusone,Pttminusone,stT,PtT,news,K] = f_KalmanSmootherv2(data,T,Z,H,R,Q,s0,P0)

stt = NaN(size(T,1),size(data,2));
Ptt = NaN(size(T,1),size(T,1),size(data,2));
sttminusone = NaN(size(T,1),size(data,2));
Pttminusone = NaN(size(T,1),size(T,1),size(data,2));
K = zeros(size(T,1),size(data,1),size(data,2));
stT= NaN(size(T,1),size(data,2));
PtT = NaN(size(T,1),size(T,1),size(data,2));
news = zeros(size(data,1),size(data,2)) ;

for t=1:size(data,2)
    % predict!
    if t==1
        sttminusone(:,t) = T*s0;
        Pttminusone(:,:,t) = T*P0*T' + R*Q*R';
    else
        sttminusone(:,t) = T*stt(:,t-1);
        Pttminusone(:,:,t) = T*Ptt(:,:,t-1)*T' + R*Q*R';
    end

    % update!
    missing = isnan(data(:,t)) ; 
    W = eye(size(data,1)) ; 
    W = W(~missing,:) ;
    WZ = W*Z ; 
    datatemp = data(:,t) ; 
    datatemp = datatemp(~missing) ; 
    v = datatemp - WZ*sttminusone(:,t) ;
    news(~missing,t) = v ;  
    K(:,~missing,t) = Pttminusone(:,:,t)*WZ'/(WZ*Pttminusone(:,:,t)*WZ'+ W*H*W');
    stt(:,t) = sttminusone(:,t) + K(:,~missing,t)*v;
    Ptt(:,:,t) = (eye(size(T,1))-K(:,~missing,t)*WZ)*Pttminusone(:,:,t); 
end 

stT(:,end) = stt(:,end);
PtT(:,:,end) = Ptt(:,:,end);

for t=size(data,2)-1:-1:1
    J = (Ptt(:,:,t)*T')/(Pttminusone(:,:,t+1) + eye(size(T,1)) * 1e-12);
    stT(:,t) = stt(:,t) + J*(stT(:,t+1)-sttminusone(:,t+1));
    PtT(:,:,t) = Ptt(:,:,t) + J*(PtT(:,:,t+1) - Pttminusone(:,:,t+1) )*J'; 
end

