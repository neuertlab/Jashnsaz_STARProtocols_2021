function [Opt_eigs, Opt_names] = get_Opt_eigs(eigs,matrx,m,FIMinvFIM)
eigs=eigs(isnan(eigs)==0); % remove NaN s 
meanU = NaN; medianU = NaN; minU = NaN; maxU = NaN; volU = NaN; normU = NaN; areacumU = NaN; detMatrx = NaN; traceMatrx = NaN; 
try
meanU = mean(eigs);
medianU = median(eigs);
minU = min(eigs);
maxU = max(eigs);
% volU = nthroot(abs(prod(eigs)),length(eigs));
volU = prod(nthroot(abs(eigs), length(eigs))); 
normU = norm(eigs,m);
areacumU = trapz(1:length(eigs),sort(eigs))/length(eigs);
detMatrx = nthroot(det(matrx),length(eigs)); 
traceMatrx = trace(matrx)/length(eigs); 
catch
   disp('missed optimality calc. ... ') 
end
try
Opt_names = {'mean(eigs)', 'median(eigs)', 'min(eigs)', 'max(eigs)', 'nvol(eigs)', ...
    'norm(eigs)', 'nareacum(eigs)', 'ndet', 'ntrace'}; 

switch FIMinvFIM
    
    case 'invFIM'        
        Opt_eigs = [meanU; medianU; minU; maxU; volU; normU; areacumU; detMatrx; traceMatrx];
        
    case 'inveigFIM'        
        Opt_eigs = [meanU; medianU; minU; maxU; volU; normU; areacumU; 1/detMatrx; 1/traceMatrx];
        Opt_names = {'mean(1/eigs)', 'median(1/eigs)', 'min(1/eigs)', 'max(1/eigs)', 'nvol(1/eigs)', ...
    'norm(1/eigs)', 'nareacum(1/eigs)', '1/ndet', '1/ntrace'}; 

    case 'FIM'        
        Opt_eigs = 1./[meanU; medianU; minU; maxU; volU; normU; areacumU; detMatrx; traceMatrx];
        for i=1:length(Opt_names); Opt_names{i} = ['1/',Opt_names{i}]; end
end

catch
   disp('missed optimality asigns. ... ') 
end
end