function [parsUncert,eig_invFIM,eig_FIM,inv_eig_FIM,invFIM,Ellipses,UncertaintyM,efail] = get_FIMSTATS(FIM,pars,free_params)
% get ellipses and calculate projected_FIM
Nellipse = nchoosek(length(free_params),2);

Total_EllipseAreaX = [];
Total_EllipseAreaY = [];
errorcount=0;
eyc = length(FIM);
invFIM = eye(eyc)/FIM;

UncertaintyM = NaN(eyc,eyc,2); 
for i=1:length(pars)
    lvec{i} =[];
end
check = zeros(Nellipse,2);

for i=1:length(pars)
    c=0;c1=0;
    for j=1:length(pars)
        if j>i
         
            subset_free_params =[free_params(i) free_params(j)];
%             xc = log(pars(subset_free_params(1)));
%             yc = log(pars(subset_free_params(2)));            
            c=c+1;c1=c1+1;
            try
                h = error_ellipse(invFIM(subset_free_params,subset_free_params),log(pars(subset_free_params)),'conf',.95);
                x = h.XData; y = h.YData;
                Ellipses{i,j}.x = x;
                Ellipses{i,j}.y = y;

                dlamdaY = range(y);
                dlamdaX = range(x);

                UncertaintyM(i,j,1) = dlamdaX; 
                UncertaintyM(i,j,2) = dlamdaY; 


                HK1 = check(check(:,1)>0,1);
                HK2 = check(check(:,2)>0,2);
                HK = [HK1,HK2];
                checkpass = 1;
                for chk = 1: length(HK1)
                   if (or(and(HK(chk,1) == i,HK(chk,2) == j),and(HK(chk,2) == i,HK(chk,1) == j)))
                        checkpass = 0;
                   end
                end
                if (checkpass == 1)

                    Total_EllipseAreaX(i,j) = dlamdaX; 
                    Total_EllipseAreaY(i,j) = dlamdaY;
                    lvec{i} = horzcat(lvec{i}, dlamdaX);
                    lvec{j} = horzcat(lvec{j}, dlamdaY);
                    check(c1,1) = i;
                    check(c1,2) = j;
                end
                close
            catch
                errorcount=errorcount+1;
                close
            end
        end
    end
end

for i=1:length(lvec)
    for j=1:length(lvec{i})
        lvecM{i,j} = lvec{i}(j);
    end
end

%[V,D] = eig(invFIM(subset_free_params,subset_free_params)); less accurate than svd

[~,S,~] = svd(FIM);
eig_FIM = diag(S); % get eigenvalues of FIM
inv_eig_FIM = 1./eig_FIM; 

[~,invS,~] = svd(invFIM);
eig_invFIM = diag(invS); % get eigenvalues of invFIM

for nvector = 1:length(lvec)
   lvec2{nvector} =  mean(lvec{nvector});
   [temp1,temp2] = mode(fix(lvec{nvector}*1000)/1000);
   lvec3{nvector} = temp1;
   percent(nvector) = temp2/length(lvec{nvector});
end

if (min(percent >=0.9))
   for nvector = 1:length(lvec)
   lvec{nvector} = lvec3{nvector};
   end
else
   for nvector = 1:length(lvec)
   lvec{nvector} = lvec2{nvector};
   end
end

parsUncert = [cell2mat(lvec)]'; 

efail = 100*errorcount/(Nellipse); % failor % rate to get individual ellipse
end