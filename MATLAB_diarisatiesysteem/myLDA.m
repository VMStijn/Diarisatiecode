function [L,D]=myLDA(data,class)
% L=myLDA(data,class)
% data: one observation per column
% class: class id, can be string array or numbers
[classes,~,idx]=unique(class);
[D,T]=size(data);
NbClass=length(classes);
n=zeros(1,NbClass);
mu=zeros(D,NbClass);
cv_class=zeros(D,D,NbClass);
for cl=1:NbClass
    ii=(idx==cl);
    n(cl)=sum(ii);
    mu(:,cl)=mean(data(:,ii),2);
    cv_class(:,:,cl)=(data(:,ii)-mu(:,cl))*(data(:,ii)-mu(:,cl))';
end
mut=mean(data,2);
between=((mu-mut).*n)*(mu-mut)';
within=sum(cv_class,3)+1e-10*eye(D);
%between=cov(mu',1);
%total=cov(data',1);
%within=mean(cv_class,3);
[L,D]=eig(between,within);
D=diag(D);
[D,ii]=sort(D,'descend');
L=L(:,ii);
return

