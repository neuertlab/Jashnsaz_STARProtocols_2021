function [FP_OBJ_FIM] = do_FP_FIM_J(nodeID)
    warning('off','all'); 
%     clear

    load Models
%     load sim_data
    simD = load('../../simData.mat'); 
    simData = simD.simData; 
    
    rng('shuffle'); 
    seeds = randi(2^32,1e3,1); 
    rng(seeds(nodeID)); %randomize the seed for rng
    
    % get a refrence for the speed of the node. 
    for getnodespead=1:100
        tic 
        sum(sum(ones(10000,10000)));
        nodespeads(getnodespead)=toc;   
    end
    nodespeadref = mean(nodespeads); 
    
   
    n_BRs = size(simData,2);
    n_models = length(Model); 
    
    % assign train data to nodes 
    possible_train_data = [6:6:36]; % train data to choose from [0.7M]
    choose_train_data = ceil(nodeID/n_BRs); % index from nodeID to choose train data set    
    chosen_train_data = possible_train_data([1:choose_train_data]); % choose train data set (all the indexes for train data)
    
    m = 3; % model number (true model)
    ssdata = mod(nodeID,n_BRs); if ssdata==0; ssdata=n_BRs; end; %BR number out of 15 BRs for each condition
    
%     sim_data = simData(ssdata).sim_data; % picks corresponding BR sim_data
    sim_data_all37 = simData(ssdata).sim_data; % picks corresponding BR sim_data
    for ibr=1:36
        sim_data{ibr}=sim_data_all37{ibr};
    end
    clear sim_data_all37; 
    
    % plotting options
    toPlotFigs = "no"; toSaveFigs = "no"; 
    
    % optimization algorithm params
    Npop = 200; % Population size 
    Ngen = 20; % Number of generations
    iMax = 20; % Number of GA simulations
    nElites = 1; % Number of elites
    ulb = 3; 
    TPdrop = 0.25; % Number of data points to drop     
    
    global dirName; dirName = ['OutPuts',num2str(nodeID)]; 
    mkdir(dirName); 
    
    global minerr; minerr = inf; 
    global best_pars; best_pars = [];        
    global modelindex; modelindex = m; 

    %%
    model_index = modelindex;
    sim_data_indx = [1:length(sim_data)]; % all sim data index (trainData + testData)

    train_data_indx = [sim_data_indx(chosen_train_data)]; % [in1 in2 etc] % train data index 
    
    test_data_indx = sim_data_indx; % test data index
    
    for ssss=train_data_indx
        test_data_indx=test_data_indx(test_data_indx~=ssss);
    end
    
    model = Model{model_index};
    X=100*rand(model.n_params,1);
    for i=1:length(train_data_indx)
        train_inputs{i} = sim_data{train_data_indx(i)};
    end
    
    for trainmodels=1:length(train_inputs)
        train_models{trainmodels}.model = Get_ODE(model,train_inputs{trainmodels}.Salt);
    end
    
    trainDataModel.train_models = train_models; 
    trainDataModel.train_inputs = train_inputs; 
    
    % fit optimization condition
    FitConditionsVec.nodeID = nodeID; 
    FitConditionsVec.Npop = Npop; 
    FitConditionsVec.Ngen = Ngen; 
    FitConditionsVec.iMax = iMax; 
    FitConditionsVec.TPdrop = TPdrop; 
    FitConditionsVec.ulb = ulb; 
    FitConditionsVec.nElites = nElites; 
    FitConditionsVec.randnumRef = rand; 
    FitConditionsVec.nodespeadref = nodespeadref; 
    FitConditionsVec.SimData_BR = ssdata; 

    %% G.A. Search - logarithmic then Fminnsearch     (Param, train_inputs, train_models, mkplots, sparsobj, wt)
    Constrs.LB=-ulb*ones(size(X'));  Constrs.UB=ulb*ones(size(X'));
    Mut_Fun = @(parents,options,nvars,FitnessFcn,state,thisScore,thisPopulation)Mutation(parents,options,nvars,FitnessFcn,state,thisScore,thisPopulation,Constrs);

    gaopt = gaoptimset('Display','none',... % 'useparallel',1,
        'MutationFcn',Mut_Fun,...
        'PopulationSize',Npop);
    gaopt = gaoptimset(gaopt,'EliteCount',nElites,'Generations',Ngen);
    
%     spmd
%         warning('off')c
%     end

    opt = optimset('display','none','MaxIter',500); %'useparallel',1,
    
    OBJ_GA_full = @(X)get_OBJ(10.^X', train_inputs, train_models, 0, 0);
    OBJ_fmin_full = @(X)get_OBJ(10.^X, train_inputs, train_models, 0, 0);

    Hv = [];
    OBJs = NaN(iMax+1,4);
    
    for i=0:iMax
        tic
        disp(['i = ', num2str(i), ' started.'])
        if i<=4||mod(i,4)==0
            disp('using random initial population')
            gaopt.InitialPopulation = -3 + 6*rand(Npop,model.n_params);
        else
            disp('using initial population permuted from previous steps')
            gaopt.InitialPopulation = -0.5 + 1*rand(Npop,model.n_params)+...
                repmat(H,Npop,1);
            gaopt.InitialPopulation(1:size(Hv,1),:) = Hv;
        end
        wt = rand(size(train_inputs{1}.hogp));
        wt(wt<=TPdrop)=0;
        wt(wt>TPdrop)=1;
        disp('runing GA - red')
        OBJ_GA_red = @(X)get_OBJ(10.^X', train_inputs, train_models, 1, wt);
        H = ga(OBJ_GA_red,length(X),gaopt); % Run the G.A.
        OBJs(i+1, 1) = OBJ_fmin_full(H'); 
        disp(['final obj = ',num2str(OBJs(i+1, 1))])

        disp('runing FMIN - red')
        OBJ_fmin_red = @(X)get_OBJ(10.^X, train_inputs, train_models, 1, wt);
        H = fminsearch(OBJ_fmin_red,H',opt)';
        Hv = [Hv;H];
        OBJs(i+1, 2) = OBJ_fmin_full(H'); 
        disp(['final obj = ',num2str(OBJs(i+1, 2))])

        disp('runing GA - full')       
        gaopt.InitialPopulation = -0.5 + 1*rand(Npop,model.n_params)+...
            repmat(H,Npop,1);
        gaopt.InitialPopulation(1:size(Hv,1),:) = Hv;
        H = ga(OBJ_GA_full,length(X),gaopt); % Run the G.A.
        OBJs(i+1, 3) = OBJ_fmin_full(H'); 
        disp(['final obj = ',num2str(OBJs(i+1, 3))])

        disp('runing FMIN - full')
        H = fminsearch(OBJ_fmin_full,H',opt)';
        Hv = [Hv;H];
        OBJs(i+1, 4) = OBJ_fmin_full(H'); 
        disp(['final obj = ',num2str(OBJs(i+1, 4))])
    
        sim_time(i+1) = toc;
        disp(['time = ', num2str(sim_time(i+1)), ' | i = ', num2str(i), ' finished.'])
        disp(' ')  
    end
    sim_time = sim_time/60;     
    OBJ = minerr; 
    
%     if toPlotFigs=="yes"
%         hh=plot_OBJs(toSaveFigs, OBJs); close all; 
%     end
    
    FP_OBJ_FIM.dirName = dirName; 
    FP_OBJ_FIM.sim_time = sim_time; 
    FP_OBJ_FIM.FitConditionsVec = FitConditionsVec; 
    FP_OBJ_FIM.sim_data_indx = sim_data_indx; 
    FP_OBJ_FIM.train_data_indx = train_data_indx;
    FP_OBJ_FIM.test_data_indx = test_data_indx; 
    FP_OBJ_FIM.model_index = model_index; 
    FP_OBJ_FIM.trainDataModel = trainDataModel; 
    FP_OBJ_FIM.best_pars = best_pars;
    FP_OBJ_FIM.OBJ = OBJ; 
    FP_OBJ_FIM.OBJs = OBJs; 

    save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM');
    
    % get predictions0
    fp_errors = zeros(1, length(sim_data)); 
    
    for testdata = 1:length(sim_data)
        predict_data=sim_data{testdata}; 
        [Hog1pp, predict_error, NodesElseHog1pp] = get_solutions(model,best_pars,predict_data);
        predictions{testdata}.Hog1pp = Hog1pp;
        predictions{testdata}.NodesElseHog1pp = NodesElseHog1pp; 
        predictions{testdata}.predict_error = predict_error; fp_errors(testdata) = predict_error; 
        predictions{testdata}.tt = predict_data.tt;
        predictions{testdata}.Salt = predict_data.Salt;
        predictions{testdata}.MeanHog = Hog1pp;
        predictions{testdata}.STDVHog = predict_data.STDVHog;
        predictions{testdata}.hogp = Hog1pp;
        predictions{testdata}.salt_out = predict_data.salt_out;
        disp(['   predicton on sim_data ', num2str(testdata), ' done.'])
    end
    disp(' ')  

%     FP_EE.F_m = mean(fp_errors(train_data_indx)); FP_EE.F_s = std(fp_errors(train_data_indx)); 
%     FP_EE.P_m0 = mean(fp_errors(test_data_indx)); FP_EE.P_s0 = std(fp_errors(test_data_indx));
%     FP_OBJ_FIM.FP_EE = FP_EE;   

    FP_OBJ_FIM.ErrorsFit = fp_errors(train_data_indx); 
    FP_OBJ_FIM.ErrorsP0 = fp_errors(test_data_indx); 
    
    FP_OBJ_FIM.predictions0 = predictions;   
    save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM'); 
    
    clear predictions; clear fp_errors; 
    
    % get predictions1
    sim_test_data1 = simData(ssdata).sim_test_data1;   
    fp_errors = zeros(1, length(sim_test_data1)); 
    
    for testdata = 1:length(sim_test_data1)
        predict_data=sim_test_data1{testdata}; 
        [Hog1pp, predict_error, NodesElseHog1pp] = get_solutions(model,best_pars,predict_data);
        predictions{testdata}.Hog1pp = Hog1pp;
        predictions{testdata}.NodesElseHog1pp = NodesElseHog1pp; 
        predictions{testdata}.predict_error = predict_error; fp_errors(testdata) = predict_error; 
        predictions{testdata}.tt = predict_data.tt;
        predictions{testdata}.Salt = predict_data.Salt;
        predictions{testdata}.MeanHog = Hog1pp;
        predictions{testdata}.STDVHog = predict_data.STDVHog;
        predictions{testdata}.hogp = Hog1pp;
        predictions{testdata}.salt_out = predict_data.salt_out;
        disp(['   predicton on sim_test_data1 ', num2str(testdata), ' done.'])
    end
    disp(' ')  

%     FP_EE.P_m1 = mean(fp_errors); FP_EE.P_s1 = std(fp_errors); FP_OBJ_FIM.FP_EE = FP_EE;   
    FP_OBJ_FIM.ErrorsP1 = fp_errors; 
    FP_OBJ_FIM.predictions1 = predictions;      
    
    save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM'); 
    clear predictions; clear fp_errors; 
    
    % get predictions2
    sim_test_data2 = simData(ssdata).sim_test_data2;   
    fp_errors = zeros(1, length(sim_test_data2)); 
    
    for testdata = 1:length(sim_test_data2)
        predict_data=sim_test_data2{testdata}; 
        [Hog1pp, predict_error, NodesElseHog1pp] = get_solutions(model,best_pars,predict_data);
        predictions{testdata}.Hog1pp = Hog1pp;
        predictions{testdata}.NodesElseHog1pp = NodesElseHog1pp; 
        predictions{testdata}.predict_error = predict_error; fp_errors(testdata) = predict_error; 
        predictions{testdata}.tt = predict_data.tt;
        predictions{testdata}.Salt = predict_data.Salt;
        predictions{testdata}.MeanHog = Hog1pp;
        predictions{testdata}.STDVHog = predict_data.STDVHog;
        predictions{testdata}.hogp = Hog1pp;
        predictions{testdata}.salt_out = predict_data.salt_out;
        disp(['   predicton on sim_test_data2 ', num2str(testdata), ' done.'])
    end
    disp(' ')  
    
%     FP_EE.P_m2 = mean(fp_errors); FP_EE.P_s2 = std(fp_errors); FP_OBJ_FIM.FP_EE = FP_EE;   
    FP_OBJ_FIM.predictions2 = predictions;  
    FP_OBJ_FIM.ErrorsP2 = fp_errors; 
    
    save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM'); 
    clear predictions; clear fp_errors;
    
    predictions = FP_OBJ_FIM.predictions0;   
     
%     if toPlotFigs=="yes"
%         hh = plot_FP(toSaveFigs, sim_data, model_index, train_data_indx, test_data_indx, best_pars, predictions, OBJ, train_inputs, train_models{1}, sim_time); close all;   
%     end
     
    for i=1:length(test_data_indx)
        test_data{i} = predictions{test_data_indx(i)};
        test_data{i}.indx = test_data_indx(i); 
    end
     
    FP_OBJ_FIM.test_data = test_data;   
    save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM');  
     
%     TTT = 50; 
%     for i=1:2
%         [sim_data] = get_sim_data(TTT, TTT/i, model_index, best_pars); 
%         synth_data{i}.sim_data = sim_data; 
%     end
%     FP_OBJ_FIM.synth_data = synth_data;   
%     save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM');      

    % FIM
    for nEval=1:length(test_data)
        free_parameters=[1:model.n_params]; bst_pars=best_pars; data=test_data{nEval}; log=1;
        [FIM_Matrix,FIM_STATS,Sens_Matrix] = get_FIM(model,bst_pars,free_parameters,data,log);
        FIM{nEval}.FIM_Matrix = FIM_Matrix; 
        FIM{nEval}.FIM_STATS = FIM_STATS; 
        FIM{nEval}.Sens_Matrix = Sens_Matrix;
        disp(['   FIM on test_data ', num2str(nEval), ' [sim_data ', num2str(test_data_indx(nEval)),'] done.'])
    end
    disp(' ')  
    
    FP_OBJ_FIM.FIM = FIM;
    save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM');  
% 
%     if toPlotFigs=="yes"   
%         hh = plot_FIM(toSaveFigs, model_index, train_data_indx, test_data_indx, best_pars, train_models{1},FP_OBJ_FIM); close all; 
%     end
% 
%     % ellipses 
%     if toPlotFigs=="yes"   
%         plot_ellipses(toSaveFigs, FP_OBJ_FIM); close all; 
%     end
     
    % get OBJvsPars
    [OBJ_sens_to_Pars] = get_OBJ_sens(sim_data, model, best_pars);
    FP_OBJ_FIM.OBJ_sens_to_Pars = OBJ_sens_to_Pars;
    save([dirName,'/FP_OBJ_FIM'], 'FP_OBJ_FIM');
     
%     if toPlotFigs=="yes" 
%         plot_OBJsens(sim_data, model, FP_OBJ_FIM, best_pars, train_data_indx); close all; 
%     end
    %% GA Mut Function
    function mut_Chil = Mutation(parents,~,~,~,~,~,this_Pop,Constrs)
    % Custom Mutation function for G.A. search
    PTB = rand(size(this_Pop(parents,:)))>0.8;
    while min(max(PTB,[],2))==0
        J = find(max(PTB,[],2)==0);
        PTB(J,:) = rand(size(PTB(J,:)))>0.8;
    end

    mut_Chil = this_Pop(parents,:)+...
        PTB.*randn(size(this_Pop(parents,:)))/10^(5*rand)+...
        10^(-3*rand)*randn*(rand(size(this_Pop(parents,:)))>0.95);

    % This mutation function takes the original parents, then chooses 50% of
    % the number to mutate, then mutates these by a normally distributed random
    % variable (multiplicatively). Finally, we add another small normally distributed
    % random variable (again to 50%) in order to push the values away from
    % zero.

    FLP = ones(size(mut_Chil))-2*(rand(size(mut_Chil))>0.99);
    mut_Chil=mut_Chil.*FLP;
    for ii=1:size(mut_Chil,1)
        mut_Chil(ii,:) = max([mut_Chil(ii,:);Constrs.LB]);
        mut_Chil(ii,:) = min([mut_Chil(ii,:);Constrs.UB]);
    end

    end
end