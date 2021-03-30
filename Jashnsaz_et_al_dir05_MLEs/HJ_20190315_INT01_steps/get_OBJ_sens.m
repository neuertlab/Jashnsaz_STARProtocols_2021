function [OBJ_sens_to_Pars] = get_OBJ_sens(sim_data, model, params)

    for nData=1:length(sim_data)

        data = sim_data{nData};
        model = Get_ODE(model,data.Salt);

        for param_num=1:length(params)
            % Pick a parameter
            cpa = param_num;                                                    % index of the parameter that I will change - all other parameters are fixed. 
            pchange = params(cpa);                                              % parameter value I want to change
            npars = 100;                                                        % number of different parameter values of cpa to try
            pvec_change = linspace(pchange - .1*pchange,pchange+.1*pchange,npars); 
            %pvec_change = sort([pvec_change pchange]); % make sure "true" parameter is in the vector. 

            % make a matrix of parameters
            all_pars = repmat(params,1,npars);
            all_pars(cpa,:) = pvec_change;

            % loop over all parameter values, solve model, and record J. 
            J = zeros(npars,1);
            for i = 1:npars
    %             disp(['Testing parameter ', num2str(i), ' of ', num2str(npars)])
                J(i) = get_OBJ_simple(model,data,all_pars(:,i));  
            end
            solutions{param_num}.pvec_change=pvec_change;
            solutions{param_num}.J=J; 

        end

        OBJ_sens_to_Pars{nData} = solutions;
        clear solutions; 
        disp(['   OBJ_sens on data', num2str(nData), ' done.'])
    end
end