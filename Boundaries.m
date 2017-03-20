figure;% Create a new instance of a plot 
check=0;%Defining some  useful global variables
column=1;
count=0;
StepSize=10000;% Increase Step to 10K for more accuracy

Vec123=zeros(size(table,1),3);%Preallocate for faster Computation
for i=1:size(table,1) %Assign a [1 2 3] vector for each joint 
Vec123(i,:)=[1,2,3];%1=Min, 2=Max, 3=Range
end
CellVec123=num2cell(Vec123,2);
A=combvec(CellVec123{:});%Perform all possible combinations

NewComb=zeros(size(A,1),1);%Preallocate for faster Computation
for i=1:(size(A,2))%Two nested for loops to evaluate each element in A 
   for j=1:size(A,1)%Searching for number 3 
   if(A(j,i)==3)%If i found it twice it will not be stored 
        count=count+1;
   end
   end
   if(count==1) %If I found it only once 
   NewComb(:,column)=A(:,i);%Store the combination 
   column=column+1;%Increase Column size of New Comb
   end
count=0; %Equate to 0 after each iteration of i  
end

for i=1:size(NewComb,2) %%Two nested for loops to evaluate NewComb Matrix 
  for j=1:size(NewComb,1) 
  if(NewComb(j,i)==1)%1 represent Min 
     if(table(j,4)==q(j)) %Checking if Prismatic or revolute joint 
     eval(['q' num2str(j) '= deg2rad(linspace(Min(j),Min(j),StepSize));']);
     else  %Spacing the vector 
         eval(['q' num2str(j) '= linspace(Min(j),Min(j),StepSize);']);
     end
  end
  if(NewComb(j,i)==2)%2 represent Max 
     if(table(j,4)==q(j)) 
     eval(['q' num2str(j) '= deg2rad(linspace(Max(j),Max(j),StepSize));']);
     
     else  
      eval(['q' num2str(j) '= linspace(Max(j),Max(j),StepSize);']);
     end
  end
  if(NewComb(j,i)==3)%3 represent Range
     if(table(j,4)==q(j)) 
     eval(['q' num2str(j) '= deg2rad(linspace(Min(j),Max(j),StepSize));']);
     else  
       eval(['q' num2str(j) '= linspace(Min(j),Max(j),StepSize);']);
     end
  end
  end 
  if size(eval(H(1,4)),2)==1% Resize in case one of the value is constant
  X=linspace(H(1,4),H(1,4),StepSize);
  end
  if size(eval(H(2,4)),2)==1
  Y=linspace(H(2,4),H(2,4),StepSize);
  end
  if size(eval(H(3,4)),2)==1
  Z=linspace(H(3,4),H(3,4),StepSize);
  end
  plot3(eval(X),eval(Y),eval(Z),'k.');%Plotting and Labeling 
  hold on;
  grid on;
  axis equal;
  xlabel('x-axis');
  ylabel('y-axis');
  zlabel('z-axis');
  title('Workspace Boundary');  
end