

clear; clc; close all;
 
fprintf('\n');
fprintf(' ============================================================\n');
fprintf('  COMPOSTERA AUTOMATIZADA — LOGICA DIFUSA MIMO\n');
fprintf('  3 Entradas x 3 Salidas x 12 Reglas — Mamdani Type-1\n');
fprintf('  R.Gutierrez | C.Valenzuela | V.Apaza | B.Munoz\n');
fprintf(' ============================================================\n\n');
 

fprintf('[1/5] Definiendo universos y funciones de membresia...\n');
 
NP = 500;
 
U_H = linspace(0,  100, NP);
U_T = linspace(0,   80, NP);
U_G = linspace(0,   40, NP);
U_R = linspace(0,    1, NP);
U_V = linspace(0,    1, NP);
U_C = linspace(0,    1, NP);
 
% Humedad: BAJA / MEDIA / ALTA
MF_H{1} = trapmf_fn(U_H, [-10   0  30  40]);
MF_H{2} = trapmf_fn(U_H, [ 30  40  60  70]);
MF_H{3} = trapmf_fn(U_H, [ 60  70 100 110]);
 
% Temperatura: BAJA / MEDIA / ALTA
MF_T{1} = trapmf_fn(U_T, [-10   0  15  20]);
MF_T{2} = trapmf_fn(U_T, [ 15  20  55  65]);
MF_T{3} = trapmf_fn(U_T, [ 55  65  80  90]);
 
% Gases/NH3: BAJO / MEDIO / ALTO
MF_G{1} = trapmf_fn(U_G, [ -5   0   8  10]);
MF_G{2} = trapmf_fn(U_G, [  8  10  18  20]);
MF_G{3} = trapmf_fn(U_G, [ 18  20  40  45]);
 
% Riego: APAGADO / MEDIO / ALTO
MF_R{1} = trimf_fn(U_R, [-0.1 0.00 0.40]);
MF_R{2} = trimf_fn(U_R, [ 0.3 0.50 0.70]);
MF_R{3} = trimf_fn(U_R, [ 0.6 1.00 1.10]);
 
% Ventilacion: APAGADO / BAJA / ALTA
MF_V{1} = trimf_fn(U_V, [-0.1 0.00 0.40]);
MF_V{2} = trimf_fn(U_V, [ 0.3 0.50 0.70]);
MF_V{3} = trimf_fn(U_V, [ 0.6 1.00 1.10]);
 
% Calefaccion: APAGADO / MEDIA / ALTA
MF_C{1} = trimf_fn(U_C, [-0.1 0.00 0.40]);
MF_C{2} = trimf_fn(U_C, [ 0.3 0.50 0.70]);
MF_C{3} = trimf_fn(U_C, [ 0.6 1.00 1.10]);
 
% 12 Reglas IF-THEN
% Columnas: [H  T  G   Riego  Ventil  Calef]
% 0=cualquiera  1=BAJA/BAJO  2=MEDIA/MEDIO  3=ALTA/ALTO
REGLAS = [
%  H   T   G    R   V   C
   1,  0,  0,   3,  1,  1;   % R01: H_BAJA  -> Riego ALTO
   3,  0,  0,   1,  3,  1;   % R02: H_ALTA  -> Ventilacion ALTA
   0,  1,  0,   1,  1,  3;   % R03: T_BAJA  -> Calefaccion ALTA
   0,  3,  0,   1,  3,  1;   % R04: T_ALTA  -> Ventilacion ALTA
   0,  0,  3,   1,  3,  1;   % R05: G_ALTO  -> Ventilacion ALTA
   2,  2,  1,   1,  1,  1;   % R06: Normal optimo -> todo APAGADO
   2,  2,  2,   2,  2,  2;   % R07: Moderado -> todo MEDIO
   1,  1,  0,   3,  1,  3;   % R08: H+T bajas -> Riego+Calef ALTO
   3,  3,  0,   1,  3,  1;   % R09: H+T altas -> Ventilacion ALTA
   0,  3,  3,   1,  3,  1;   % R10: T+G altos -> Ventilacion ALTA
   1,  0,  3,   2,  3,  1;   % R11: H_baja+G_alto -> Riego+Vent
   3,  1,  0,   1,  3,  3;   % R12: H_alta+T_baja -> Vent+Calef
];
 
fprintf('    OK: 3 entradas, 3 salidas, %d reglas\n\n', size(REGLAS,1));
 
%% ================================================================
%  BLOQUE 2 — FIGURA 1: FIS PLOT (estilo Fuzzy Logic Designer)
%% ================================================================
fprintf('[2/5] Generando FIS Plot (estilo Fuzzy Logic Designer)...\n');
 
fig1 = figure('Name','Compostera_Automatizada — FIS Plot', ...
              'NumberTitle','off','Color',[0.12 0.12 0.12], ...
              'Position',[20 60 1280 700]);
 
col3  = {[0.20 0.60 0.90],[0.95 0.55 0.10],[0.95 0.25 0.25]};
ax_bg = [0.05 0.07 0.10];
 
% Posiciones: entradas (izquierda), salidas (derecha)
pos_ent = {[0.04 0.63 0.22 0.28], ...
           [0.04 0.32 0.22 0.28], ...
           [0.04 0.03 0.22 0.28]};
 
pos_sal = {[0.74 0.63 0.22 0.28], ...
           [0.74 0.32 0.22 0.28], ...
           [0.74 0.03 0.22 0.28]};
 
U_ent  = {U_H,   U_T,   U_G};
MF_ent = {MF_H,  MF_T,  MF_G};
tit_ent= {'Humedad  (3 MFs)', 'Temperatura  (3 MFs)', 'Gases  (3 MFs)'};
 
U_sal  = {U_R,   U_V,   U_C};
MF_sal = {MF_R,  MF_V,  MF_C};
tit_sal= {'Riego  (3 MFs)', 'Ventilacion  (3 MFs)', 'Calefaccion  (3 MFs)'};
 
xlim_ent = {[0 100],[0 80],[0 40]};
xc = [0.70 0.70 0.70];
 
for i = 1:3
    ax = axes('Position', pos_ent{i}, ...
              'Color', ax_bg, ...
              'XColor', xc, 'YColor', xc, ...
              'GridColor',[0.25 0.25 0.25], ...
              'FontSize', 7.5, 'Parent', fig1);
    hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    ax.GridAlpha = 0.3;
    ax.XLim = xlim_ent{i};
    ax.YLim = [-0.05 1.1];
    for j = 1:3
        plot(ax, U_ent{i}, MF_ent{i}{j}, ...
             'Color', col3{j}, 'LineWidth', 1.8);
    end
    title(ax, tit_ent{i}, ...
          'Color',[0.85 0.85 0.85], 'FontSize',8, 'FontWeight','normal');
end
 
for i = 1:3
    ax = axes('Position', pos_sal{i}, ...
              'Color', ax_bg, ...
              'XColor', xc, 'YColor', xc, ...
              'GridColor',[0.25 0.25 0.25], ...
              'FontSize', 7.5, 'Parent', fig1);
    hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    ax.GridAlpha = 0.3;
    ax.XLim = [0 1];
    ax.YLim = [-0.05 1.1];
    for j = 1:3
        plot(ax, U_sal{i}, MF_sal{i}{j}, ...
             'Color', col3{j}, 'LineWidth', 1.8);
    end
    title(ax, tit_sal{i}, ...
          'Color',[0.85 0.85 0.85], 'FontSize',8, 'FontWeight','normal');
end
 
% Caja central Mamdani
ax_c = axes('Position',[0.37 0.35 0.25 0.30], ...
            'Color',[0.16 0.18 0.20], ...
            'XColor','none','YColor','none','Parent',fig1);
ax_c.XLim=[0 1]; ax_c.YLim=[0 1];
rectangle('Parent',ax_c,'Position',[0.05 0.08 0.90 0.84], ...
          'EdgeColor',[0.40 0.45 0.55],'LineWidth',1.5, ...
          'FaceColor',[0.12 0.14 0.18]);
text(0.50, 0.62, 'Mamdani', 'Parent',ax_c, ...
     'Color',[0.85 0.85 0.85],'FontSize',11,'FontWeight','bold', ...
     'HorizontalAlignment','center');
text(0.50, 0.42, 'Type 1', 'Parent',ax_c, ...
     'Color',[0.65 0.70 0.80],'FontSize',10, ...
     'HorizontalAlignment','center');
text(0.50, 0.22, '12 Rules  |  3x3', 'Parent',ax_c, ...
     'Color',[0.45 0.55 0.70],'FontSize',8.5, ...
     'HorizontalAlignment','center');
 
% Lineas de conexion
lc = [0.45 0.55 0.65];
ex = [0.265 0.265 0.265];
ey = [0.775 0.460 0.170];
sx = [0.735 0.735 0.735];
sy = [0.775 0.460 0.170];
cy_box = [0.715 0.500 0.380];
 
for i = 1:3
    annotation(fig1,'line',[ex(i) 0.37],[ey(i) cy_box(i)],'Color',lc,'LineWidth',1.0);
    annotation(fig1,'line',[0.62 sx(i)],[cy_box(i) sy(i)],'Color',lc,'LineWidth',1.0);
end
 
annotation(fig1,'textbox',[0.25 0.92 0.50 0.06], ...
    'String','Fuzzy Inference System (FIS) Plot  —  Compostera_Automatizada', ...
    'Color',[0.90 0.90 0.90],'FontSize',11,'FontWeight','bold', ...
    'EdgeColor','none','BackgroundColor','none','HorizontalAlignment','center');
annotation(fig1,'textbox',[0.25 0.87 0.50 0.04], ...
    'String','System: Compostera_Automatizada  |  Mamdani Type-1  |  3 Inputs  x  3 Outputs  x  12 Rules', ...
    'Color',[0.60 0.65 0.70],'FontSize',8.5,'EdgeColor','none', ...
    'BackgroundColor','none','HorizontalAlignment','center');
 
fprintf('    OK: FIS Plot generado\n\n');
 
%% ================================================================
%  BLOQUE 3 — FIGURA 2: MEMBERSHIP FUNCTION EDITOR
%% ================================================================
fprintf('[3/5] Generando Membership Function Editor...\n');
 
fig2 = figure('Name','MF Editor — Compostera_Automatizada', ...
              'NumberTitle','off','Color',[0.10 0.10 0.12], ...
              'Position',[30 40 1280 720]);
 
todos_U   = {U_H,  U_T,  U_G,  U_R,  U_V,  U_C};
todos_MF  = {MF_H, MF_T, MF_G, MF_R, MF_V, MF_C};
todos_tit = {'Humedad  [%]','Temperatura  [C]','Gases/NH3  [ppm]', ...
             'Riego  [0-1]','Ventilacion  [0-1]','Calefaccion  [0-1]'};
todos_leg = {{'BAJA','MEDIA','ALTA'}, ...
             {'BAJA','MEDIA','ALTA'}, ...
             {'BAJO','MEDIO','ALTO'}, ...
             {'APAGADO','MEDIO','ALTO'}, ...
             {'APAGADO','BAJA','ALTA'}, ...
             {'APAGADO','MEDIA','ALTA'}};
 
ac = [0.70 0.70 0.70];
 
for p = 1:6
    ax = subplot(2,3,p);
    set(ax,'Color',[0.05 0.07 0.10], ...
           'XColor',ac,'YColor',ac, ...
           'GridColor',[0.25 0.25 0.28], ...
           'FontSize',9,'LineWidth',0.8);
    hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    ax.GridAlpha = 0.25;
 
    xU = todos_U{p};
    for j = 1:3
        y = todos_MF{p}{j};
        fill([xU, fliplr(xU)], [y, zeros(1,NP)], col3{j}, ...
             'FaceAlpha',0.13,'EdgeColor','none','Parent',ax);
        plot(ax, xU, y, 'Color',col3{j}, 'LineWidth',2.0);
    end
 
    title(ax, todos_tit{p}, ...
          'Color',[0.92 0.92 0.92],'FontSize',10,'FontWeight','bold');
    ylabel(ax,'Degree of membership', ...
           'Color',[0.65 0.65 0.65],'FontSize',8);
    if p > 3
        xlabel(ax, todos_tit{p}, ...
               'Color',[0.65 0.65 0.65],'FontSize',8);
    end
    ylim(ax, [-0.05 1.12]);
    leg = legend(ax, todos_leg{p}, 'Location','north','FontSize',8);
    leg.TextColor = [0.85 0.85 0.85];
    leg.Color     = [0.15 0.17 0.20];
    leg.EdgeColor = [0.30 0.32 0.35];
end
 
annotation(fig2,'textbox',[0.01 0.52 0.04 0.10], ...
    'String','INPUT','Color',[0.45 0.75 0.45],'FontSize',9, ...
    'FontWeight','bold','EdgeColor','none','Rotation',90, ...
    'HorizontalAlignment','center');
annotation(fig2,'textbox',[0.01 0.04 0.04 0.10], ...
    'String','OUTPUT','Color',[0.45 0.65 0.90],'FontSize',9, ...
    'FontWeight','bold','EdgeColor','none','Rotation',90, ...
    'HorizontalAlignment','center');
 
sgtitle('Membership Function (MF) Editor  —  Compostera\_Automatizada', ...
        'Color',[0.90 0.90 0.90],'FontSize',13,'FontWeight','bold');
 
fprintf('    OK: MF Editor generado\n\n');
 
%% ================================================================
%  BLOQUE 4 — SUPERFICIES 3D + ESCENARIOS
%% ================================================================
fprintf('[4/5] Calculando superficies de control y escenarios...\n');
 
% -- Escenarios del paper
sep = repmat('=',1,72);
fprintf('\n %s\n',sep);
fprintf('  ESCENARIOS — Compostera Automatizada (Tabla I adaptada)\n');
fprintf(' %s\n',sep);
fprintf('  %-6s %-6s %-8s  %-14s %-14s %-14s\n', ...
        'H[%]','T[C]','G[ppm]','Riego','Ventilacion','Calefaccion');
fprintf('  %s\n',repmat('-',1,68));
 
esc = {
    50, 35,  8,  'Condicion NORMAL -> reposo';
    20, 35,  8,  'H BAJA  -> Riego ALTO';
    80, 35,  8,  'H ALTA  -> Ventilacion ALTA';
    50, 10,  8,  'T BAJA  -> Calefaccion ALTA';
    50, 70,  8,  'T ALTA  -> Ventilacion ALTA';
    50, 35, 25,  'G ALTO  -> Ventilacion ALTA';
    15, 10,  5,  'H+T BAJAS -> Riego+Calef ALTO';
    80, 72, 28,  'TRIPLE ALARMA -> max accion';
};
 
em={'APAGADO ','MEDIO   ','ALTO    '};
ev={'APAGADO ','BAJA    ','ALTA    '};
ec={'APAGADO ','MEDIA   ','ALTA    '};
 
for i = 1:size(esc,1)
    Hs=esc{i,1}; Ts=esc{i,2}; Gs=esc{i,3}; ds=esc{i,4};
    res = fis_eval(Hs,Ts,Gs, U_H,U_T,U_G,U_R,U_V,U_C, ...
                  MF_H,MF_T,MF_G,MF_R,MF_V,MF_C, REGLAS, NP);
    rC=res(1); vC=res(2); cC=res(3);
    if rC<0.30,ir=1;elseif rC<0.65,ir=2;else,ir=3;end
    if vC<0.30,iv=1;elseif vC<0.65,iv=2;else,iv=3;end
    if cC<0.30,ic=1;elseif cC<0.65,ic=2;else,ic=3;end
    fprintf('  H=%2d T=%2d G=%2d    %s(%.2f) %s(%.2f) %s(%.2f)  <- %s\n', ...
            Hs,Ts,Gs, em{ir},rC, ev{iv},vC, ec{ic},cC, ds);
end
fprintf(' %s\n\n',sep);
 
% -- Superficies 3D
fprintf('  Calculando superficies 3D (~30 s)...\n');
 
Hv = linspace(0,100,22);
Tv = linspace(0, 80,22);
G_fijo = 10;
 
[HG, TG] = meshgrid(Hv, Tv);
SR = zeros(size(HG));
SV = zeros(size(HG));
SC = zeros(size(HG));
 
for r = 1:size(HG,1)
    for c = 1:size(HG,2)
        res = fis_eval(HG(r,c),TG(r,c),G_fijo, ...
                       U_H,U_T,U_G,U_R,U_V,U_C, ...
                       MF_H,MF_T,MF_G,MF_R,MF_V,MF_C, REGLAS, NP);
        SR(r,c)=res(1); SV(r,c)=res(2); SC(r,c)=res(3);
    end
end
 
fig3 = figure('Name','Control Surface — Compostera_Automatizada', ...
              'NumberTitle','off','Color',[0.10 0.10 0.12], ...
              'Position',[40 30 1280 460]);
 
surfs  = {SR, SV, SC};
tit3   = {'Riego','Ventilacion','Calefaccion'};
cmaps3 = {'parula','cool','autumn'};
 
for p = 1:3
    ax = subplot(1,3,p);
    set(ax,'Color',[0.06 0.08 0.12], ...
           'XColor',[0.70 0.70 0.70],'YColor',[0.70 0.70 0.70], ...
           'ZColor',[0.70 0.70 0.70],'FontSize',9);
    surf(ax, HG, TG, surfs{p}, 'EdgeColor','none','FaceAlpha',0.92);
    colormap(ax, cmaps3{p});
    cb = colorbar(ax);
    cb.Color = [0.70 0.70 0.70];
    cb.Label.String = tit3{p};
    cb.Label.Color  = [0.80 0.80 0.80];
    xlabel(ax,'Humedad [%]','Color',[0.75 0.75 0.75],'FontSize',9);
    ylabel(ax,'Temperatura [C]','Color',[0.75 0.75 0.75],'FontSize',9);
    zlabel(ax,tit3{p},'Color',[0.75 0.75 0.75],'FontSize',9);
    title(ax, sprintf('Salida: %s\n(Gases = %d ppm fijo)',tit3{p},G_fijo), ...
          'Color',[0.90 0.90 0.90],'FontSize',10,'FontWeight','bold');
    view(ax, 42, 28); grid(ax,'on');
    ax.GridAlpha = 0.25;
    ax.GridColor = [0.28 0.30 0.34];
    zlim(ax,[0 1]);
end
sgtitle('Control Surface  —  Compostera\_Automatizada  (Mamdani Type-1)', ...
        'Color',[0.90 0.90 0.90],'FontSize',13,'FontWeight','bold');
 
fprintf('    OK: Superficies generadas\n\n');
 
%% ================================================================
%  BLOQUE 5 — SIMULACION 7 DIAS EN LAZO CERRADO
%% ================================================================
fprintf('[5/5] Simulacion 7 dias lazo cerrado (168 h)...\n');
 
% -- Parametros de planta
T_amb  = 18;   T_opt = 48;
tau_T  = 4.0;  tau_H = 6.0;  tau_G = 2.0;
Kv_T   = 7.5;  Kv_H  = 4.0;  Kv_G  = 11.0;
Kr_T   = 4.5;  Kr_H  = 2.2;
 
dt=0.05; Tf=168; t=(0:dt:Tf)'; N=length(t);
X  = zeros(N,3); X(1,:)=[14, 72, 1.5];  % [H, T, G]
Uc = zeros(N,3);
 
pT  =  4.5*sin(2*pi*t/24);
pH  =  3.0*cos(2*pi*t/36)-1.5;
pG  = (0.7*sin(2*pi*t/8)+0.9).*exp(-t/180);
 
for k = 1:N-1
    H_k = max(10,  min(100, X(k,1)));
    T_k = max(0,   min(80,  X(k,2)));
    G_k = max(0,   min(40,  X(k,3)));
 
    res = fis_eval(H_k,T_k,G_k, U_H,U_T,U_G,U_R,U_V,U_C, ...
                   MF_H,MF_T,MF_G,MF_R,MF_V,MF_C, REGLAS, NP);
    riego=res(1); vent=res(2); calef=res(3);
    Uc(k,:) = [riego, vent, calef];
 
    dT = Kr_T*vent*(T_opt-T_k)/tau_T ...
       - Kv_T*vent*(T_k-T_amb)/tau_T ...
       + calef*8.0*(20-T_k)/tau_T ...
       + pT(k)*0.09;
    dH = - Kv_H*vent*H_k/(tau_H*100) ...
         - riego*6.0*(H_k-50)/tau_H ...
         + riego*4.0*(40-H_k)/tau_H ...
         + pH(k)*0.06;
    dG = pG(k)*0.9 - Kv_G*vent*G_k/(tau_G*40);
 
    X(k+1,1) = max(10, min(100, X(k,1)+dt*dH));
    X(k+1,2) = max(0,  min(80,  X(k,2)+dt*dT));
    X(k+1,3) = max(0,  min(40,  X(k,3)+dt*dG));
end
Uc(N,:) = Uc(N-1,:);
 
fprintf('    OK: Simulacion completa (%d pasos)\n\n', N);
 
% -- Estadisticas
fprintf(' ====================================================\n');
fprintf('  ESTADISTICAS — 7 DIAS\n');
fprintf('  Variable         Min    Media    Max    Std\n');
fprintf('  ------------------------------------------------\n');
fprintf('  Humedad [%%]     %5.1f   %5.1f   %5.1f   %5.1f\n', ...
    min(X(:,1)),mean(X(:,1)),max(X(:,1)),std(X(:,1)));
fprintf('  Temperatura [C]  %5.1f   %5.1f   %5.1f   %5.1f\n', ...
    min(X(:,2)),mean(X(:,2)),max(X(:,2)),std(X(:,2)));
fprintf('  Gases [ppm]      %5.1f   %5.1f   %5.1f   %5.1f\n', ...
    min(X(:,3)),mean(X(:,3)),max(X(:,3)),std(X(:,3)));
fprintf('  Riego ON:        %.1f%% del tiempo\n', 100*sum(Uc(:,1)>0.45)/N);
fprintf('  Ventilacion ON:  %.1f%% del tiempo\n', 100*sum(Uc(:,2)>0.45)/N);
fprintf('  Calefaccion ON:  %.1f%% del tiempo\n', 100*sum(Uc(:,3)>0.45)/N);
fprintf(' ====================================================\n\n');
 
% -- Figura 4: Panel de simulacion
td = t/24;
bg_sim  = [0.10 0.10 0.12];
xc_axis = [0.70 0.70 0.70];
 
cH = [0.20 0.60 0.95]; cT = [0.95 0.35 0.25]; cG = [0.95 0.65 0.10];
cR = [0.20 0.85 0.50]; cV = [0.35 0.65 0.95]; cC = [0.95 0.55 0.20];
 
fig4 = figure('Name','Simulacion 7 dias — Compostera_Automatizada', ...
              'NumberTitle','off','Color',bg_sim, ...
              'Position',[50 20 1340 820]);
 
gap = 0.01; h6 = 0.128; bot = 0.07;
ypos = [bot+5*(h6+gap), bot+4*(h6+gap), bot+3*(h6+gap), ...
        bot+2*(h6+gap), bot+(h6+gap),   bot];
ylims_list = {[0 110],[0 88],[0 46],[0 1.1],[0 1.1],[0 1.1]};
 
% Crear los 6 ejes directamente SIN funcion anidada
ax1 = axes('Parent',fig4,'Position',[0.07 ypos(1) 0.91 h6], ...
           'Color',[0.06 0.08 0.11],'XColor',xc_axis,'YColor',xc_axis, ...
           'GridColor',[0.22 0.24 0.28],'GridAlpha',0.5, ...
           'XLim',[0 7],'YLim',ylims_list{1},'Box','on','FontSize',9);
grid(ax1,'on');
 
ax2 = axes('Parent',fig4,'Position',[0.07 ypos(2) 0.91 h6], ...
           'Color',[0.06 0.08 0.11],'XColor',xc_axis,'YColor',xc_axis, ...
           'GridColor',[0.22 0.24 0.28],'GridAlpha',0.5, ...
           'XLim',[0 7],'YLim',ylims_list{2},'Box','on','FontSize',9);
grid(ax2,'on');
 
ax3 = axes('Parent',fig4,'Position',[0.07 ypos(3) 0.91 h6], ...
           'Color',[0.06 0.08 0.11],'XColor',xc_axis,'YColor',xc_axis, ...
           'GridColor',[0.22 0.24 0.28],'GridAlpha',0.5, ...
           'XLim',[0 7],'YLim',ylims_list{3},'Box','on','FontSize',9);
grid(ax3,'on');
 
ax4 = axes('Parent',fig4,'Position',[0.07 ypos(4) 0.91 h6], ...
           'Color',[0.06 0.08 0.11],'XColor',xc_axis,'YColor',xc_axis, ...
           'GridColor',[0.22 0.24 0.28],'GridAlpha',0.5, ...
           'XLim',[0 7],'YLim',ylims_list{4},'Box','on','FontSize',9);
grid(ax4,'on');
set(ax4,'YTick',[0 0.5 1],'YTickLabel',{'OFF','','ON'});
 
ax5 = axes('Parent',fig4,'Position',[0.07 ypos(5) 0.91 h6], ...
           'Color',[0.06 0.08 0.11],'XColor',xc_axis,'YColor',xc_axis, ...
           'GridColor',[0.22 0.24 0.28],'GridAlpha',0.5, ...
           'XLim',[0 7],'YLim',ylims_list{5},'Box','on','FontSize',9);
grid(ax5,'on');
set(ax5,'YTick',[0 0.5 1],'YTickLabel',{'OFF','','ON'});
 
ax6 = axes('Parent',fig4,'Position',[0.07 ypos(6) 0.91 h6], ...
           'Color',[0.06 0.08 0.11],'XColor',xc_axis,'YColor',xc_axis, ...
           'GridColor',[0.22 0.24 0.28],'GridAlpha',0.5, ...
           'XLim',[0 7],'YLim',ylims_list{6},'Box','on','FontSize',9);
grid(ax6,'on');
set(ax6,'YTick',[0 0.5 1],'YTickLabel',{'OFF','','ON'});
 
% Zonas optimas
patch(ax1,[0 7 7 0],[40 40 60 60],[0.20 0.55 0.20], ...
      'FaceAlpha',0.08,'EdgeColor','none');
patch(ax2,[0 7 7 0],[20 20 65 65],[0.95 0.35 0.25], ...
      'FaceAlpha',0.06,'EdgeColor','none');
patch(ax3,[0 7 7 0],[0  0  20 20],[0.95 0.65 0.10], ...
      'FaceAlpha',0.06,'EdgeColor','none');
 
% Graficar variables
hold(ax1,'on'); plot(ax1,td,X(:,1),'Color',cH,'LineWidth',1.8);
yline(ax1,40,'--','Color',cH*0.7,'LineWidth',1.2, ...
      'Label','40% min','LabelHorizontalAlignment','right');
yline(ax1,60,'--','Color',[0.15 0.45 0.75],'LineWidth',1.2, ...
      'Label','60% max','LabelHorizontalAlignment','right');
 
hold(ax2,'on'); plot(ax2,td,X(:,2),'Color',cT,'LineWidth',1.8);
yline(ax2,20,'--','Color',cT*0.7,'LineWidth',1.2, ...
      'Label','20C min','LabelHorizontalAlignment','right');
yline(ax2,65,'--','Color',[0.65 0.15 0.60],'LineWidth',1.2, ...
      'Label','65C max','LabelHorizontalAlignment','right');
 
hold(ax3,'on'); plot(ax3,td,X(:,3),'Color',cG,'LineWidth',1.8);
yline(ax3,20,'--','Color',cG*0.7,'LineWidth',1.2, ...
      'Label','20ppm umbral','LabelHorizontalAlignment','right');
 
hold(ax4,'on');
area(ax4,td,Uc(:,1),'FaceColor',cR,'FaceAlpha',0.75, ...
     'EdgeColor',cR*0.7,'LineWidth',0.7);
hold(ax5,'on');
area(ax5,td,Uc(:,2),'FaceColor',cV,'FaceAlpha',0.75, ...
     'EdgeColor',cV*0.7,'LineWidth',0.7);
hold(ax6,'on');
area(ax6,td,Uc(:,3),'FaceColor',cC,'FaceAlpha',0.75, ...
     'EdgeColor',cC*0.7,'LineWidth',0.7);
 
% Etiquetas de eje Y
ylabel(ax1,'Humedad [%]','Color',cH,'FontSize',9,'FontWeight','bold');
ylabel(ax2,'Temp [C]',   'Color',cT,'FontSize',9,'FontWeight','bold');
ylabel(ax3,'Gases [ppm]','Color',cG,'FontSize',9,'FontWeight','bold');
ylabel(ax4,'Riego',      'Color',cR,'FontSize',9,'FontWeight','bold');
ylabel(ax5,'Ventil.',    'Color',cV,'FontSize',9,'FontWeight','bold');
ylabel(ax6,'Calefac.',   'Color',cC,'FontSize',9,'FontWeight','bold');
xlabel(ax6,'Tiempo  [dias]','Color',[0.75 0.75 0.75], ...
       'FontSize',10,'FontWeight','bold');
 
% Sincronizar eje X y marcar dias
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x');
xlim(ax1,[0 7]);
all_ax = [ax1,ax2,ax3,ax4,ax5,ax6];
for d = 1:6
    for k = 1:6
        xline(all_ax(k), d, ':', ...
              'Color',[0.35 0.37 0.42],'Alpha',0.7);
    end
end
 
annotation(fig4,'textbox',[0.07 0.955 0.91 0.038], ...
    'String', ...
    'Simulacion 7 dias — Lazo Cerrado MIMO  |  Compostera_Automatizada  |  IEEE 2019', ...
    'Color',[0.90 0.90 0.90],'FontSize',12,'FontWeight','bold', ...
    'EdgeColor','none','BackgroundColor','none', ...
    'HorizontalAlignment','center');
 
fprintf(' ============================================================\n');
fprintf('  COMPLETADO — 4 figuras generadas:\n');
fprintf('    Fig 1 — FIS Plot (estilo Fuzzy Logic Designer)\n');
fprintf('    Fig 2 — Membership Function (MF) Editor\n');
fprintf('    Fig 3 — Control Surface (3 salidas x 3D)\n');
fprintf('    Fig 4 — Simulacion 7 dias lazo cerrado\n');
fprintf(' ============================================================\n\n');

 
function y = trapmf_fn(x, p)
    a=p(1); b=p(2); c=p(3); d=p(4);
    y = zeros(size(x));
    if b > a
        mask = (x >= a) & (x < b);
        y(mask) = (x(mask) - a) ./ (b - a);
    end
    y((x >= b) & (x <= c)) = 1;
    if d > c
        mask = (x > c) & (x <= d);
        y(mask) = (d - x(mask)) ./ (d - c);
    end
end
 
function y = trimf_fn(x, p)
    a=p(1); b=p(2); c=p(3);
    y = zeros(size(x));
    if b > a
        mask = (x >= a) & (x <= b);
        y(mask) = (x(mask) - a) ./ (b - a);
    end
    if c > b
        mask = (x >= b) & (x <= c);
        y(mask) = (c - x(mask)) ./ (c - b);
    end
    y(x == b) = 1;
end
 
function sal = fis_eval(H_in, T_in, G_in, ...
                        U_H, U_T, U_G, U_R, U_V, U_C, ...
                        MF_H, MF_T, MF_G, MF_R, MF_V, MF_C, ...
                        REGLAS, NP)
    H_in = max(0,   min(100, H_in));
    T_in = max(0,   min(80,  T_in));
    G_in = max(0,   min(40,  G_in));
 
    mu_H = zeros(1,3);
    mu_T = zeros(1,3);
    mu_G = zeros(1,3);
    for j = 1:3
        mu_H(j) = interp1(U_H, MF_H{j}, H_in, 'linear', 0);
        mu_T(j) = interp1(U_T, MF_T{j}, T_in, 'linear', 0);
        mu_G(j) = interp1(U_G, MF_G{j}, G_in, 'linear', 0);
    end
 
    agg_R = zeros(1,NP);
    agg_V = zeros(1,NP);
    agg_C = zeros(1,NP);
 
    for r = 1:size(REGLAS,1)
        iH=REGLAS(r,1); iT=REGLAS(r,2); iG=REGLAS(r,3);
        oR=REGLAS(r,4); oV=REGLAS(r,5); oC=REGLAS(r,6);
        g = [];
        if iH > 0, g(end+1) = mu_H(iH); end %#ok<AGROW>
        if iT > 0, g(end+1) = mu_T(iT); end %#ok<AGROW>
        if iG > 0, g(end+1) = mu_G(iG); end %#ok<AGROW>
        if isempty(g), alpha = 1; else, alpha = min(g); end
        if alpha <= 1e-9, continue; end
        agg_R = max(agg_R, min(alpha, MF_R{oR}));
        agg_V = max(agg_V, min(alpha, MF_V{oV}));
        agg_C = max(agg_C, min(alpha, MF_C{oC}));
    end
 
    dR = sum(agg_R); dV = sum(agg_V); dC = sum(agg_C);
    if dR < 1e-12, sR=0; else, sR=sum(U_R.*agg_R)/dR; end
    if dV < 1e-12, sV=0; else, sV=sum(U_V.*agg_V)/dV; end
    if dC < 1e-12, sC=0; else, sC=sum(U_C.*agg_C)/dC; end
    sal = [sR, sV, sC];
end