% M.Michalczuk 09.06.2018
% This is example of running 'cutout' function
clear all;
close all;
x=[0:0.005:5];
y=exp(-6*x).*sin(x*40)*6+exp(5*x)*5e-11.*sin(x*20);
figure(1)
for i=1:2
  a(i)=subplot(2,1,i);
  title('Before');
  plot(x,y,x,y+2,'o');
  grid on;
  title('Before');
  legend('a','a+2');
  xlim([0 5]);
end
drawnow;
pause(1);
cutout(a(2),1,4,0.2);
title('After');


