
l = 14;
test = zeros(4,l);
exact = zeros(2,l+1);

test(:,1) = [st;st];
exact(:,1) = [0 ;0];
exact(:,2) = st;
for i = 2:l
    exact(:,i+1) = [2 0;0 2]*exact(:,i)-[1 0; 0 1]*exact(:,i-1)+[0;-0.098];
    test(:,i) = F*test(:,i-1)+b;
end
figure 
plot([0 test(1,:)],[0 test(2,:)],exact(1,:),exact(2,:));
legend('prediction','exact');
xlabel('x');ylabel('y');
%plot(exact(1,:),exact(2,:),test(1,:),test(2,:))