%% CABLE ATTENUATION ANALYZER
% jose.rugeles@unimilitar.edu.co (adaptado a MATLAB)
% Lineas de transmisión y comunicaciones ópticas
% Modelo: Att(f) = kdb1·√f + kdb2·f  (f en MHz, Att en dB/m)

clear; close all; clc;

%% ═══════════════════════════════════════════════════════════════════
%  DATOS DE CABLES  —  edita aquí con tus tablas del fabricante
%% ═══════════════════════════════════════════════════════════════════

CABLES = struct(...
    'nombre', {}, ...
    'color', {}, ...
    'longitud', {}, ...
    'tabla', {});

% Cable 1: RG174
CABLES(1).nombre = 'RG174';
CABLES(1).color = [0.902, 0.627, 0.251]; % Naranja suave
CABLES(1).longitud = 1.0;
CABLES(1).tabla = [
    50,   17.5 / 100;
    100,  25.8 / 100;
    200,  38.2 / 100;
    400,  54.9 / 100;
    800,  77.0 / 100;
    1000, 87.5 / 100;
];

% Cable 2: PE300-196
CABLES(2).nombre = 'PE300-196';
CABLES(2).color = [0.3, 0.75, 0.9]; % Azul suave
CABLES(2).longitud = 4.978;
CABLES(2).tabla = [
    1000,  0.36;
    3000,  0.66;
    5000,  0.85;
    10000, 1.31;
    18000, 1.90;
];

% Cable 3: RG900
CABLES(3).nombre = 'RG900';
CABLES(3).color = [0.6, 0.4, 0.8]; % Lavanda
CABLES(3).longitud = 1.0;
CABLES(3).tabla = [
    900,  0.056;
    1800, 0.082;
    2500, 0.098;
    5800, 0.16;
];

% Cable 4: RG195
CABLES(4).nombre = 'RG195';
CABLES(4).color = [1.0, 0.627, 0.251]; % Lavanda
CABLES(4).longitud = 1.0;
CABLES(4).tabla = [
    900,  0.36;
    1800, 0.52;
    2500, 0.62;
    5800, 0.98;
];

%% ═══════════════════════════════════════════════════════════════════
%  CONFIGURACIÓN DE LA GRÁFICA
%% ═══════════════════════════════════════════════════════════════════

CONFIG = struct();
CONFIG.titulo = 'Atenuación en cables coaxiales';
CONFIG.freq_min_MHz = 10;
CONFIG.freq_max_MHz = 20000;
CONFIG.mostrar_tabla_total = true;
CONFIG.output_file = 'cable_attenuation_plot.png';
CONFIG.dpi = 150;

% Tema más tranquilo - papel antiguo
TEMA = struct();
TEMA.fondo = [0.98, 0.96, 0.92];     % Beige claro - como papel viejo
TEMA.axes = [1, 1, 1];               % Blanco
TEMA.grid = [0.8, 0.8, 0.8];         % Gris clarito
TEMA.texto = [0.2, 0.2, 0.2];        % Gris oscuro
TEMA.lineas_grid = [0.85, 0.85, 0.85]; % Gris perla

%% ═══════════════════════════════════════════════════════════════════
%  PROCESAMIENTO
%% ═══════════════════════════════════════════════════════════════════

fprintf('\n========================================\n');
fprintf('  RESULTADOS DEL AJUSTE\n');
fprintf('========================================\n');

nCables = length(CABLES);
resultados = cell(nCables, 1);

for i = 1:nCables
    cable = CABLES(i);
    tabla = cable.tabla;
    freq_MHz = tabla(:, 1);
    att_dBm = tabla(:, 2);
    
    % Ajuste por mínimos cuadrados
    A = [sqrt(freq_MHz), freq_MHz];
    coef = A \ att_dBm;
    kdb1 = coef(1);
    kdb2 = coef(2);
    
    att_fit = kdb1 * sqrt(freq_MHz) + kdb2 * freq_MHz;
    rms = sqrt(mean((att_fit - att_dBm).^2));
    
    % Guardar resultados
    resultados{i} = struct(...
        'nombre', cable.nombre, ...
        'color', cable.color, ...
        'longitud', cable.longitud, ...
        'tabla', cable.tabla, ...
        'freq_MHz', freq_MHz, ...
        'att_dBm', att_dBm, ...
        'kdb1', kdb1, ...
        'kdb2', kdb2, ...
        'rms', rms);
    
    % Mostrar resultados
    fprintf('\n%s\n', cable.nombre);
    fprintf('  kdb1 = %.6f\n', kdb1);
    fprintf('  kdb2 = %.8f\n', kdb2);
    fprintf('  RMS  = %.5f dB/m\n', rms);
    
    if CONFIG.mostrar_tabla_total
        fprintf('  Pérdidas para L=%.3fm:\n', cable.longitud);
        for j = 1:length(freq_MHz)
            if freq_MHz(j) < 1000
                fprintf('    %4.0f MHz: %.2f dB\n', freq_MHz(j), att_dBm(j)*cable.longitud);
            else
                fprintf('    %4.0f GHz: %.2f dB\n', freq_MHz(j)/1000, att_dBm(j)*cable.longitud);
            end
        end
    end
end

%% ═══════════════════════════════════════════════════════════════════
%  GRÁFICA SENCILLA - ESTILO SORNERITO
%% ═══════════════════════════════════════════════════════════════════

% Crear figura con fondo clarito
fig = figure('Position', [100, 100, 1200, 700], 'Color', TEMA.fondo);
ax = axes('Parent', fig, 'Color', TEMA.axes, 'XScale', 'log', ...
    'XColor', TEMA.texto, 'YColor', TEMA.texto, ...
    'FontSize', 12, 'FontName', 'Helvetica', ...
    'GridColor', TEMA.lineas_grid, 'GridAlpha', 0.6, ...
    'MinorGridColor', TEMA.lineas_grid, 'MinorGridAlpha', 0.3);
hold(ax, 'on');
grid(ax, 'on');
grid(ax, 'minor');
box(ax, 'on');

% Frecuencias para curvas
f_curva = logspace(log10(CONFIG.freq_min_MHz), log10(CONFIG.freq_max_MHz), 500);

% Colores más tranquilos para cada cable
colores_suaves = [
    0.698, 0.400, 0.400;  % Terracota suave
    0.400, 0.600, 0.698;  % Azul sereno
    0.600, 0.498, 0.698;  % Lila tenue
    1.0, 0.627, 0.251;
];

% ── Curvas y puntos ──
for i = 1:nCables
    r = resultados{i};
    att_curva = r.kdb1 * sqrt(f_curva) + r.kdb2 * f_curva;
    
    % Línea del modelo - más fina y elegante
    plot(ax, f_curva, att_curva, 'Color', colores_suaves(i,:), ...
        'LineWidth', 2, 'LineStyle', '-', ...
        'DisplayName', r.nombre);
    
    % Puntos del fabricante - discretos
    scatter(ax, r.freq_MHz, r.att_dBm, 50, colores_suaves(i,:), ...
        'filled', 'MarkerEdgeColor', 'none', ...
        'MarkerFaceAlpha', 0.7, 'HandleVisibility', 'off');
    
    % Pequeñas etiquetas solo en puntos clave
    if i == 1
        idx_etiqueta = [1, 3, 6]; % Solo algunos puntos
    elseif i == 2
        idx_etiqueta = [1, 3, 5];
    else
        idx_etiqueta = [2, 4];
    end
    
    for j = idx_etiqueta
        fx = r.freq_MHz(j);
        fy = r.att_dBm(j);
        if fy < 1
            etiqueta = sprintf('%.3f', fy);
        else
            etiqueta = sprintf('%.2f', fy);
        end
        
        % Posiciones de texto más naturales
        if i == 1
            desplazamiento = [30, 0.02];
        elseif i == 2
            desplazamiento = [-50, -0.05];
        else
            desplazamiento = [20, -0.03];
        end
        
        text(ax, fx, fy, ['  ' etiqueta], 'FontSize', 10, ...
            'Color', colores_suaves(i,:), 'FontWeight', 'normal', ...
            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
    end
end

% ── Ejes con estilo minimalista ──
xlabel(ax, 'Frecuencia (MHz / GHz)', 'FontSize', 13, 'Color', TEMA.texto, 'FontWeight', 'normal');
ylabel(ax, 'Atenuación (dB/m)', 'FontSize', 13, 'Color', TEMA.texto, 'FontWeight', 'normal');
title(ax, CONFIG.titulo, 'FontSize', 16, 'Color', TEMA.texto, 'FontWeight', 'normal', ...
    'FontName', 'Helvetica');

% Ticks del eje X más naturales
set(ax, 'XLim', [CONFIG.freq_min_MHz, CONFIG.freq_max_MHz]);
ticks_x = [10, 100, 1000, 10000];
labels_x = {'10 MHz', '100 MHz', '1 GHz', '10 GHz'};
set(ax, 'XTick', ticks_x, 'XTickLabel', labels_x);

% Líneas verticales sutiles
for fx = [100, 1000]
    xline(ax, fx, '--', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 1, 'HandleVisibility', 'off');
end

% Leyenda simple y elegante
legend(ax, 'Location', 'northwest', 'FontSize', 11, ...
    'Color', 'none', 'EdgeColor', 'none', 'TextColor', TEMA.texto);



% Pequeña nota al pie
text(ax, 0.02, 0.02, sprintf('Modelo: kdb1·√f + kdb2·f'), ...
    'Units', 'normalized', 'FontSize', 10, 'Color', [0.5, 0.5, 0.5], ...
    'FontAngle', 'italic', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

% Guardar con fondo transparente (casi)
exportgraphics(fig, CONFIG.output_file, 'Resolution', CONFIG.dpi, 'BackgroundColor', TEMA.fondo);
fprintf('\nGráfica guardada: %s\n', CONFIG.output_file);

% Mostrar coeficientes de forma limpia
fprintf('\n========================================\n');
fprintf('COEFICIENTES DEL MODELO:\n');
fprintf('========================================\n');
for i = 1:nCables
    r = resultados{i};
    fprintf('%s:\n', r.nombre);
    fprintf('  k1 = %.6f  |  k2 = %.8f  |  RMS = %.5f\n', r.kdb1, r.kdb2, r.rms);
end
fprintf('========================================\n');