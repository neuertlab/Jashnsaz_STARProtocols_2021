function hh = plot_ellipses(toSaveFigs, FP_OBJ_FIM) 
global dirName

hh=figure(); clf; set(gcf, 'Units', 'points', 'Position', [0, 0, 1200, 700], 'PaperUnits', 'points', 'PaperSize', [1200, 700]); 
set(gcf,'defaultLineLineWidth',2); set(gca, 'FontName', 'Arial'); set(0,'defaultAxesFontSize',18); dx=0.015; dy=0.02; 
col = {[1 0 0],[.75 0 0],[.5 0 0], [0 1 0],[0 .75 0],[0 .5 0], [0 0 1],[0 0 .75],[0 0 .5]};

pars = FP_OBJ_FIM.best_pars;  
Np = length(pars); 
test_data_indx = FP_OBJ_FIM.test_data_indx; 

for ndata = 1:length(test_data_indx)
    Ellipses = FP_OBJ_FIM.FIM{ndata}.FIM_STATS.Ellipses;  
        leg_label{ndata} = ['D', num2str(test_data_indx(ndata))]; 

    count=1; 
    for i=1:Np
        for j=1:Np
            
            if i==j && ndata == 1
            subplotHJ(Np,Np,count,dy,dx); hold all;
            xlim([0,.55]); ylim([0,.5]); ticks = []; axis off;
            tx=text(.2,.25,['\lambda', num2str(i)]); tx.FontSize = 15;  

            elseif j>i
            subplotHJ(Np,Np,count,dy,dx); hold all;
            try
            plot(Ellipses{i, j}.y, Ellipses{i, j}.x, 'Color', col{test_data_indx(ndata)});
            set(gca,'FontSize',5); %set(gca,'Yscale','log')
%             xlim([-3e6 3e6]); ylim([-1e6 1e6])

            catch
                disp('missed ')
            end
            end
            count = count + 1; 
            
        end
    end

end

if toSaveFigs == "yes"
    figname = [dirName, '/Ellipses']; 
    saveas(gcf,figname, 'epsc')  % save epsc
end

close 
hh=figure(); clf; set(gcf, 'Units', 'points', 'Position', [0, 0, 1200, 700], 'PaperUnits', 'points', 'PaperSize', [1200, 700]); 
set(gcf,'defaultLineLineWidth',2); set(gca, 'FontName', 'Arial'); set(0,'defaultAxesFontSize',18); dx=0.055; dy=0.085;

ncol = ceil(sqrt(Np));
nrow = ceil(Np/ncol);

for ndata = 1:length(test_data_indx)
    Ellipses = FP_OBJ_FIM.FIM{ndata}.FIM_STATS.Ellipses;   

    count=1; 
    for i=1
        for j=1:Np
            
            if j==i
                lgp=subplotHJ(nrow,ncol,count,dy,dx); hold all;      
                plot(NaN,NaN, 'Color', col{test_data_indx(ndata)}); 
                axis off           
            elseif j~=i
                subplotHJ(nrow,ncol,count,dy,dx); hold all;      
            try
            plot(Ellipses{i, j}.y, Ellipses{i, j}.x, 'Color', col{test_data_indx(ndata)});
%             xlim([-3e6 3e6]); ylim([-1e6 1e6])
            xlabel(['log \lambda_{', num2str(j), '}']); ylabel(['log \lambda_{', num2str(i), '}']);
            catch
                disp('missed ')
            end
            end
            count = count + 1; 
            
        end
    end

end

legend(lgp, leg_label); legend(lgp, 'boxoff'); 

if toSaveFigs == "yes"
    figname = [dirName, '/Ellipses2']; 
    saveas(gcf,figname, 'epsc')  % save epsc
end
close 

hh=figure(); clf; set(gcf, 'Units', 'points', 'Position', [0, 0, 1200, 700], 'PaperUnits', 'points', 'PaperSize', [1200, 700]); 
set(gcf,'defaultLineLineWidth',2); set(gca, 'FontName', 'Arial'); set(0,'defaultAxesFontSize',18); dx=0.06; dy=0.085;

ncol = ceil(sqrt(Np/2));
nrow = ceil((Np/2)/ncol);

for ndata = 1:length(test_data_indx)
    Ellipses = FP_OBJ_FIM.FIM{ndata}.FIM_STATS.Ellipses;   

    count=1; 
    i=1; j=2;     
    subplotHJ(nrow,ncol,count,dy,dx); hold all;      
    try
    plot(Ellipses{i, j}.x, Ellipses{i, j}.y, 'Color', col{test_data_indx(ndata)});
%             xlim([-3e6 3e6]); ylim([-1e6 1e6])
    xlabel(['log \lambda_{', num2str(i), '}']); ylabel(['log \lambda_{', num2str(j), '}']);
    catch
        disp('missed ')
    end    
    count = count + 1; 
                       
    for j=3:2:Np                        
            subplotHJ(nrow,ncol,count,dy,dx); hold all;      
            try
            plot(Ellipses{i, j}.x, Ellipses{i, j+1}.x, 'Color', col{test_data_indx(ndata)});
%             xlim([-3e6 3e6]); ylim([-1e6 1e6])
            xlabel(['log \lambda_{', num2str(j), '}']); ylabel(['log \lambda_{', num2str(j+1), '}']);
            catch
                disp('missed ')
            end
            count = count + 1; 
            
    end    

end

if toSaveFigs == "yes"
    figname = [dirName, '/Ellipses3']; 
    saveas(gcf,figname, 'epsc')  % save epsc
end
close 

end