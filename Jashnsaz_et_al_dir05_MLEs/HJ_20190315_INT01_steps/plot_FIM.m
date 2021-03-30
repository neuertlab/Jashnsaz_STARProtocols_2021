function hh = plot_FIM(toSaveFigs, model_index, train_data_indx, test_data_indx, params, mytrainmodel,FP_OBJ_FIM) 
global dirName

hh = figure(); clf; set(gcf, 'Units', 'points', 'Position', [0, 0, 1600, 900], 'PaperUnits', 'points', 'PaperSize', [1200, 700]); 
set(gcf,'defaultLineLineWidth',2); set(0,'defaultAxesFontSize',18); set(gca, 'FontName', 'Arial');
% colors 
col = {[1 0 0],[.75 0 0],[.5 0 0], [0 1 0],[0 .75 0],[0 .5 0], [0 0 1],[0 0 .75],[0 0 .5]};
for i=1:8; col2{i} = (0.05*i)*[1 1 1]; end
mkr = {'*', '+', 'o', 'x', 's', 'd', 'h', 'p'}; 

% draw trainData
subplotHJ(14,4,1,.03,.04); hold on;
title('trainData')
for i=1:3    
    txt=text(i,.5,[num2str(.2*i), 'M']); txt.FontSize = 16; txt.HorizontalAlignment='center'; 
end
xlim([-.5 3.5]); ylim([0 1]); axis off; 
   
indx = 1;
SRQ={'Step','Ramp','Quad'}; 
for i=1:3
    subplotHJ(14,4,i*4 + 1,0,.04); hold on;   
    for j=1:3   
        if ismember(indx, train_data_indx) == 1
            bar(j, 1, 'BarWidth', 1, 'FaceColor', col{indx});
            txt=text(j,.5,['D',num2str(indx)]); txt.FontSize = 16; txt.Color = 'W'; 
            txt.FontWeight='bold'; txt.HorizontalAlignment='center'; 
        end
        indx = indx + 1;
    end
    txt=text(0,.5,SRQ{i}); txt.FontSize = 16; txt.HorizontalAlignment='center'; 
    xlim([-.5 3.5]); axis off   
end


% draw testData
subplotHJ(14,4,2,.03,.04); hold on;
title('testData')
for i=1:3    
    txt=text(i,.5,[num2str(.2*i), 'M']); txt.FontSize = 16; txt.HorizontalAlignment='center'; 
end
xlim([-.5 3.5]); ylim([0 1]); axis off; 
   
indx = 1;
SRQ={'Step','Ramp','Quad'}; 
for i=1:3
    subplotHJ(14,4,i*4 + 2,0,.04); hold on;
    
    for j=1:3   
        if ismember(indx, test_data_indx) == 1
            bar(j, 1, 'BarWidth', 1, 'FaceColor', col{indx});
            txt=text(j,.5,['D',num2str(indx)]); txt.FontSize = 16; txt.Color = 'W'; 
            txt.FontWeight='bold'; txt.HorizontalAlignment='center'; 
        end
        indx = indx + 1;
    end
    txt=text(0,.5,SRQ{i}); txt.FontSize = 16; txt.HorizontalAlignment='center'; 
    xlim([-.5 3.5]); axis off   
end
    
% draw model
dx=0.0005; dy=0.051; 
subplotHJ(3,4,3,dy,dx);
set(gcf,'defaultLineLineWidth',1.5);
network_plot(mytrainmodel.model, model_index)
m_fig=['Model', num2str(model_index), '.png'];
image(imread(['ModelsGraphs/' m_fig]));
title(['Model', num2str(model_index), ' | N_{Params}=', num2str(mytrainmodel.model.n_params)]);
axis normal
axis off
delete(['ModelsGraphs/', m_fig]);

% plot params
dy=0.11; sph=subplotHJ(3,4,4,dy,dx);
plot_polygon_log((params'), ':*k');
title('fit parameters');


% optimalities

% uncertainties

% histogram dU
dy=.11; dx=.04;
subplotHJ(4,4,5,dy,dx); hold on;
title('uncertainties')
for tstd = 1:length(test_data_indx)
    H_dU = FP_OBJ_FIM.FIM{tstd}.FIM_STATS.parsUncert;  
    plot(cumsum(sort(H_dU)), '-', 'Color', col{test_data_indx(tstd)}, 'LineWidth', 2);
end   
set(gca,'Yscale', 'log')
% xticks(test_data_indx)
% xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('sorted \Delta\lambda'); ylabel('cumsum')
box on; 

% uncertenties
U_Opts = []; 
opt_names = FP_OBJ_FIM.FIM{1}.FIM_STATS.U_Opt_names;  
for tstd = 1:length(test_data_indx)   
    U_Opts = [U_Opts FP_OBJ_FIM.FIM{tstd}.FIM_STATS.Opt_U];  
end
U_Opts(~isfinite(U_Opts))=NaN; 

dy = .02; subplotHJ(4,4,9,dy,dx); hold on;
for i=1:size(U_Opts,1)
    plot(test_data_indx, U_Opts(i,:), mkr{i}, 'Color', col2{i},'LineWidth', 1.5, 'MarkerSize', 8)
end
set(gca,'Yscale', 'log')
xticks(test_data_indx)
xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('testData'); ylabel('Optimality')
box on; 

% optimalities scores 
[~, UOpt_indx] = sort(U_Opts, 2,'descend'); 
dy=0;dx=0; 
for i=1:size(U_Opts,1)  
    subplotHJ(4*12,4,3*12*4 +(i-1)*4+4*3+1,dy,dx);hold on
    for j=1:size(U_Opts,2)
        bar(j, 1, 'BarWidth', 1,'FaceColor', col{test_data_indx(UOpt_indx(i,j))});  
    end
    txt=text(size(U_Opts,2)+1.8,.5,[opt_names{i}]); txt.FontSize = 12; txt.Color = 'k'; 
    txt.HorizontalAlignment='center'; 
    xlim([-2.5 size(U_Opts,2)+3]); axis off
end

% invFIM

% histogram eigs invFIM
dy=.11; dx=.06;
subplotHJ(4,4,6,dy,dx); hold on;
title('FIM^{-1}')
for tstd = 1:length(test_data_indx)
    eigs_invFIM = FP_OBJ_FIM.FIM{tstd}.FIM_STATS.eigs_invFIM;  
    plot(cumsum(sort(eigs_invFIM)), '-', 'Color', col{test_data_indx(tstd)}, 'LineWidth', 2);
end   
set(gca,'Yscale', 'log')
% xticks(test_data_indx)
% xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('sorted \Delta\lambda'''); ylabel('cumsum')
box on; 

% eigs invFIM
invFIM_Opts = []; 
opt_names = FP_OBJ_FIM.FIM{1}.FIM_STATS.invFIM_Opt_names;  
for tstd = 1:length(test_data_indx)   
    invFIM_Opts = [invFIM_Opts FP_OBJ_FIM.FIM{tstd}.FIM_STATS.Opt_invFIM];  
end
invFIM_Opts(~isfinite(invFIM_Opts))=NaN; 

dy = .02; subplotHJ(4,4,10,dy,dx); hold on; 
for i=1:size(U_Opts,1)
    plot(test_data_indx, invFIM_Opts(i,:), mkr{i}, 'Color', col2{i},'LineWidth', 1.5, 'MarkerSize', 8)
end
set(gca,'Yscale', 'log')
xticks(test_data_indx)
xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('testData'); ylabel('Optimality')
box on; 

% optimalities scores 
[~, invFIM_indx] = sort(invFIM_Opts, 2,'descend'); 
dy=0;dx=0; 
for i=1:size(invFIM_Opts,1)  
    subplotHJ(4*12,4,3*12*4 +(i-1)*4+4*3+2,dy,dx);hold on
    for j=1:size(invFIM_Opts,2)
        bar(j, 1, 'BarWidth', 1,'FaceColor', col{test_data_indx(invFIM_indx(i,j))});  
    end
    txt=text(size(invFIM_Opts,2)+1.8,.5,opt_names{i}); txt.FontSize = 12; txt.Color = 'k'; 
    txt.HorizontalAlignment='center'; 
    xlim([-2.5 size(invFIM_Opts,2)+3]); axis off
    if contains(opt_names{i}, 'trace')
        txt=text(-.6,.5,'A-Opt'); txt.FontSize = 12; txt.Color = 'k'; 
        txt.FontWeight='bold'; txt.HorizontalAlignment='center'; 
    end
end


% FIM inveig

% histogram inveigs FIM
dy=.11; dx=.06;
subplotHJ(4,4,7,dy,dx); hold on;
title('FIM')
for tstd = 1:length(test_data_indx)
    inv_eig_FIM = FP_OBJ_FIM.FIM{tstd}.FIM_STATS.inv_eig_FIM;  
    plot(cumsum(sort(inv_eig_FIM)), '-', 'Color', col{test_data_indx(tstd)}, 'LineWidth', 2);
end   
set(gca,'Yscale', 'log')
% xticks(test_data_indx)
% xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('sorted (1/\Delta\lambda'''')'); ylabel('cumsum')
box on; 

% eigs FIM
inveigFIM_Opts = []; 
opt_names = FP_OBJ_FIM.FIM{1}.FIM_STATS.inveigFIM_Opt_names;  
for tstd = 1:length(test_data_indx)   
    inveigFIM_Opts = [inveigFIM_Opts FP_OBJ_FIM.FIM{tstd}.FIM_STATS.Opt_inveigFIM];  
end
inveigFIM_Opts(~isfinite(inveigFIM_Opts))=NaN; 

dy = .02; subplotHJ(4,4,11,dy,dx); hold on;
for i=1:size(U_Opts,1)
    plot(test_data_indx, inveigFIM_Opts(i,:), mkr{i}, 'Color', col2{i},'LineWidth', 1.5, 'MarkerSize', 8)
end
set(gca,'Yscale', 'log')
xticks(test_data_indx)
xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('testData'); ylabel('Optimality')
box on; 

% optimalities scores 
[~, inveigFIM_indx] = sort(inveigFIM_Opts, 2,'descend'); 
dy=0;dx=0; 
for i=1:size(inveigFIM_Opts,1)  
    subplotHJ(4*12,4,3*12*4 +(i-1)*4+4*3+3,dy,dx);hold on
    for j=1:size(inveigFIM_Opts,2)
        bar(j, 1, 'BarWidth', 1,'FaceColor', col{test_data_indx(inveigFIM_indx(i,j))});  
    end
    txt=text(size(inveigFIM_Opts,2)+1.8,.5,opt_names{i}); txt.FontSize = 12; txt.Color = 'k'; 
    txt.HorizontalAlignment='center'; 
    xlim([-1.5 size(inveigFIM_Opts,2)+3]); axis off
end

% FIM

% histogram eigs FIM
dy=.11; dx=.06;
subplotHJ(4,4,8,dy,dx); hold on;
title('FIM')
for tstd = 1:length(test_data_indx)
    eigs_FIM = FP_OBJ_FIM.FIM{tstd}.FIM_STATS.eigs_FIM;  
    plot(cumsum(sort(eigs_FIM)), '-', 'Color', col{test_data_indx(tstd)}, 'LineWidth', 2);
end   
set(gca,'Yscale', 'log')
% xticks(test_data_indx)
% xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('sorted \Delta\lambda'''''); ylabel('cumsum')
box on; 

% eigs FIM
FIM_Opts = []; 
opt_names = FP_OBJ_FIM.FIM{1}.FIM_STATS.FIM_Opt_names;  
for tstd = 1:length(test_data_indx)   
    FIM_Opts = [FIM_Opts FP_OBJ_FIM.FIM{tstd}.FIM_STATS.Opt_FIM];  
end
FIM_Opts(~isfinite(FIM_Opts))=NaN; 

dy = .02; subplotHJ(4,4,12,dy,dx); hold on; 
for i=1:size(U_Opts,1)
    plot(test_data_indx, FIM_Opts(i,:), mkr{i}, 'Color', col2{i},'LineWidth', 1.5, 'MarkerSize', 8)
end
set(gca,'Yscale', 'log')
xticks(test_data_indx)
xlim([min(test_data_indx)-.5 max(test_data_indx)+.5])
xlabel('testData'); ylabel('Optimality')
box on; 

% optimalities scores 
[~, FIM_indx] = sort(FIM_Opts, 2,'descend'); 
dy=0;dx=0; 
for i=1:size(FIM_Opts,1)  
    subplotHJ(4*12,4,3*12*4 +(i-1)*4+4*3+4,dy,dx);hold on
    for j=1:size(FIM_Opts,2)
        bar(j, 1, 'BarWidth', 1,'FaceColor', col{test_data_indx(FIM_indx(i,j))});  
    end
    txt=text(size(FIM_Opts,2)+1.8,.5,opt_names{i}); txt.FontSize = 12; txt.Color = 'k'; 
    txt.HorizontalAlignment='center'; 
    xlim([-1.5 size(FIM_Opts,2)+3.2]); axis off
    
    if contains(opt_names{i}, 'min(eigs)')
        txtt=text(-.5,.5,'E-Opt'); 
    elseif contains(opt_names{i}, 'det')
        txtt=text(-.5,.5,'D-Opt');
    elseif contains(opt_names{i}, 'trace')
        txtt=text(-.5,.5,'T-Opt');
    end               
    txtt.FontSize = 12; txt.Color = 'k'; 
    txtt.FontWeight='bold'; txt.HorizontalAlignment='center'; 
end

if toSaveFigs == "yes"
    figname = [dirName, '/optimalities_M',num2str(model_index)]; 
    saveas(gcf,figname, 'epsc')  % save epsc
end
end