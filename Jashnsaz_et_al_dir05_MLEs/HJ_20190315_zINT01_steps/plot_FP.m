function hh = plot_FP(toSaveFigs, sim_data, model_index, train_data_indx, test_data_indx, params, predictions, minerr, mytraindata, mytrainmodel, toctime) 
global dirName

hh = figure(); clf; set(gcf, 'Units', 'points', 'Position', [0, 0, 1200, 700], 'PaperUnits', 'points', 'PaperSize', [1200, 700]); 
set(gcf,'defaultLineLineWidth',2); set(0,'defaultAxesFontSize',14); set(gca, 'FontName', 'Arial');
dx=.05; dy=.06; 
% plot salt
subplotHJ(3,3,1,dy,dx); 
hold on
for traind=1:length(mytraindata)
    plot(mytraindata{traind}.tt, mytraindata{traind}.salt_out, 'LineWidth', 6, 'color', 'c');
end
xlim([-1,inf])
ylim([0,.6])
ylabel('NaCl [M]');
xlabel('time [min]');
hold off
box off   

dx=.05; dy=.05; 
% draw model
subplotHJ(3,3,2,dy,dx); 
set(gcf,'defaultLineLineWidth',1.5);
network_plot(mytrainmodel.model, model_index)
m_fig=['Model', num2str(model_index), '.png'];
image(imread(['ModelsGraphs/' m_fig]));
title(['Model', num2str(model_index), ' | N_{Params}=', num2str(mytrainmodel.model.n_params)]);
axis normal
axis off
delete(['ModelsGraphs/', m_fig]);

subplotHJ(3,3,3,dy,dx);  
plot_polygon_log((params'), ':*k');
title('fit parameters');


% plot Hog1  
predict_erros = zeros(1, length(sim_data)); 
for testdata = 1:length(sim_data)
    
    subplotHJ(6,3,6+testdata,dy,dx); 
    
    if ismember(testdata, train_data_indx)==1; col = 'r'; leg_label = {'train data', 'fit'}; else
        col = 'g'; leg_label = {'test data', 'predict'}; end
    try
        
    mu_D = sim_data{testdata}.hogp;
    sigma_D = sim_data{testdata}.STDVHog;
    ttt = sim_data{testdata}.tt;    

    Hog1fit = predictions{testdata}.Hog1pp;
    predict_erros(testdata) = predictions{testdata}.predict_error;
    
    p=plot(ttt,mu_D,'k', ttt,mu_D+sigma_D,'k', ttt,mu_D-sigma_D,'k', ttt,Hog1fit, col); hold on;
    p(1).LineWidth = 3; p(2).LineWidth = 0.5; p(3).LineWidth = 0.5; p(4).LineWidth = 3;
    h(1) = plot(NaN,NaN,'k', 'LineWidth',3); h(2) = plot(NaN,NaN, 'Color', col, 'LineWidth',3);
    legend(h, leg_label);legend('boxoff');
    
    catch
        disp('missed')
    end
    hold off; box on
    xlim([0 inf])
    ylim([0 inf])
    ylabel('Hog1pp');
    xlabel('time (min)');
    box on

end

fit_ee_um = mean(predict_erros(train_data_indx)); fit_ee_std = std(predict_erros(train_data_indx)); 
predict_ee_mu = mean(predict_erros(test_data_indx)); predict_ee_std = std(predict_erros(test_data_indx)); 

% plot errors
subplotHJ(6,2,11,dy,dx); 
hold on
errorbar(model_index,fit_ee_um, fit_ee_std, '*r', 'Linewidth',2);
errorbar(model_index,predict_ee_mu, predict_ee_std, '*g', 'Linewidth',2);

xl = (floor(log10(model_index)+1)^2);
ylabel('Model Errors'); xlim([0 model_index+xl]); set(gca,'XTick',[model_index]); box on;
set(gca,'YScale','log'); legend({'fit error', 'predict error'});legend('boxoff');
xlabel('Models')

% plot run time 
subplotHJ(6,2,12,dy,dx); 
hold on
plot([model_index],[minerr], '*k', 'Linewidth',2);
errorbar([model_index],[round(mean(toctime),2)], [round(std(toctime),2)],'ob', 'Linewidth',2);
xl = (floor(log10(model_index)+1)^2);
ylabel('run time | OBJ'); xlabel('Models'); xlim([0 model_index+xl]); set(gca,'XTick',[model_index]); box on;
set(gca,'YScale','log');
legend({'OBJ', 'run time'});legend('boxoff');

if toSaveFigs == "yes"
    figname = [dirName, '/FP_M',num2str(model_index)]; 
    saveas(gcf,figname, 'epsc')  % save epsc
end
end
