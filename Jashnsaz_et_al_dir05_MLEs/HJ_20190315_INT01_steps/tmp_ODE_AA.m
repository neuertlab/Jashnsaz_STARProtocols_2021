function tmp_ODE_A = tmp_ODE_AA(t,in2,in3,d)
%TMP_ODE_AA
%    TMP_ODE_A = TMP_ODE_AA(T,IN2,IN3,D)

%    This function was generated by the Symbolic Math Toolbox version 8.1.
%    01-Aug-2018 15:23:46

K3 = in3(3,:);
K4 = in3(4,:);
K7 = in3(7,:);
K8 = in3(8,:);
K9 = in3(9,:);
K10 = in3(10,:);
K11 = in3(11,:);
K12 = in3(12,:);
K13 = in3(13,:);
K14 = in3(14,:);
X1 = in2(1,:);
X2 = in2(2,:);
X3 = in2(3,:);
t2 = X3-1.0;
tmp_ODE_A = [-(K3.*X1.*d)./(K4+X1);-(K7.*X2.*d)./(K8+X2);-(K11.*X1.*t2)./(K12-X3+1.0)-(K13.*X2.*t2)./(K14-X3+1.0)-(K9.*X3.*d)./(K10+X3)];
