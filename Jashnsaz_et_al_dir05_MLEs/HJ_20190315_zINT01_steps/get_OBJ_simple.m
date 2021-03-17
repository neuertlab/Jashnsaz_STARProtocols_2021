function J = get_OBJ_simple(Mod,Data,Param)

     J = 0;
     n_data_points = 0; % number of total data points from all Data sets used in fit. 
         
    for i=1:length(Data)
        
        basal_params = 0.1; 
        ODE = @(t,x)Mod.ODE(t,x,Param,basal_params);
        JAC = @(t,x)Mod.Jacobian(t,x,Param,basal_params);
        options = odeset('Jacobian',JAC);
        IC = 0.05*ones(Mod.n_nodes,1); IC(end)=0; 
        
        [~,yout] = ode23s(ODE,Data.tt*60,IC,options);
        x_Mod = yout(:,Mod.n_nodes);

        mu_D = Data.MeanHog;
        sigma_D = Data.STDVHog;        
        n_data_points = n_data_points + length(mu_D); 

        try
            J = J + sum(((x_Mod-mu_D)./sigma_D).^2);
        catch
        	J = J + sum(((0-mu_D)./sigma_D).^2);
        end
        
    end
    
    J = J/n_data_points; 
    
end