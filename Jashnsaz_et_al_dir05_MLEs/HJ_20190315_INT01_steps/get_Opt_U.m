function [Opt_U, Opt_names] = get_Opt_U(par_uncerts,m)
par_uncerts=par_uncerts(isnan(par_uncerts)==0); % remove NaN s 
meanU = NaN; medianU = NaN; minU = NaN; maxU = NaN; volU = NaN; normU = NaN; areacumU = NaN;
try
meanU = mean(par_uncerts);
medianU = median(par_uncerts);
minU = min(par_uncerts);
maxU = max(par_uncerts);
% volU = nthroot(abs(prod(par_uncerts)), length(par_uncerts));
volU = prod(nthroot(abs(par_uncerts), length(par_uncerts))); 
normU = norm(par_uncerts, m);
areacumU = trapz(1:length(par_uncerts),sort(par_uncerts))/length(par_uncerts);
catch
    disp('missed optimality calc. ... ') 
end
try
Opt_U = [meanU; medianU; minU; maxU; volU; normU; areacumU];
Opt_names = {'mean\Delta\lambda', 'median\Delta\lambda', 'min\Delta\lambda', 'max\Delta\lambda', 'nvol\Delta\lambda',...
    'norm\Delta\lambda', 'nareacum\Delta\lambda'}; 
catch
    disp('missed optimality asigns. ... ') 
end
end