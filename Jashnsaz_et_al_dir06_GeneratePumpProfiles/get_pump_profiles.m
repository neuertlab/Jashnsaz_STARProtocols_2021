function get_pump_profiles = get_pump_profiles()
clc; close all
warning('off','all'); 

%% enter the preperties of the NaCl profile to be generated: 
kinetics = 2; % polynomial order of input profile; for linear (t1) =1; quadratic (t2) =2, root function (sqrt(t)) =0.5 etc
ProfileType = 't2'; % 't1', 't2', will be used to create a name for directory to save code outputs
FinalMolarity = .4; % [M] Final molarity concentration of the desired profile to be reached during the experiment
StartMolarity = 0; % [M] Starting molarity concentration of the desired profile. The current code is optimized for 0 starting value. 
Profile_duration = 25; % [min] total duration of the desired profile to be applied to the cells during the experiment;
V0 = 30; % [mL] starting volume of the mixing flask for time-lapse setup(or cells in the dish for time-point setup). 
NaCl_stock = 5.00; % [M] molarity of concentrated stimulus to be loaded to the syringe. 
p2_rate = 0.1; % [mL/min] Pump2 rate (output pump) [mL/min]
N = 40; % total available number of phases (intervals) of the pump 1 (keep 40 or 250)
dvDEC = 5; %  For RATE_and_VOL (uL/min, uL), for 2 decimal place use value 5, and for 1 decimal place use value 4, 
%% this section is only relevant for time-point setup, not relevant for time-lapse
sampling_time_points = [0]; % [min] time points at which to take out samples. enter 0 if you don't take out samples [for time-lapse setup].
% [1,2,4,6,8,10,15,20,25,30,35,40,45,50,55]
samples_volumes = 0; % [mL] sample volume to take out at each time point

%% calculate total exposure (area under the profile, mM*min) for a linear ramp of given duration 
% and readjust the quadratic (or other profiles) duration to have the same
% total exposure as that of the linear ramp. 
% % tot_exposure_ramp = Profile_duration*(FinalMolarity-StartMolarity)/2; 
% % 
% % timesteps=(1/60)*1e-3; um = (FinalMolarity-StartMolarity)/Profile_duration^kinetics;
% % timepoints=0:timesteps:Profile_duration*5; 
% % m = StartMolarity + um*timepoints.^kinetics;
% % 
% % tot_exposure = 0; ii=1; 
% % while tot_exposure<tot_exposure_ramp
% %     tot_exposure = tot_exposure + timesteps*m(ii); ii=ii+1; 
% % end
% % Profile_duration = timepoints(ii); clear m timesteps timepoints; 
% % disp(['The desired profile duration is ', num2str(Profile_duration/60), 'hours (', num2str(Profile_duration),'min).']); 
% % Profile_duration = max(sampling_time_points); % total duration of the NaCl profile applied to the samples during the experiment (minute)

%% set the timepoints and initialize the parameters. 
dt=Profile_duration/N; 
t = dt:dt:N*dt;
t = [0 t]'; 

N=length(t);    % total number of phases (intervals) of the pump to be used. 
ddt = zeros(N,1); % time intervals for each of the N pump phases (M)
m = zeros(N,1); % molarity of the flask at the end of each of the N pump phases (M)
pump2_salt_out = zeros(N,2); % salt taken out through pump2 during each interval (mg). 
sampling_salt_out = zeros(N,2); % salt taken out through sample (mg).  
dv = zeros(N,2); % dispensed volume during each of the N pump phases (mL)
k = zeros(N,2); % pump rates during each of the N pump phases (mL/min)
v = zeros(N,2); % cumulitive dispensed volume at the end of each of the N pump phases (mL)
vv = zeros(N,2); % cumulitive sample volume change through pump 1 and pump2  (mL)
flask_vol = zeros(N,2); % total volume in the flask at the end of each of the N pump phases (mL) [V0 + pump 1 - pump2 - sample out]
sum_samples_out_volumes = zeros(N,2); % total volume in the flask at the end of each of the N pump phases (mL) [V0 + pump 1 - pump2 - sample out]
mm = zeros(N,2); % Calculated molarity of the flask at the end of each of the N pump phases (M)

% initial values
m0 = StartMolarity; 
ddt(1) = 0; m(1) = m0; pump2_salt_out(1,:) = 0; sampling_salt_out(1,:) = 0;
dv(1,:) = 0; k(1,:) = 0; v(1,:) = 0; vv(1,:) = V0; mm(1,:)=m0; flask_vol(1,:)=V0; mmm(1,:)=m0; 
%%

um = (FinalMolarity-m0)/Profile_duration^kinetics; %coefficient to acheive specified final molarity at the end of any kinetic profile (M/minute)


index_count = 1; 
for alpha = [1 1]
    
    ss = 1; saltP2=0; 
    for phase=2:N
        
        dt = t(phase) - t(phase-1);
        ddt(phase) = dt; 

        m(phase) = m0 + um*t(phase)^kinetics;
        
        pump2_salt_out(phase, index_count) = .5*( m(phase) + m(phase-1) )*p2_rate*dt;
        
        if sampling_time_points ~= 0 % taking out samples 
            if t(phase-1) == sampling_time_points (ss)
                sampling_salt_out(phase, index_count) = m(phase-1)*samples_volumes;
                ss = ss + 1; 
            else
                sampling_salt_out(phase, index_count) = 0;
            end
            ExpType = 'Bulk'; 
        else 
            ExpType = 'TimeLapse'; 
        end
        
        sum_samples_out_volumes(phase, index_count) = samples_volumes*(ss-1);
        
        dv(phase, index_count) = ( m(phase)*( vv(phase-1, index_count) ...
            - p2_rate*dt - samples_volumes*(ss-1) ) - NaCl_stock*v(phase-1, index_count) ...
            + sum(pump2_salt_out(1:phase,index_count)) + sum(sampling_salt_out(1:phase, index_count)) )/(NaCl_stock-m(phase)); 
        if index_count == 2; dv(phase, index_count) = round(dv(phase, index_count-1),dvDEC);end
        k(phase, index_count) = dv(phase, index_count)/dt; 
        if index_count == 2; 
            k(phase, index_count) = round(dv(phase, index_count)/dt,dvDEC);
            if k(phase, index_count)>=1
                k(phase, index_count) = round(dv(phase, index_count)/dt,dvDEC-2);
            end
        end
        if k(phase, index_count) < 10^-dvDEC; k(phase, index_count) = 10^-dvDEC; end; 
        dv(phase, index_count) = k(phase, index_count)*dt; 
        if index_count == 2; 
            dv(phase, index_count) = round(dv(phase, index_count),dvDEC);
        end

        v(phase, index_count) = v(phase-1, index_count) + dv(phase, index_count); 
        vv(phase, index_count) = vv(phase-1, index_count) + dv(phase, index_count) - p2_rate*dt;  
        flask_vol(phase, index_count) = V0 + v(phase, index_count) - p2_rate*dt - sum_samples_out_volumes(phase, index_count); 
        mm(phase, index_count) = ( NaCl_stock*(v(phase, index_count)) - sum(pump2_salt_out(1:phase,index_count)) - sum(sampling_salt_out(1:phase, index_count)) )/( vv(phase, index_count) - sum_samples_out_volumes(phase, index_count));
        saltP2 = saltP2 + 0.5*((m(phase-1)+m(phase))*p2_rate*dt); 
        mmm(phase, index_count) = (NaCl_stock*v(phase, index_count)-saltP2 - sum(sampling_salt_out(1:phase, index_count)))/(V0+v(phase, index_count)-phase*p2_rate*dt-sum_samples_out_volumes(phase, index_count));  
        mmm(phase, index_count) = max(0, mmm(phase, index_count)); mm(phase, index_count) = max(0, mm(phase, index_count));

    end
    index_count = index_count + 1; 
end

t = t(2:end); ddt = ddt(2:end); m = m(2:end); pump2_salt_out=pump2_salt_out(2:end,:); sampling_salt_out=sampling_salt_out(2:end,:); 
dv=dv(2:end,:); k=k(2:end,:); v=v(2:end,:); vv=vv(2:end,:); flask_vol=flask_vol(2:end,:); mm=mm(2:end,:); sum_samples_out_volumes=sum_samples_out_volumes(2:end,:); mmm=mmm(2:end,:);

% dv(1,:)=dv(2,:)*(dv(2,:)/dv(3,:)); k(1,:)=k(2,:)*(k(2,:)/k(3,:));
%% convert units and calculate errors
kk=1000*k; % convert pump rate to uL/min
ttt=ddt*60; %time interval at each step (sec). 
dv = 1000*dv; % convert volum to uL

NaCl_error1=100*abs(mm(:,1)-m(:,1))./max(.05,m(:,1)); % error in NaCl calculation 1. 
NaCl_error2=100*abs(mmm(:,1)-m(:,1))./max(.05,m(:,1)); % error in NaCl calculation 2. 

NaCl_error3=100*abs(mm(:,2)-m(:,1))./max(.05,m(:,1)); % error in NaCl calculation 1. 
NaCl_error4=100*abs(mmm(:,2)-m(:,1))./max(.05,m(:,1)); % error in NaCl calculation 2.

%% save data 
% save data to be loaded to the pump (to excel sheet)
N=size(t,1);

profile = zeros(N, 3);
profile(:,1) = kk(:,1); %  pump rates in (uL/min) 
profile(:,2) = dv(:,1); %  dispensed volume at each step (mL). 
profile(:,3) = ttt; % time intervals at each step (sec). 


dirName=[ProfileType, '_', num2str(Profile_duration), 'min_', num2str(FinalMolarity), 'M'];
mkdir(dirName); 

fileName=[ExpType, '_', ProfileType, '_', num2str(Profile_duration), 'min_', num2str(FinalMolarity),'M_loadFile.xlsx'];
xlswrite([dirName, '/',fileName],profile);

profile = zeros(N, 3);
profile(:,1) = kk(:,2); %  pump rates in (uL/min) 
profile(:,2) = dv(:,2); %  dispensed volume at each step (mL). 
profile(:,3) = ttt; % time intervals at each step (sec). 

xlswrite([dirName, '/','rounded_', fileName],profile);

% save all data 
profile = NaN(N, 7*2+1);
profile(:,1) = [1:N]'; % pump phase 
profile(:,2) = t; % time (min)
profile(:,3) = kk(:,1); %  pump rates in (uL/min) 
profile(:,4) = dv(:,1); %  dispensed volume at each step (mL).
profile(:,5) = v(:,1); %  cumulutive dispensed volume up to each step (mL). 
profile(:,6) = m(:,1); % theoretical profile (M). 
profile(:,7) = mm(:,1); % generated profile (M). 
profile(:,8) = mmm(:,1); % generated profile (M). 

profile(:,10) = [1:N]'; % pump phase 
profile(:,11) = t; % time (min)
profile(:,12) = kk(:,2); %  pump rates in (uL/min) 
profile(:,13) = dv(:,2); %  dispensed volume at each step (mL).
profile(:,14) = v(:,2); %  cumulutive dispensed volume up to each step (mL). 
profile(:,15) = m(:,1); % theoretical profile (M). 
profile(:,16) = mm(:,2); % generated profile (M). 
profile(:,17) = mmm(:,2); % generated profile (M). 

profilesHeader =['phase' ,'time (min)','pump rate (uL/min)', 'Disp. vol. (mL)', 'Cum. disp. vol. (mL)', 'NaCl (M)', 'NaCl (M)', '',...
    'phase' ,'time (min)','pump rate (uL/min)', '[Disp. vol.] (mL)', 'Cum. disp. vol. (mL)', 'NaCl (M)', 'NaCl (M)'];
fileNameXlsx=[ProfileType, '_', num2str(Profile_duration), 'min_', num2str(FinalMolarity),'M', '.xlsx'];

xlswrite([dirName, '/', fileNameXlsx],profile,profilesHeader);

%% time point for measurments

tt=t*60; % convert time unit to seconds 
mmins=zeros(N,1);
sseconds=zeros(N,1);

for i=1:N
    mmins(i)=floor(tt(i)/60); 
    sseconds(i) = rem(tt(i),60);
end
mmins=mmins;
sseconds=sseconds;

pump_profile = zeros(N, 4);

pump_profile(:,1) = mmins; 
pump_profile(:,2) = sseconds; 
pump_profile(:,3) = kk(:,1); 
pump_profile(:,4) = v(:,1); 

DataHeader =['mm' ,'ss','pump rate (uL/min)', 'Tot. Disp. Vol. (mL)'];
xlswrite([dirName, '/', 'MeasurmentsSheet.csv'],pump_profile, DataHeader);
xlswrite([dirName, '/','Experiment2.csv'],v(:,1));

%%
mm_exp = zeros(N,1); % Calculated molarity of NaCl from measured dispensed volumes (M)
if exist([dirName, '/','Experiment.csv']) == 2
    v_exp=csvread([dirName, '/','Experiment.csv']);  
    for phase=1:N
       mm_exp(phase) = ( NaCl_stock*(v_exp(phase)) - sum(pump2_salt_out(1:phase, 1)) - sum(sampling_salt_out(1:phase, 1)) )/(V0 + v_exp(phase, 1) - (phase)*p2_rate*ddt(phase)- sum_samples_out_volumes(phase, 1));
    end
    Expmnt_NaCl_error=100*abs(mm_exp(:,1)-m(:,1))./m(:,1); % error in NaCl measured from experiment. 

end
    

%% plot figures

ProfileName=[ProfileType, '-', num2str(Profile_duration), 'min-', num2str(FinalMolarity), ...
    'M-NaCl']; %_FlaskVolume', num2str(V0), 'mL'

set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 18, 18], 'PaperUnits', 'centimeters', 'PaperSize', [18, 18]); 
dx=0.06; dy=0.075;
lw = 1; mksz = 3; 

legend_label1 = {'Theory', 'dv rounded'};
legend_label2 = {'Theory', 'Calc1.', 'Calc2.', 'Calc1. dv rounded','Calc2. dv rounded'};
legend_label2 = {'Theory', 'Calc1. dv rounded','Calc2. dv rounded'};

subplotHJ(3,3,1,dy,dx)
plot(t, m, '-*c', 'Linewidth', lw, 'MarkerSize',mksz); 
xlabel('Time (min)')
ylabel('NaCl [M]')
title(ProfileName)
xlim([-.5 Profile_duration+.5]) 
ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label1{1}, 'Location','northwest'); legend('boxoff');


subplotHJ(3,3,2,dy,dx)
hold on
% plot(t, dv(:,1), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, dv(:,2), ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

if sampling_time_points ~= 0
    for i=1:length(sampling_time_points)
        plot([sampling_time_points(i) sampling_time_points(i)], [min(min(dv)) max(max(dv))], ':k')
    end
end
xlabel('Time (min)')
ylabel('P1 Disp. volume (\muL)')
title('Pump1 dispensed volume')
xlim([-.5 Profile_duration+.5]) 
%ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label1{2}, 'Location','northwest'); legend('boxoff');


subplotHJ(3,3,3,dy,dx)
hold on

% plot(t, v(:,1), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, v(:,2), ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

if exist([dirName, '/','Experiment.csv']) == 2
    plot(t, v_exp, '--+k', 'Linewidth', 1)
end

xlabel('Time (min)')
ylabel('P1 CDV (mL)')
title('Pump1 Cumulitive Dispensed Volume')
xlim([-.5 Profile_duration+.5]) 
ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

legend(legend_label1{2}, 'Location','northwest'); legend('boxoff');
box on

subplotHJ(3,3,4,dy,dx)
hold on
% plot(t, flask_vol(:,1), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, flask_vol(:,2), ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

xlabel('Time (min)')
ylabel('flask volume (mL)')
title('V0 + P1 - P2 - Samples')
xlim([-.5 Profile_duration+.5]) 
%ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label1{2}, 'Location','northwest'); legend('boxoff');



subplotHJ(3,3,5,dy,dx)
hold on
% plot(t, kk(:,1), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, kk(:,2), ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

if sampling_time_points ~= 0
    for i=1:length(sampling_time_points)
        plot([sampling_time_points(i) sampling_time_points(i)], [min(min(kk)) max(max(kk))], ':k')
    end
end

xlabel('Time (min)')
ylabel('Pump1 rate (\muL/min)')
xlim([-.5 Profile_duration+.5]) 
%ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label1{2}, 'Location','northwest'); legend('boxoff');



subplotHJ(3,3,6,dy,dx)
hold on
plot(t, m, '-*c', 'Linewidth', 2*lw, 'MarkerSize',mksz)
% plot(t, mm(:,1), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
% plot(t, mmm(:,1), ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

plot(t, mm(:,2), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, mmm(:,2), ':ob', 'Linewidth', lw, 'MarkerSize',mksz)

if exist([dirName, '/','Experiment.csv']) == 2
    plot(t, mm_exp, '--+k', 'Linewidth', 1)
end
xlabel('Time (min)')
ylabel('NaCl [M]')
xlim([-.5 Profile_duration+.5]) 
ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label2, 'Location','northwest'); legend('boxoff');
title('Constructed NaCl Profile')

subplotHJ(3,4,9,dy,dx)
hold on
plot(t, 1000*diff([m0;m])/dt, '-*c', 'Linewidth', lw, 'MarkerSize',mksz)
% plot(t, diff([m0;mm(:,1)])/dt, '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
% plot(t, diff([m0;mmm(:,1)])/dt, ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

plot(t, 1000*diff([m0;mm(:,2)])/dt, '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, 1000*diff([m0;mmm(:,2)])/dt, ':ob', 'Linewidth', lw, 'MarkerSize',mksz)

if exist([dirName, '/','Experiment.csv']) == 2
    plot(t, mm_exp, '--+k', 'Linewidth', 1)
end
xlabel('Time (min)')
ylabel('d(NaCl)/dt [mM/min]')
xlim([-.5 Profile_duration+.5]) 
ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label2, 'Location','northwest'); legend('boxoff');
title('rates')

subplotHJ(3,4,10,dy,dx)
hold on
% plot(t, pump2_salt_out(:,1), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, pump2_salt_out(:,2), ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

xlabel('Time (min)')
ylabel('P2 salt out (mg)')
title('Pump2 salt out')
xlim([-.5 Profile_duration+.5]) 
ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label1{2}, 'Location','northwest'); legend('boxoff');

subplotHJ(3,4,11,dy,dx)
hold on
% plot(t, sampling_salt_out(:,1), '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, sampling_salt_out(:,2), ':*b', 'Linewidth', lw, 'MarkerSize',mksz)
% draw sampling points
if sampling_time_points ~= 0
    for i=1:length(sampling_time_points)
        plot([sampling_time_points(i) sampling_time_points(i)], [min(min(sampling_salt_out)) max(max(sampling_salt_out))], ':k')
    end
end
xlabel('Time (min)')
ylabel('Sampling salt out (mg)')
title('Sampling salt out')
xlim([-.5 Profile_duration+.5]) 
ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend(legend_label1{2}, 'Location','northwest'); legend('boxoff');


subplotHJ(3,4,12,dy,dx)
hold on
% plot(t, NaCl_error1, '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
% plot(t, NaCl_error2, ':*b', 'Linewidth', lw, 'MarkerSize',mksz)

plot(t, NaCl_error3, '--sr', 'Linewidth', lw, 'MarkerSize',mksz)
plot(t, NaCl_error4, ':ob', 'Linewidth', lw, 'MarkerSize',mksz)

if exist([dirName, '/','Experiment.csv']) == 2
    plot(t, Expmnt_NaCl_error, '--+k', 'Linewidth', 1)
end
xlabel('Time (min)')
ylabel('% of errors in NaCl')
xlim([-.5 Profile_duration+.5]) 
ylim([0 inf])
xticks([0:round(Profile_duration/6):Profile_duration]);    

box on
legend({legend_label2{2}, legend_label2{3}}, 'Location','northwest'); legend('boxoff');

set(findall(gcf,'-property','FontSize'),'FontSize',7, 'defaultTextFontSize',7, 'FontName', 'Helvetica');

savefig(gcf, [dirName, '/',fileName(1:end-14), '.fig']); 
print([dirName, '/',ProfileType],'-dpng');


%%

