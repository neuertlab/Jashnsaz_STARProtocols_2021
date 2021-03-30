function OBJ = get_OBJ(Param, train_inputs, train_models, sparsobj, wt) % (10.^X', train_inputs, train_models, 0, 1)
    Param(Param<1e-3)=1e-3; Param(Param>1e3)=1e3; 

    OBJ = 0; 
    for i=1:length(train_inputs)

        mytraindata = train_inputs{i}; 
        mytrainmodel = train_models{i}; 

        mu_D = mytraindata.hogp;
        sigma_D = mytraindata.STDVHog;
        
        basal_params = 0.1; 
        ODE = @(t,x)mytrainmodel.model.ODE(t,x,Param,basal_params);
        JAC = @(t,x)mytrainmodel.model.Jacobian(t,x,Param,basal_params);
        IC = 0.05*ones(mytrainmodel.model.n_nodes,1); IC(end)=0; 
        options = odeset('Jacobian',JAC);

        [~,yout] = ode23s(ODE,mytraindata.tt*60,IC,options); % ode23s ode15s
        x_Mod = yout(:,mytrainmodel.model.n_nodes);

        % objective function based on Hog1 traces
        if sparsobj==0
            wt = ones(size(x_Mod));
        else  % Use only a sparse set of the data in each evaluation.
        end
        wt=wt/sum(wt);

        try
            OBJ = OBJ + sum(((x_Mod-mu_D)./sigma_D).^2.*wt); % mean(sigma_D)
        catch % ode23 failor 
            
            check_vec_sizes = [size(wt); size(x_Mod); size(mu_D); size(sigma_D)] 
            disp('skipped ode -- assume zero')
            OBJ = OBJ + sum(((0-mu_D)./sigma_D).^2);
            sort_params = sort(Param, 'ascend'); 
            disp(['4mins and 4maxs params:  ', num2str(sort_params([1:4 end-3:end])')]) 
        end
    end    
    global minerr
    if OBJ < minerr 
        global best_pars
        minerr = OBJ; 
        best_pars = Param; 
    end   
end

