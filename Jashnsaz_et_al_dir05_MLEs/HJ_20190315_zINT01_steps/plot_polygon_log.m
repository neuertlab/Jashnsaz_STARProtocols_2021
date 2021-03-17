function polygon_log(r, col) 
sides = length(r);
degrees = 2*pi/sides; % Find the angle between corners in degrees 
theta = 0:degrees:2*pi-degrees; % Theta changes by the internal angle of the polygon

log_r = log10(r); minr = floor(min(log_r)); maxr = ceil(max(log_r));
r = (log_r - minr); 

lb=minr+1; ub = maxr; mb = mean([lb,ub]);%indexes
llb=min(r); uub = (max(r)); % real values 

h=polarplot(theta, r, col, 'LineWidth', 0.05); % Plot
haxes = get(h,'Parent');
tikks = linspace(llb,uub,3); 
haxes.RTick = tikks;
haxes.RTickLabel = {num2str(lb),num2str(mb),num2str(ub)};
haxes.ThetaTick = radtodeg(theta); 
for pn=1:sides
    params_names{pn}=['\lambda', num2str(pn)];
end
haxes.ThetaTickLabels = params_names;
haxes.GridLineStyle = ':'; haxes.GridColor = 'k'; 



