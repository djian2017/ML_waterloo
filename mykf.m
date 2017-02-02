function [x,hx,obP,oP,KT,loglik]= mykf(y,F,b,H,Q,R,P,x0)
  x(:,1) = x0;
  leng = size(y,2);
  obP = zeros(4,4,leng-1);
  oP = zeros(4,4,leng);
  hx = zeros(4,leng);
  oP(:,:,1) = P;
  loglik = 0;
for i = 1:leng
    if i >1
       hx(:,i) = F*x(:,i-1)+b;
       bP = F*P*F'+Q;
    else
       hx(:,i) = x0+b;
       bP = P;
    end
    obP(:,:,i) = bP;
    e = y(:,i)-H*hx(:,i);
    S = H*bP*H'+R;
    K = bP*H'*S^(-1);
    x(:,i) = hx(:,i)+K*e;
    P = (eye(4)-K*H)*bP;
    oP(:,:,i) = P;
    loglik = loglik - log((2*pi)^(2/2)*sqrt(abs(det(S))))-0.5*(e'*S^(-1)*e);
end
KT = K;