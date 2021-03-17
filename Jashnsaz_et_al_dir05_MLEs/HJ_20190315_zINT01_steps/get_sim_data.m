function [sim_data] = get_sim_data(TTT, TT, model_index, params)

sympref('HeavisideAtOrigin',1);
salt_funcs{1} = @(t) 0.2 * heaviside(t - .001);
salt_funcs{2} = @(t) 0.4 * heaviside(t - .001);
salt_funcs{3} = @(t) 0.6 * heaviside(t - .001);
salt_funcs{4} = @(t) 0.8 * heaviside(t - .001);

salt_funcs{5} = @(t) min([(0.2*t/(60*TT)),.2]); 
salt_funcs{6} = @(t) min([(0.4*t/(60*TT)),.4]); 
salt_funcs{7} = @(t) min([(0.6*t/(60*TT)),.6]);
salt_funcs{8} = @(t) min([(0.8*t/(60*TT)),.8]);

salt_funcs{9} = @(t) min([(0.2.*t.^2/(60*TT)^2),.2]); 
salt_funcs{10} = @(t) min([(0.4.*t.^2/(60*TT)^2),.4]); 
salt_funcs{11} = @(t) min([(0.6.*t.^2/(60*TT)^2),.6]); 
salt_funcs{12} = @(t) min([(0.8.*t.^2/(60*TT)^2),.8]); 

salt_funcs{13} = @(t) min([(0.2.*t.^3/(60*TT)^3),.2]); 
salt_funcs{14} = @(t) min([(0.4.*t.^3/(60*TT)^3),.4]); 
salt_funcs{15} = @(t) min([(0.6.*t.^3/(60*TT)^3),.6]); 
salt_funcs{16} = @(t) min([(0.8.*t.^3/(60*TT)^3),.8]); 

load Models
model=Model{model_index};                                                % pick a model as tru model


for i = 1:16

    sim_data{i}.tt=[0:TTT];
    sim_data{i}.Salt = salt_funcs{i};
    model = Get_ODE(model,sim_data{i}.Salt);                           % add ODE to model object for a given Salt input
    model.IC = 0.05*ones(model.n_nodes,1); model.IC(end)=0;                                % set initial condition (everything is inactive)

    % Define parameters.     
    kinetic_params = params; 
    basal_param=0.1;
    % Specify ODE
    ODE = @(t,x)model.ODE(t,x,kinetic_params,basal_param); 
    JAC = @(t,x)model.Jacobian(t,x,kinetic_params,basal_param);
    options = odeset('Jacobian',JAC);
     % Integrate ODE. 
    [~,yout] = ode23s(ODE,sim_data{i}.tt*60,model.IC);

    sim_data{i}.MeanHog = yout(:,model.n_nodes);                       % get the hog output - the "bottom" node. 
    sim_data{i}.cumsumMeanHog = cumsum(sim_data{i}.MeanHog);  

    %generate single cell trajs by adding Gaussian noise to the mean.
    noise_level = 0.5; 
    BiolRep = 5; 
    single_cell_trajs = 10; 

    for br=1:BiolRep
        mean_var=1+0*randn(1,1);
        for sc=1:single_cell_trajs
            sim_data{i}.scSTDVHog(:,sc) = noise_level*mean(yout(:,model.n_nodes)).*randn(size(yout,1),1);
            sim_data{i}.scHogp(:,sc) = mean_var*yout(:,model.n_nodes) + sim_data{i}.scSTDVHog(:,sc);  
            sim_data{i}.cumsum_scHogp(:,sc) = cumsum(sim_data{i}.scHogp(:,sc));
        end
        sim_data{i}.br_hogp(:,br) = mean(sim_data{i}.scHogp')';
        sim_data{i}.br_STDVHog(:,br) = std(sim_data{i}.scHogp')';
        sim_data{i}.cumsum_br_hogp(:,br) = mean(sim_data{i}.cumsum_scHogp')';
        sim_data{i}.cumsum_br_STDVHog(:,br) = std(sim_data{i}.cumsum_scHogp')';
    end

    sim_data{i}.hogp = mean(sim_data{i}.br_hogp')';
    sim_data{i}.STDVHog = 2*std(sim_data{i}.br_STDVHog')';

    sim_data{i}.cumsumhogp = mean(sim_data{i}.cumsum_br_hogp')';
    sim_data{i}.cumsumSTDVHog = std(sim_data{i}.cumsum_br_STDVHog')';

    % calculate each salt function for given time points.
    j=1;
    salt_out=zeros(1,length(sim_data{i}.tt));
    for t = sim_data{i}.tt
        salt_out(j) = sim_data{i}.Salt(t*60);
        j=j+1;
    end 
    sim_data{i}.salt_out=salt_out;

end
    
    disp(['Data is simulated from Model', num2str(model_index),'.']);
    
end