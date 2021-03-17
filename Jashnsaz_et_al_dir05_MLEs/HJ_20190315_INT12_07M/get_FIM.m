function [FIM,FIM_STATS,S]= get_FIM(model,theta,free_parameters,data,log)
    % Get the Fisher Information Matrix for a particular model,
    % about parameters specified by theta. 
    % free parameters should be a vector of indices of theta that are 
    % "free" in the model. The variance should be of size Nt.
    % for now, I'm assuming our only observable is the last node. 
    % log refers to the log-FIM (i.e. df/dlogtheta)^2
   
    % FOR each free parameter, compute the FIM:
    S = zeros(length(data.tt),length(free_parameters));
    for i=1:length(free_parameters)
        model = Get_Sens_ODE(model,data.Salt,free_parameters(i));
        x0 = zeros(model.n_nodes*2,1); x0(1:model.n_nodes-1,1) = 0.05;         
        basal_param = 0.1;
        ODE = @(t,x)model.ODE(t,x,theta,basal_param);
        [~,yout] = ode23s(ODE,data.tt*60,x0);
        S(:,i) = yout(:,end);
    end
    % make the variance matrix
    COV = inv(diag(data.STDVHog.^2));
    % compute the FIM
    FIM = zeros(length(free_parameters),length(free_parameters));
    for i=1:length(free_parameters)
        for j=1:length(free_parameters)
            if log
                FIM(i,j) = theta(free_parameters(i))*theta(free_parameters(j))*...
                    S(:,i)'*COV*S(:,j);
            else
                FIM(i,j) = S(:,i)'*COV*S(:,j);
            end            
        end 
    end

    % get FIM stats and optimalities. 
    [parsUncert,eigs_invFIM,eigs_FIM,inv_eig_FIM,invFIM,Ellipses,UncertaintyM,efail] = get_FIMSTATS(FIM,theta,free_parameters);

    FIM_STATS.parsUncert = parsUncert;
    FIM_STATS.eigs_invFIM = eigs_invFIM;
    FIM_STATS.eigs_FIM = eigs_FIM;
    FIM_STATS.inv_eig_FIM = inv_eig_FIM; 
    FIM_STATS.invFIM = invFIM; 
    FIM_STATS.Ellipses = Ellipses;
    FIM_STATS.UncertaintyM = UncertaintyM; 
    FIM_STATS.EllipseFailureRate = efail;
     
    norm_ordr = 2;  
    [Opt_U, U_Opt_names] = get_Opt_U(parsUncert',norm_ordr);
    [Opt_invFIM, invFIM_Opt_names] = get_Opt_eigs(eigs_invFIM',invFIM,norm_ordr,'invFIM');
    [Opt_inveigFIM, inveigFIM_Opt_names] = get_Opt_eigs(inv_eig_FIM',FIM,norm_ordr,'inveigFIM');
    [Opt_FIM, FIM_Opt_names] = get_Opt_eigs(eigs_FIM',FIM,norm_ordr,'FIM');
    
    FIM_STATS.Opt_U = Opt_U; FIM_STATS.U_Opt_names = U_Opt_names; % optimalities directly from parameters uncertanties
    FIM_STATS.Opt_invFIM = Opt_invFIM; FIM_STATS.invFIM_Opt_names = invFIM_Opt_names; % optimalities from invFIM eigenvalues
    FIM_STATS.Opt_inveigFIM = Opt_inveigFIM; FIM_STATS.inveigFIM_Opt_names = inveigFIM_Opt_names; % optimalities from FIM inv_eigenvalues  
    FIM_STATS.Opt_FIM = Opt_FIM; FIM_STATS.FIM_Opt_names = FIM_Opt_names; % optimalities from FIM eigenvalues  
end
