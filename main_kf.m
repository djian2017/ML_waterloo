clear;
load projectiles.csv
data = projectiles;
M = 99;
data_size = max(data(:,1))+1;
data_length = length(data);
data2 = zeros(2,data_size,M);
sample_length = zeros(M,1);
i1 = 1; 
j = 1;
TOL = 10;
for i = 2:data_length
    if data(i,1) == 0
        i2 = i-1;
        data2(1,1:i2-i1+1,j) = data(i1:i2,2);
        data2(2,1:i2-i1+1,j) = data(i1:i2,3);
        sample_length(j) = i2-i1+1;
        i1 = i;
        j = j+1;
    end
end


dt = 0.1;
F = ones(4,4);
b = ones(4,1);
H = [1 0 0 0;
     0 1 0 0];
 Q = 0.001*eye(4);
 R = 0.001*eye(2);
 P = Q;

pl = -10^30; % a small number

for i = 1:200
  srx1 = zeros(4,1);
  srx2 = zeros(4,1);
  sPx = zeros(4,4);
  sPxy = zeros(4,4);
  sl = 0;
  tlik = 0;
   for j = 1:M
      if sample_length(j) >2  
        x0 = [data2(:,2,j);(data2(:,2,j)-data2(:,1,j))/1];
        % Kalman filter
        [x,hx,bP,tP,KT,pl1] = mykf(data2(:,3:sample_length(j),j),F,b,H,Q,R,P,x0);
        % RTS smoother
        [rx, Px, Pxy] = mysmooth(x,hx,bP,tP,F,H,KT);
        srx1 = srx1 + sum(rx(:,1:end-1),2);
        srx2 = srx2 + sum(rx(:,2:end),2);
        sPx = sPx + sum(Px(:,:,1:end-1),3);
        sPxy = sPxy + sum(Pxy,3);
        sl = sl + sample_length(j)-2;
        tlik = tlik+pl1;
      end
   end
   ll = tlik;
   %maximazation step
 tA = [sPx, srx1;
      srx1', sl];
 tB = [sPxy,srx2];
 Fb = tB*tA^(-1);
F = Fb(:,1:4); 
b =Fb(:,5);
if ll - pl <1
    break;
end
pl=ll
 end
st = [0.707106781187 ;0.658106781187]; 
plottest
 