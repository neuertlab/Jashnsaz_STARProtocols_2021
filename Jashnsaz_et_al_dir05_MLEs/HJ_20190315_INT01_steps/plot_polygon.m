function polygon(r, col) 
    sides = length(r);
    degrees = 2*pi/sides; % Find the angle between corners in degrees 
    theta = 0:degrees:2*pi-degrees; % Theta changes by the internal angle of the polygon
    h=polarplot(theta, r, col); % Plot
    haxes = get(h,'Parent');
    haxes.ThetaTick = []; 


