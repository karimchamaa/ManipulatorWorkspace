clear;%Clear the screen, delete the variables and close all plots.
%close all;
clc;
StepSize = input('StepSize(0-360):');% Step size between min and max
q = sym('q%d', [1000 1]);%Symbols for joint variables up to 10K elements
Index=[1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1];

%Ask the user to input DH-Table
display('Insert the DH Table in a matrix form using only 1 variable in the form q(Link#); Angle(0-360deg)');
prompt = 'ai Alphai di Thetai\n';
table = input(prompt);

% Ask the user For constraints
Min= zeros(1,size(table,1));%Preallocate for faster computation
Max= zeros(1,size(table,1));
for i=1:size(table,1)
    Min(i) = input(['Min q(',num2str(i),')=']) ;
    Max(i) = input(['Max q(',num2str(i),')=']);
end

% Transform Angle to radiant in the table
for i=1:size(table,1)
  table(i,2)=deg2rad(eval(table(i,2)));% Since alpha is always constant
  if(table(i,4)~=q(i))% In case it's a prismatic joint 
  table(i,4)=deg2rad(eval(table(i,4)));
  end  
end

% Get A1,A2...An
A=sym('a',[4,4,size(table,1)]);%Preallocate for faster computation
for i=1:size(table,1)
A(:,:,i)=[cos(table(i,4)) -sin(table(i,4))*cos(table(i,2)) sin(table(i,4))*sin(table(i,2)) table(i,1)*cos(table(i,4))
sin(table(i,4)) cos(table(i,4))*cos(table(i,2)) -cos(table(i,4))*sin(table(i,2)) table(i,1)*sin(table(i,4))
0 sin(table(i,2)) cos(table(i,2)) table(i,3)
0 0 0 1];%DH Matrix
end

%Homogenous Transform Matrix
ZBase=sym('zbase',[4,4,size(table,1)]);%Preallocate for faster computation
 for i=1:size(table,1)
      H=Index*A(:,:,i);
      Index=H;
      ZBase(:,:,i)=H;%Will be used by Jacobian 
      X=H(1,4);%store position
      Y=H(2,4);
      Z=H(3,4);
 end 
 
 %Jacobians
Jv=sym('jv',[3,size(table,1)]);%Preallocate for faster computation
Jw=sym('jw',[3,size(table,1)]);
for i=1:size(table,1)
%Revolute Joint   
if(table(i,4)==q(i))  
if i==1
 Jv(:,i)=transpose(cross([0 0 1],[H(1,4) H(2,4) H(3,4)]));
 Jw(:,i)=transpose([0 0 1]);
 else
 Jv(:,i)=transpose(cross([ZBase(1,3,i-1) ZBase(2,3,i-1) ZBase(3,3,i-1)],[H(1,4)-ZBase(1,4,i-1),H(2,4)-ZBase(2,4,i-1),H(3,4)-ZBase(3,4,i-1)]));
 Jw(:,i)=transpose([ZBase(1,3,i-1) ZBase(2,3,i-1) ZBase(3,3,i-1)]);    
end
else
%Prismatic Joint 
if i==1
Jv(:,i)=[0 0 1];  
Jw(:,i)=[0 0 0];
else
Jv(:,i)=[ZBase(1,3,i-1) ZBase(2,3,i-1) ZBase(3,3,i-1)];  
Jw(:,i)=[0 0 0]; 
end
end
end
J=[Jv;Jw];%Combine Jv and Jw into matrix J

 %Equate Vectors, size of vector depend on step size
 Q=zeros(size(table,1),StepSize);%Preallocate for speed
 for i=1:size(table,1)
 if(table(i,4)==q(i))%Convert angle to radiant for revolute joints
      Q(i,:)=deg2rad(linspace(Min(i),Max(i),StepSize));
 else  
      Q(i,:)=linspace(Min(i),Max(i),StepSize);
 end
 end

% Find all the possible Combinations 
Partition=num2cell(Q,2);
Q=combvec(Partition{:});%Combine joint variables  
for i=1:size(Q,1)
eval(['q' num2str(i) '= Q(i,:);']);%Store Combined parameter in q1...qn
end

%Equate X Y Z In case one of them has a constant value 
if size(eval(H(1,4)),2)==1
X=linspace(H(1,4),H(1,4),size(Q,2));
end
if size(eval(H(2,4)),2)==1
Y=linspace(H(2,4),H(2,4),size(Q,2));
end
if size(eval(H(3,4)),2)==1
Z=linspace(H(3,4),H(3,4),size(Q,2));
end

%Plot Vectors of same size in 3d
pl1=plot3(eval(X),eval(Y),eval(Z),'b.'); 
grid on;
axis equal;
xlabel('x-axis');%Label the axix. 
ylabel('y-axis');
zlabel('z-axis');
title('Reachable and Singular Workspace');
