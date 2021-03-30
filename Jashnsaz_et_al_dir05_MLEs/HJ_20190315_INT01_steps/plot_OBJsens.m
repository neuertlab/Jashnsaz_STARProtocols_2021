function plot_OBJsens(sim_data, model, FP_OBJ_FIM, params, train_data_indx) 
global dirName

hh=figure(); clf; set(gcf, 'Units', 'points', 'Position', [0, 0, 1200, 700], 'PaperUnits', 'points', 'PaperSize', [1200, 700]); 
set(gcf,'defaultLineLineWidth',2); set(gca, 'FontName', 'Arial'); set(0,'defaultAxesFontSize',18); dx=0.055; dy=0.085;


col = {[1 0 0],[.75 0 0],[.5 0 0], [0 1 0],[0 .75 0],[0 .5 0], [0 0 1],[0 0 .75],[0 0 .5]};

Np = model.n_params;
ncol = ceil(sqrt(Np));
nrow = ceil(Np/ncol);

OBJ_sensitivity = FP_OBJ_FIM.OBJ_sens_to_Pars;
for nData=1:length(sim_data)
    
    if ismember(nData, train_data_indx)==1; leg_label{nData} = 'train data'; else
        leg_label{nData} = 'test data'; end
    
    solutions = OBJ_sensitivity{nData}; 
    for param_num=1:length(params)
        pchange = params(param_num);
        subplotHJ(nrow,ncol,param_num,dy,dx); hold all;      
        h(nData)=plot(solutions{param_num}.pvec_change,solutions{param_num}.J, 'Color',col{nData}, 'LineWidth',2.5);
        plot([pchange,pchange],[1e-10,max(solutions{param_num}.J)],'Color',.4*[1 1 1],'LineStyle','--');
        h2(nData) =   plot(NaN,NaN,'Color',col{nData}, 'LineWidth',3);
        xlabel(['\lambda_{', num2str(param_num), '}']);
        ylabel(['J(\lambda_{', num2str(param_num), '})']);
        xlow(nData,param_num) = min(solutions{param_num}.pvec_change);
        xhigh(nData,param_num) = max(solutions{param_num}.pvec_change);
        ylow(nData,param_num) = min(solutions{param_num}.J);
        yhigh(nData,param_num) = max(solutions{param_num}.J);
        xlim([0.95 1.05].*[min(xlow(:,param_num)) max(xhigh(:,param_num))]);
        ylim([0.9 1.1].*[min(ylow(:,param_num)) max(yhigh(:,param_num))]);
%         set(gca,'Yscale','log')
    end
end
xlim([0.95 1.05].*[min(xlow(:,param_num)) 2*max(xhigh(:,param_num))-min(xlow(:,param_num))]);
lgd = legend(h,leg_label);legend('boxoff');
lgd.FontSize = 8;


figname = [dirName, '/OBJvsPars']; 
% % savefig(figname); 
print(figname,'-dpng');

end