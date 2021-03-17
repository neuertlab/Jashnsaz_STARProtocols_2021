clc; clear; close all; 
format shortg
% this code calculates the inoculation volumes to start multiple cell cultures from independent pre-cultures to reach desired OD600 the next day.  
% specify parameters in the next two sections, run the code, it prints and saves the table of calculation
% see the last 3 lines for the printer setup

%% enter the OD600 measures of the pre-cultures in decending order. 
% Sort them to a descending order during/after OD600 measurment. 
% ideal starting OD600 range 0.10 to 0.60, for cells of ~30ml, to start 4-7pm today, for experiments starting tomorrow 9 am. 
% comment out or uncomment as needed based on your # of samples
init_OD600 = [
    0.241; % 1
    0.223; % 2
    0.159; % 3
    0.111; % 4
    0.110; % 5
    0.085; % 6
    0.079; % 7
    0.077; % 8
    0.075; % 9
    0.053; % 10
%     0.292; % 11
%     0.280; % 12
%     0.267; % 13
%     0.240; % 14
%     0.107; % 15
%     0.086; % 16
%     0.076; % 17
%     0.068; % 18
%     0.065; % 19
%     0.065; % 20    
    ];  
%% enter parameters
str = 'March 10, 2021 9:00:00'; % target time for the start of the 1st exoeriment (tomorrow, 9am)
target_OD600 = 0.50; % target OD600 of the cells at the start of the experiment
cells_vol = 25; % volume of the cells (start media in each flask) (mL)
doubling_time = 88; % an estimate of cells doubling time in exponential phase (min)
duration_for_an_expmnt = 90; % duration for each expmnt (the time between two target times) (min)

%% calculations
% calculates duration from now until the first target time. 
init_time = clock; % the current date and time as a date vector
target_time = datevec(str,'mmmm dd, yyyy HH:MM:SS'); 
dur_in_minutes = etime(target_time,init_time)/60; % the number of minutes between t1 and t2.

n_samples = length(init_OD600); 
inoculation_vols = NaN(1,n_samples); 

for i= 1:n_samples
    cells_growth_cycles = (dur_in_minutes +(i-1)*duration_for_an_expmnt)/doubling_time; % # of cells growth cycles from now till each experiment
    inoculation_vols(i) = (1000*cells_vol*target_OD600)/((2^(cells_growth_cycles))*init_OD600(i));     
end

%% prints the results in a table
figure(); set(gcf, 'Units', 'centimeters', 'Position', [0, 0, 12, 18], 'PaperUnits', 'centimeters', 'PaperSize', [12, 18]); 
hold on; grid on; 

datetoday=cellstr(datetime('today')); 
theDate = datetoday{1}; 
% title(datetoday{1});

txt = text(1,n_samples+1, 'samples'); txt.HorizontalAlignment = 'center'; 
txt = text(3,n_samples+1, 'volume (\mu L)'); txt.HorizontalAlignment = 'center';
txt = text(2,n_samples+1, 'OD600'); txt.HorizontalAlignment = 'center';

for i=1:n_samples
    if inoculation_vols(i)>2.5
        vol_print = num2str(inoculation_vols(i),'%04.2f');
    else
        vol_print = num2str(inoculation_vols(i),'%04.3f');
    end
    txt = text(1,n_samples-i+1, num2str(i)); txt.HorizontalAlignment = 'center';
    txt = text(3,n_samples-i+1, vol_print); txt.HorizontalAlignment = 'center';
    txt = text(2,n_samples-i+1, num2str(init_OD600(i))); txt.HorizontalAlignment = 'center';
end

xlim([.5 3.5]); ylim([.5 n_samples + .5]); 
xticks([.5:1:3.5]); yticks([.5:1:n_samples + 1.5])          
xticklabels([]); yticklabels([]); box on; 

set(findall(gcf,'-property','FontSize'),'FontSize',12, 'defaultTextFontSize',12, 'FontName', 'Helvetica')

% [~,printers] = findprinters
print('-PNeuert Lab New') % prints the results, use the line above to find your printers name
saveas(gcf,[theDate, '_OD600s'], 'epsc') % saves the calculation results as a .eps table
