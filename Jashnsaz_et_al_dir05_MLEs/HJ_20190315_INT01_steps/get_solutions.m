function [Hog1pp, error, NodesElseHog1pp] = get_solutions(model,params,data)

    model.IC = 0.05*ones(model.n_nodes,1); model.IC(end)=0;                                % set initial condition 
    basal_param = 0.1;
    
    model = Get_ODE(model,data.Salt);
    ODE = @(t,x)model.ODE(t,x,params,basal_param);
    JAC = @(t,x)model.Jacobian(t,x,params,basal_param);
    options = odeset('Jacobian',JAC);

    [~,yout] = ode23s(ODE,data.tt*60,model.IC,options);

    Hog1pp = yout(:,model.n_nodes);
    error = mean(abs(Hog1pp - data.hogp));
    NodesElseHog1pp = yout(:,1:model.n_nodes-1);
