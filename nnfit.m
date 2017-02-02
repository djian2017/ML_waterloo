clear;

% loading data
data=csvread('projectiles.csv');
new=cell(99); 
init=zeros(99,2);
coefs=zeros(99,6);
l=length(data);
k=0;
for(i=1:l)
    if(data(i,1)==0)
        k=k+1;
        new{k}=[new{k};data(i,2:3)];
    else
        new{k}=[new{k};data(i,2:3)];
    end
end

 % fitting to second order polynomial 
for i=1:99
    dat=new{i};
    init(i,:)=dat(2,:);
    x=dat(:,1);
    y=dat(:,2);
    if(length(x)>2)
    mod1=fit([1:length(x)]',x,'poly2');
    mod2=fit([1:length(x)]',y,'poly2');
    coefs(i,:)=[mod1.p1,mod1.p2,mod1.p3,mod2.p1,mod2.p2,mod2.p3];
    else
    x=[x;x(end)*2];
    y=[y;0];
    mod1=fit([1:length(x)]',x,'poly2');
    mod2=fit([1:length(x)]',y,'poly2');
    coefs(i,:)=[mod1.p1,mod1.p2,mod1.p3,mod2.p1,mod2.p2,mod2.p3];
    end
end

% neural network training
inputs = init';
targets = coefs';

% Create a Fitting Network
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize);


% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
net.trainParam.showWindow=0;

% Train the Network
[net,tr] = train(net,inputs,targets);

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);

% test set
testTargets = targets  .* tr.testMask{1};

% mean square error of test set
testPerformance = perform(net,testTargets,outputs);
% residual plot of the whole data
figure, plotregression(targets,outputs);

% plot the result with initial 
st = [0.707106781187 ;0.658106781187]; 
% prediction from the trained network
re = net(st);
len = 99;
t = 1:(len+1);
x = re(1)*t.^2+re(2)*t+re(3);
y = re(4)*t.^2+re(5)*t+re(6);
% find the hitting time
if y(end) < 0
list = find(y<0);
if list(1) == 1
    slen = list(2)-1;
else
    slen = list(1)-1;
end
else
    slen = len;
end
exact = zeros(2,slen);
exact(:,1) = [0 ;0];
exact(:,2) = st;
for i = 2:(slen-1)
    exact(:,i+1) = [2 0;0 2]*exact(:,i)-[1 0; 0 1]*exact(:,i-1)+[0;-0.098];
end
figure, plot(x(1:slen),y(1:slen),exact(1,:),exact(2,:));
legend('prediction','exact');
xlabel('x');ylabel('y');

% write  file 
csvwrite('trajouput.csv',[x',y']);
