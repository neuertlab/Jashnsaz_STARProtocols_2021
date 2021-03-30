function model = Get_ODE(model,salt)
%%% Get the ODEs for a model 
% Also requires a salt function (this isn't ideal)
% get the number of nodes, make empty ODE. 
n_nodes = size(model.A,1);
tmp_ODE_A = sym(zeros(n_nodes,1)); 
tmp_ODE_B = sym(zeros(n_nodes,1));
% get the number of parameters and 
% specify parameter vector for the models. 
n_parameters = 2*nnz(model.A)+2*nnz(model.B)+2*nnz(model.C);
sym_K = sym('K',[n_parameters 1]);
sym_X = sym('X',[n_nodes 1] );
param_count = 1; 
% symbolic time
t = sym('t');
% use a seperate symbol for basal deactivation terms. 
d = sym('d');
% symbolic salt for symbolic ODE
s = sym('s');

for j=1:n_nodes
    if model.B(j) == 1
        tmp_ODE_B(j) = tmp_ODE_B(j) + ...
            sym_K(param_count)*(1-sym_X(j))/((1-sym_X(j))+sym_K(param_count+1)); % need to make sure this is correct
            % increase parameter count
        param_count = param_count+2;
    elseif model.B(j) == -1
            tmp_ODE_B(j) = tmp_ODE_B(j) - ...
            sym_K(param_count)*(sym_X(j))/((sym_X(j))+sym_K(param_count+1)); % need to make sure this is correct
            % increase parameter count
            param_count = param_count+2; 
    end
    % Also, add in the terms for basal deactivation
    if model.C(j) == -1
        tmp_ODE_A(j) = tmp_ODE_A(j) - ...
            sym_K(param_count)*d*(sym_X(j))/((sym_X(j))+sym_K(param_count+1)); % need to make sure this is correct
            % increase parameter count
            param_count = param_count+2; 
    elseif model.C(j) == 1
        tmp_ODE_A(j) = tmp_ODE_A(j) + ...
            sym_K(param_count)*d*(1-sym_X(j))/((1-sym_X(j))+sym_K(param_count+1)); % need to make sure this is correct
            % increase parameter count
            param_count = param_count+2; 
    end
end
    

for j=1:n_nodes
    for k=1:n_nodes
        if model.A(j,k) == 1
            tmp_ODE_A(j) = tmp_ODE_A(j) + ...
            sym_K(param_count)*sym_X(k)*(1-sym_X(j))/((1-sym_X(j))+sym_K(param_count+1)); % need to make sure this is correct
            % increase parameter count
            param_count = param_count+2; 

        elseif model.A(j,k) == -1
            tmp_ODE_A(j) = tmp_ODE_A(j) - ...
            sym_K(param_count)*sym_X(k)*(sym_X(j))/((sym_X(j))+sym_K(param_count+1)); % need to make sure this is correct
            % increase parameter count
            param_count = param_count+2; 
        end            
    end   
    
end
sym_vec = [t; d; sym_K; sym_X];
model.param_count=n_parameters;
model.sym_ODE = tmp_ODE_A + s* tmp_ODE_B; 
% neet to convert the symbolic ODEs to the necessary functions
args = {t,sym_X,sym_K,d};
tmp_ODE_AA = matlabFunction(tmp_ODE_A,'Vars',args);
tmp_ODE_BB = matlabFunction(tmp_ODE_B,'Vars',args);
%model.ODE = @(t,x,k,d) tmp_ODE_AA(t,x,k,d)+salt(t)*tmp_ODE_BB(t,x,k,d);
%model.ODE = @(t,x,k,d) eval(subs(tmp_ODE_A,sym_vec,[t d k x']'))+salt(t)*eval(subs(tmp_ODE_B,sym_vec,[t d k x']'));  

Jacobian_A = matlabFunction(jacobian(tmp_ODE_A,sym_X),'Vars',args);
Jacobian_B = matlabFunction(jacobian(tmp_ODE_B,sym_X),'Vars',args); 
model.Jacobian = @(t,x,k,d) Jacobian_A(t,x,k,d)+salt(t)*Jacobian_B(t,x,k,d);

model.ODE = @(t,x,k,d) tmp_ODE_AA(t,x,k,d)+salt(t)*tmp_ODE_BB(t,x,k,d);
%model.ODE = @(t,x,k,d) eval(subs(tmp_ODE_A,sym_vec,[t d k x']'))+salt(t)*eval(subs(tmp_ODE_B,sym_vec,[t d k x']'));  
end  
            
    