% Code for reproducible results in paper:
% "Channel Model Mismatch Analysis for XL-MIMO Systems from a Localization
% Perspective"
% 
% Version: 08-May
% author: Hui Chen (hui.chen@chalmers.se; hui.chen@kaust.edu.sa)
% 

%%
close all;
clear all;
clc;

%% initialization...
% p: impaired model (true model)
% f: ideal model (mismatched model)
rng(1);
% current_figure = 'Digital, G=5, P=30dBm, N=64';

c = default_THz_2D_SWM_parameters();

% scene 1:
c.K = 10;
c.array_structure = "Digital";     % Digital
c.wave_type = "PWM";
c.G = 1;
c.P = 100;
c.D_Rx = (0:63)';  % uniform linear array

% scene 2:
% c.P = 1000;

% scene 3: save Fig-4-3.mat
% remember to set same precoders.
% c.array_structure = "Analog";     % Digital
% c.G = 50;

% scene 4:
% c.D_Rx = (0:31)';  % uniform linear array

% scene 5:
c.BW = 100e6;

% c.c/c.fc/2*length(c.D_Rx)
current_figure = [convertStringsToChars(c.array_structure) ', G=' num2str(c.G) ', P=' num2str(pow2db(c.P)) 'dBm, N=' num2str(length(c.D_Rx))];

c = update_parameters(c);
c0 = c;
%% PWM model and SWM model.
% cf is the mismatched model using PWM
cf = c0;
cf.wave_type = "PWM";
% cf.wave_type = "SWM-A1";
cf = update_parameters(cf);
cf = get_Rx_symbol(cf);

% cp is the true model using SWM
cp = c0;
cp.wave_type = "SWM";
cp = update_parameters(cp);
cp = get_Rx_symbol(cp);
cp.yp = cp.u;
% c.u

norm(cf.u(:) - cp.u(:), 'fro')/norm(cp.u(:), 'fro')

%% grid search and crlb
% rng(0);
snr = c.snr;
N_iter = 12;

% xgrid = 0.1:0.1:5;
% ygrid = -2.5:0.1:2.5;

xgrid = 0.05:0.05:5;
ygrid = -2.5:0.05:2.5;

CRLB_cell = cell(1, length(xgrid));

P_vec = (c.P);

parfor xi = 1:length(xgrid)
    disp([num2str(xi) '/' num2str(length(xgrid))])
    for yi = 1:length(ygrid)
%         c.PU = [xgrid(xi) ygrid(yi)]';
%         c = update_parameters(c);
%         c0 = c;

        cf = c0;
        cf.PU = [xgrid(xi) ygrid(yi)]';
        cf.wave_type = "PWM";
        cf = update_parameters(cf);
        cf = get_Rx_symbol(cf);
        cf = get_CRLB(cf);
%         AEB_PWM(xi, yi) = cf.AEB;
%         DEB_PWM(xi, yi) = cf.DEB;
%         PEB_PWM(xi, yi) = cf.PEB;
        CRLB_cell{xi}(1, yi) = cf.PEB;
        
        % cp is the true model using SWM
        cp = c0;
        cp.PU = [xgrid(xi) ygrid(yi)]';
        cp.wave_type = "SWM";
        cp.NF_SNS = "True";     % True, False
        cp.NF_SWM = "True";
        cp.NF_BSE = "True";
        cp = update_parameters(cp);
        cp = get_Rx_symbol(cp);
        cp = get_CRLB(cp);
%         AEB_SWM(xi, yi) = cp.AEB;
%         DEB_SWM(xi, yi) = cp.DEB;
%         PEB_SWM(xi, yi) = cp.PEB;
        CRLB_cell{xi}(2, yi) = cp.PEB;
        
        % CRLB F (Ideal model)
        

        [AEB, DEB, PEB] = get_CRLB_PWM_LB(cp, cf);
%         AEB_LB(xi, yi) = AEB;
%         DEB_LB(xi, yi) = DEB;
%         PEB_LB(xi, yi) = PEB;
        CRLB_cell{xi}(3, yi) = PEB;

    end
end
%%

CRB_mat = zeros(length(xgrid), length(ygrid), 3);

for ti = 1:size(CRB_mat, 3)
    for xi = 1:length(xgrid)
        CRB_mat(xi, :, ti) = CRLB_cell{xi}(ti, :);
    end
end

PEB_SWM = CRB_mat(:, :, 2);
PEB_LB = CRB_mat(:, :, 3);


%% CRLB
% Fresnel distance:     0.62*sqrt((c.N_Rx*c.lambdac/2)^3/c.lambdac)
% Frauhofer distance:   2*(c.N_Rx*c.lambdac/2)^2/c.lambdac
% 
figure;imagesc(xgrid, ygrid, PEB_SWM');
set(gca,'ColorScale','log')
colorbar;
caxis([1e-4 1e0]);
xlabel('x axis [m]');
ylabel('y axis [m]');
title('SWM')
hold on;contour(xgrid, ygrid, PEB_SWM', [0.001 0.01 0.02 0.05 0.1], 'ShowText','on', 'LineColor', 'w');

set(gca,'FontSize', 16);

figure;imagesc(xgrid, ygrid, (PEB_LB)');
set(gca,'ColorScale','log')
colorbar;
caxis([1e-4 1e0]);
xlabel('x axis [m]');
ylabel('y axis [m]');
title('LB')
hold on;contour(xgrid, ygrid, PEB_LB', [0.001 0.01 0.02 0.05 0.1], 'ShowText','on', 'LineColor', 'w');

set(gca,'FontSize', 16);


% figure;imagesc(x_grid, y_grid, (PEB_LB-PEB_SWM)');
% set(gca,'ColorScale','log')
% colorbar;
% caxis([1e-4 1e-2]);

%% LB difference
LB_diff = abs(PEB_LB-PEB_SWM)./(PEB_SWM);
% figure;imagesc(xgrid, ygrid, 10*log10(LB_diff)');

% min(min(LB_diff))
% pow2db(LB_diff)
CRB_mismatch = pow2db(abs(PEB_LB-PEB_SWM)./(PEB_SWM));
% CRB_mismatch = pow2db(abs(DEB_LB-DEB_SWM)./DEB_SWM);
% CRB_mismatch = pow2db(abs(AEB_LB-AEB_SWM)./AEB_SWM);
figure;imagesc(xgrid, ygrid, CRB_mismatch');
% set(gca,'ColorScale','log')
colorbar;
caxis([-10 10]);

xlabel('x axis [m]');
ylabel('y axis [m]');
set(gca,'FontSize', 16);

% hold on; contour(CRB_mismatch,'LineColor','w');
hold on;contour(xgrid, ygrid, CRB_mismatch', [-7 -3 0 3 7], 'ShowText','on', 'LineColor', 'w');


t = -90:1:90;
r1 = 0.62*sqrt((c.N_Rx*c.lambdac/2)^3/c.lambdac);
r2 = 2*(c.N_Rx*c.lambdac/2)^2/c.lambdac;
circ1 = [cosd(t); sind(t)].*r1;
circ2 = [cosd(t); sind(t)].*r2;
hold on;plot(circ1(1,:), circ1(2,:), 'r--', 'Linewidth', 2);
hold on;plot(circ2(1,:), circ2(2,:), 'r-', 'Linewidth', 2);
title(current_figure);

% caxis([1e-4 1e-2]);
% save data_fig_4_20dbm.mat
% load data_fig_4_20dbm.mat
% save data_fig_4_30dbm.mat
% load data_fig_4_30dbm.mat

%%
CRB_mismatch = ((PEB_LB-PEB_SWM));
figure;imagesc(xgrid, ygrid, CRB_mismatch');
set(gca,'ColorScale','log')
colorbar;
caxis([1e-4 1]);

% min(CRB_mismatch(:))
% max(CRB_mismatch(:))

xlabel('x axis [m]');
ylabel('y axis [m]');
set(gca,'FontSize', 16);

% hold on; contour(CRB_mismatch,'LineColor','w');
hold on;contour(xgrid, ygrid, CRB_mismatch', [5e-4 1e-3 0.01 0.1], 'ShowText','on', 'LineColor', 'w');

t = -90:1:90;
r1 = 0.62*sqrt((c.N_Rx*c.lambdac/2)^3/c.lambdac);
r2 = 2*(c.N_Rx*c.lambdac/2)^2/c.lambdac;
circ1 = [cosd(t); sind(t)].*r1;
circ2 = [cosd(t); sind(t)].*r2;
hold on;plot(circ1(1,:), circ1(2,:), 'r--', 'Linewidth', 2);
hold on;plot(circ2(1,:), circ2(2,:), 'r-', 'Linewidth', 2);
% legend('Fresnel', 'Fraunhofer');
title(current_figure);
%%