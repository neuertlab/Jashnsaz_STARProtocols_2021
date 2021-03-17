function hh = plot_OBJs(toSaveFigs, OBJs) 
% plot objectives over the optimization
    global dirName

    hh = figure(); clf; set(gcf, 'Units', 'points', 'Position', [0, 0, 1000, 700], 'PaperUnits', 'points', 'PaperSize', [1000, 700]); 
    set(gcf,'defaultLineLineWidth',2); set(0,'defaultAxesFontSize',18); set(gca, 'FontName', 'Arial'); dx=0.06; dy=0.1; 
    
    titles = {'GA - red', 'FMIN - red', 'GA - full', 'FMIN - full'}; 
    col = {'--*r', '--*g', '--*b', '--*k'}; 
    
    for i=1:4
        subplotHJ(3,2,i,dy,dx);
        plot(OBJs(:,i), col{i}, 'MarkerSize', 8);
        title(titles{i}); xlabel('iteration');  ylabel('OBJ'); 

        subplotHJ(3,1,3,dy,dx); plot(OBJs(:,i), col{i}); hold on
        xlabel('iteration');  ylabel('OBJ'); legend(titles); legend('boxoff'); 
    end
    
    if toSaveFigs == "yes"
        figname = [dirName, '/OBJs']; 
        saveas(gcf,figname, 'epsc')  % save epsc
    end
end
