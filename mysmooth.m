function [rx, Px, Pxy] = mysmooth(x,hx,bP,P,F,H,KT)

leng = size(x,2);
rx = zeros(4,leng);
rx(:,leng) = x(:,leng);
tPx = zeros(4,4,leng);
tPx(:,:,leng) = P(:,:,leng);
tPxy = zeros(4,4,leng);
tPxy2 = zeros(4,4,leng);
for i = (leng-1):-1:1
    C = P(:,:,i)*F'*bP(:,:,i+1)^(-1);
    rx(:,i) = x(:,i)+C*(rx(:,i+1)-hx(:,i+1));
    tPx(:,:,i) = P(:,:,i)+C*(tPx(:,:,i+1)-bP(:,:,i+1))*C';
    tPxy(:,:,i+1) = tPx(:,:,i+1)*C';
end
Px = zeros(4,4,leng);
Pxy = zeros(4,4,leng);
for i = leng:-1:1
    Px(:,:,i) = tPx(:,:,i)+rx(:,i)*rx(:,i)';
    if i < leng
        Pxy(:,:,i) = tPx(:,:,i)+rx(:,i+1)*rx(:,i)';
    end
end

