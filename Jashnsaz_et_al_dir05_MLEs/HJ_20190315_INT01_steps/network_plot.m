
% this function takes a model as input and draws its graph. m_index is for
% the purpose of saving the graph with corresponding index. 

function network_plot = network_plot(model, m_index) 
    % conncention matrix
    %close all
    mkdir('ModelsGraphs');
    figure(1e8)
    A = model.A;
    B = model.B;
    C = model.C; 

    % get existing activations/inactivations among the nodes of the network.
    actIND=find(A==1);
    inactIND=find(A==-1);
    [Iact,Jact]=ind2sub(size(A),actIND);
    [Iinact,Jinact]=ind2sub(size(A),inactIND);
    
    % get existing activations/inactivations of top nodes from the inputs.
    aInput = find(B==1);
    iInput = find(B==-1);
    
    % get existing activations/inactivations of nodes from the basals.
    aBasal = find(C==1);
    iBasal = find(C==-1);
    
    % pick one of the 3-, 4-, 5-, or 6-node base models with specified
    % nodes positions.
    switch model.n_nodes
        case 3
            Nodes=[0.2,0.6;
                0.6,0.6;
                0.4,0.4];

        case 4
            Nodes=[0.2,0.6;
                0.6,0.6;
                0.4,0.4;
                0.4,0.2];

        case 5 
            if length(B(B~=0))==2 % two sensors
                Nodes=[0.2,0.6;
                    0.7,0.7;
                    0.6,0.6;
                    0.4,0.4;
                    0.4,0.2];
                
            elseif length(B(B~=0))==3 % 3 sensors
                Nodes=[0.2,0.6;
                    0.48,0.6;
                    0.6,0.6;
                    0.4,0.4;
                    0.4,0.2];
            end            
        
        case 6
            Nodes=[0.2,0.6;
                0.5,0.7;
                0.7,0.7;
                0.6,0.6;
                0.4,0.4;
                0.4,0.2];
    end
    
    hold on
    
    sz=3000;
    NodesFaceColors = [0 0.8 0.4]; 
    RegulationsColors = .55*[1 1 1]; 
    InputsColors = [0 0 0.8]; 
    BasalsColors = .8*[1 1 1]; 
    RegsLinesWidth = 3; 
    NodesEdgeLineWidth = 0.01; 
    
    % plot nodes
    s=scatter(Nodes(:,1),Nodes(:,2), sz, 'MarkerEdgeColor', 'k',...
                  'MarkerFaceColor', NodesFaceColors,...
                  'LineWidth',NodesEdgeLineWidth);
              
      lbx=min(Nodes(:,1));
      ubx=max(Nodes(:,1));
      lby=min(Nodes(:,2));
      uby=max(Nodes(:,2));
              
    xlim([lbx ubx]);
    ylim([lby uby+0.05]);
    
    alpha(s,0.7); 
    
    for ii=1:size(A,1)
        text(Nodes(ii,1)-.007,Nodes(ii,2),num2str(ii), 'FontSize',26);
    end
    
    % normalize coordinates of the nodes to draw connections
    pos = get(gca, 'Position');
    Nodes(:,1) = (Nodes(:,1) - min(xlim))./diff(xlim) * pos(3) + pos(1);               
    Nodes(:,2) = (Nodes(:,2) - min(ylim))./diff(ylim) * pos(4) + pos(2);  
  
    dd=0.0565; 
%   draw inputs
%   ac=annotation('arrow', [0, 1], [0.999, 0.999], 'LineStyle', '--', 'LineWidth', LinesWidth, 'HeadStyle', 'cback1');
    for i=1:length(aInput)
        ac=annotation('arrow', [Nodes(aInput(i),1), Nodes(aInput(i),1)], [min(1,Nodes(aInput(i),2)+3*dd), Nodes(aInput(i),2)+dd], 'LineStyle', '--', 'LineWidth', RegsLinesWidth, 'HeadStyle', 'cback1');
        ac.Color = InputsColors;
        ac.HeadLength = 16; 
        ac.HeadWidth = 18; 
    end
    
    for i=1:length(iInput)
        inac=annotation('arrow', [Nodes(iInput(i),1), Nodes(iInput(i),1)], [min(1,Nodes(iInput(i),2)+3*dd), Nodes(iInput(i),2)+dd], 'LineStyle', '--', 'LineWidth', RegsLinesWidth, 'HeadStyle', 'rectangle');
        inac.Color = InputsColors;
        inac.HeadLength = 4; 
        inac.HeadWidth = 18; 
    end
    
    % draw basal regulations
    for i=1:length(aBasal)
        bac=annotation('arrow', [Nodes(aBasal(i),1)-2.2*dd, Nodes(aBasal(i),1)-1*dd], [min(1,Nodes(aBasal(i),2)), Nodes(aBasal(i),2)], 'LineStyle', ':', 'LineWidth', RegsLinesWidth, 'HeadStyle', 'cback1');
        bac.Color = BasalsColors;
        bac.HeadLength = 10; 
        bac.HeadWidth = 18; 
    end
    
    for i=1:length(iBasal)
        binac=annotation('arrow', [Nodes(iBasal(i),1)-2.2*dd, Nodes(iBasal(i),1)-1*dd], [min(1,Nodes(iBasal(i),2)), Nodes(iBasal(i),2)], 'LineStyle', ':', 'LineWidth', RegsLinesWidth, 'HeadStyle', 'rectangle');
        binac.Color = BasalsColors;
        binac.HeadLength = 4; 
        binac.HeadWidth = 18; 
    end
   
    
    %  draw activation lines
    for i=1:length(Iact)
        dx=(Nodes(Jact(i),1) - Nodes(Iact(i),1)); dy=(Nodes(Jact(i),2) - Nodes(Iact(i),2)); 
        d=sqrt(dx^2 + dy^2); 
        sinus=dy/d; cosin=dx/d; ddx=dd*cosin; ddy=dd*sinus; 
        sinus=dy/d; cosin=dx/d; ddx=1.05*dd*cosin; ddy=1.05*dd*sinus; 
        a1=annotation('arrow', [Nodes(Jact(i),1)-ddx, Nodes(Iact(i),1)+ddx], [Nodes(Jact(i),2)-ddy, Nodes(Iact(i),2)+ddy], 'LineWidth', RegsLinesWidth, 'HeadStyle', 'cback1');
        a1.Color = RegulationsColors;
        a1.HeadLength = 16; 
        a1.HeadWidth = 18; 
    end
    
    % draw inactivation lines 
    for i=1:length(Iinact)
        dx=(Nodes(Jinact(i),1) - Nodes(Iinact(i),1)); dy=(Nodes(Jinact(i),2) - Nodes(Iinact(i),2)); 
        d=sqrt(dx^2 + dy^2);
        sinus=dy/d; cosin=dx/d; ddx=1.05*dd*cosin; ddy=1.05*dd*sinus; 
%         sinus=dy/d; cosin=dx/d; ddx=1*dd*cosin; ddy=1*dd*sinus; 
        a2=annotation('arrow', [Nodes(Jinact(i),1)-ddx, Nodes(Iinact(i),1)+ddx], [Nodes(Jinact(i),2)-ddy, Nodes(Iinact(i),2)+ddy], 'LineWidth', RegsLinesWidth, 'HeadStyle', 'rectangle');
        a2.Color = RegulationsColors;
        a2.HeadLength = 4; 
        a2.HeadWidth = 18; 
    end
    
    axis normal
    axis off
    figname=['ModelsGraphs/Model', num2str(m_index)];
    saveas(gcf, [figname, '.png'])
    %disp('done')
    close(figure(1e8))
end



