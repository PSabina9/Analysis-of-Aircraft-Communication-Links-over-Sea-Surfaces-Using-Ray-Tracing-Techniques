function startSecondInterface(f,txHeight,rxHeight)
%clear all fara pt ca sterge variabilele si nu mai functioneaza cum trebuie
%codul
close all;

    % ---------------- Parametri impliciti ----------------
    % Suprascriem valorile primite pentru a avea valori sigure de test.
    % Acest lucru garantează funcționarea aplicației chiar dacă GUI-ul
    % apelează funcția cu argumente goale.
    f = 167.5e6;                
    txHeight = 62*0.3048;       
    rxHeight = 5000*0.3048;

    % Variabile de stare accesibile în nested functions (scopul GUI)
    terrainChoice = 1;   
    weatherChoice = 1;   
    terrainName = "custom";

    % PARAMETRI TEREN – INITIAL (NECESAR CA SA RULEZE)
    terrainParams.Permittivity = 81;
    terrainParams.Conductivity = 4.64;

    % ---------------------------------------------------------------------
    %                  FEREASTRA PRINCIPALĂ A APLICAȚIEI
    % ---------------------------------------------------------------------
    Fig1 = figure('Name','Configurare și grafice', ...
        'Units','normalized','Position',[0.2 0.2 0.4 0.3], ...
        'NumberTitle','off','Color','#a2d8fc');

    % ---------------------------------------------------------------------
    %            PANOU STÂNGA — CONTROALE DE CONFIGURARE
    % ---------------------------------------------------------------------
    RadioGroup = uibuttongroup('Parent',Fig1,'Visible','on', ...
        'BackgroundColor','#cce6ff','Title','Configurare','FontSize',16, ...
        'TitlePosition','centertop','Position',[0.05 0.05 0.32 0.9]);
% --- Popup Terrain ---
uicontrol('Parent',RadioGroup,'Style','text','Units','normalized', ...
    'Position',[0.05 0.90 0.5 0.05],'BackgroundColor','#a2d8fc', ...
    'String','Material Teren:','FontSize',14,'HorizontalAlignment','left');
popupTerrain = uicontrol('Parent',RadioGroup,'Style','popupmenu','Units','normalized', ...
    'Position',[0.05 0.85 0.7 0.05],'BackgroundColor','#a2d8fc','FontSize',14, ...
    'String',{'Custom','Aer','Gheață','Apă oceanică (sărată)','Zăpadă','Apă'}, ...
    'Value',terrainChoice, 'Callback', @(s,e) onTerrainChange());

% --- Popup Weather ---
uicontrol('Parent',RadioGroup,'Style','text','Units','normalized', ...
    'Position',[0.05 0.78 0.5 0.05],'BackgroundColor','#a2d8fc', ...
    'String','Vreme:','FontSize',14,'HorizontalAlignment','left');
popupWeather = uicontrol('Parent',RadioGroup,'Style','popupmenu','Units','normalized', ...
    'Position',[0.05 0.73 0.7 0.05],'BackgroundColor','#a2d8fc','FontSize',14, ...
    'String',{'Spațiu liber','Ploaie','Ceață'}, ...
    'Value',weatherChoice, 'Callback', @(s,e) onWeatherChange());

% --- Puterea transmisă (mW) ---
uicontrol('Parent',RadioGroup,'Style','text','Units','normalized', ...
    'Position',[0.05 0.66 0.5 0.05],'String','Puterea (mW):','BackgroundColor','#a2d8fc', ...
    'FontSize',14,'HorizontalAlignment','left');
edit_mW = uicontrol('Parent',RadioGroup,'Style','edit','Units','normalized', ...
    'Position',[0.05 0.61 0.5 0.05],'String','10','BackgroundColor','white','FontSize',14, ...
    'Callback',@(s,e) safe_update_dBm());

% --- Puterea transmisă (dBm) ---
uicontrol('Parent',RadioGroup,'Style','text','Units','normalized', ...
    'Position',[0.05 0.54 0.5 0.05],'String','Puterea (dBm):','BackgroundColor','#a2d8fc', ...
    'FontSize',14,'HorizontalAlignment','left');
edit_dBm = uicontrol('Parent',RadioGroup,'Style','edit','Units','normalized', ...
    'Position',[0.05 0.49 0.5 0.05],'String','10','BackgroundColor','white','FontSize',14, ...
    'Callback',@(s,e) safe_update_mW());

% --- Titlu Site Viewer ---
uicontrol('Parent',RadioGroup,'Style','text','Units','normalized', ...
    'Position',[0.05 0.42 0.9 0.04],'BackgroundColor','#cce6ff', ...bun
    'FontSize',14,'FontWeight','bold','String','Selectați locația pentru Site Viewer');

% --- Dropdown locație Site Viewer ---
popupPort = uicontrol('Parent',RadioGroup,'Style','popupmenu','Units','normalized', ...
    'Position',[0.05 0.37 0.9 0.05],'BackgroundColor','white','FontSize',14, ...
    'String',{'Constanța','Vietnam','Golful Chesapeake'}, ...
    'Value',3);

% --- Buton Deschide Site Viewer ---
btnSite = uicontrol('Parent',RadioGroup,'Style','pushbutton','Units','normalized', ...
    'Position',[0.05 0.30 0.9 0.06],'String','Deschide Site Viewer', ...
    'FontSize',14,'BackgroundColor','#a2d8fc', ...
    'Callback',@(s,e) siteviewprop());

% --- Buton Actualizează Grafice ---
btnUpdate = uicontrol('Parent',RadioGroup,'Style','pushbutton','Units','normalized', ...
    'Position',[0.05 0.23 0.9 0.06],'String','Actualizează Grafice', ...
    'FontSize',14,'BackgroundColor','#a2d8fc', ...
    'Callback',@(s,e) recalcPlots());

    % ---------------------------------------------------------------------
    %                   PANOU DREAPTA — ZONA DE GRAFICE
    % ---------------------------------------------------------------------
    axesPanel = uipanel('Parent',Fig1,'Title','Grafice','FontSize',16, ...
        'BackgroundColor','#cce6ff','Units','normalized','Position',[0.40 0.05 0.55 0.9]);

ax1 = axes('Parent',axesPanel,'Position',[0.08 0.55 0.88 0.38]);
ax2 = axes('Parent',axesPanel,'Position',[0.08 0.08 0.88 0.38]);

  
    % ---------------------------------------------------------------------
    %                  DEFINIRE PORTURI (DOAR SITEVIEWER)
    % ---------------------------------------------------------------------
    numRxSV = 100;

    % Constanta
    ports(1).txLat = 44.0979;
    ports(1).txLon = 28.6536;
    ports(1).rxStart = [44.10 28.80];
    ports(1).rxEnd   = [44.05 29.05];

    % Vietnam
    ports(2).txLat = 16.1100;
    ports(2).txLon = 108.2300;
    ports(2).rxStart = [16.15 108.40];
    ports(2).rxEnd   = [16.05 108.55];

    % Chesapeake Bay, Maryland
ports(3).txLat = 38.298138;      % Latitudine Tx
ports(3).txLon = -76.374391;     % Longitudine Tx
ports(3).rxStart = [38.305 -76.366]; % început Rx
ports(3).rxEnd   = [38.25 -76.35]; % sfârșit Rx

    % ---------------------------------------------------------------------
    %                        NESTED FUNCTIONS
    % ---------------------------------------------------------------------

    function onTerrainChange()
        terrainChoice = popupTerrain.Value;
        switch terrainChoice
            case 1
                terrainName = "custom";
                terrainParams.Permittivity = 81;
                terrainParams.Conductivity = 4.64;
            case 2
                terrainName = "air";
                terrainParams.Permittivity = 1;
                terrainParams.Conductivity = 0;
            case 3
                terrainName = "ice";
                terrainParams.Permittivity = 3.2;
                terrainParams.Conductivity = 1e-4;
            case 4
                terrainName = "seawater";
                terrainParams.Permittivity = 80;
                terrainParams.Conductivity = 4;
            case 5
                terrainName = "snow";
                terrainParams.Permittivity = 1.5;
                terrainParams.Conductivity = 1e-3;
            case 6
                terrainName = "water";
                terrainParams.Permittivity = 80;
                terrainParams.Conductivity = 0.01;
        end
    end

    function onWeatherChange()
        weatherChoice = popupWeather.Value;
    end

    function safe_update_dBm()
        val = str2double(edit_mW.String);
        if isnan(val) || val <= 0, return; end
        edit_dBm.String = sprintf('%.2f',10*log10(val));
    end

    function safe_update_mW()
        val = str2double(edit_dBm.String);
        if isnan(val), return; end
        edit_mW.String = sprintf('%.2f',10^(val/10));
    end

    % ---------------------------------------------------------------------
    %     FUNCTIA PRINCIPALA DE GENERARE A GRAFICELOR — recalcPlots()
    % ---------------------------------------------------------------------
    function recalcPlots()

        cla(ax1); cla(ax2); 

        PmW = str2double(edit_mW.String);
        if isnan(PmW) || PmW <= 0
            errordlg("Introduceți o valoare validă pentru putere (mW) > 0");
            return;
        end

        txAntenna = design(dipoleCylindrical,f);
        rxAntenna = design(dipoleCylindrical,f);

        tx = txsite(Latitude=38.298138,Longitude=-76.374391, ...
            TransmitterFrequency=f,TransmitterPower=PmW, ...
            AntennaHeight=txHeight,Antenna=txAntenna);

        rxLat = linspace(38.25,38.15,100);
        rxLon = linspace(-76.50,-76.65,100);

        rx = rxsite(Latitude=rxLat,Longitude=rxLon, ...
            Antenna=rxAntenna,AntennaHeight=rxHeight);

        pm = propagationModel("raytracing", ...
            MaxNumReflections=1, ...
            TerrainMaterial=terrainName, ...
            TerrainMaterialPermittivity=terrainParams.Permittivity, ...
            TerrainMaterialConductivity=terrainParams.Conductivity);

        rays = raytrace(tx,rx,pm);
        pm.AngularSeparation = 0.2;
        raysLess = raytrace(tx,rx,pm);

        range = distance(tx,rx,"greatcircle");

        switch weatherChoice
            case 2
                weatherAtt_dB = 0.2*log10(1+25)*(range/1000);
            case 3
                weatherAtt_dB = 0.8*(range/1000);
            otherwise
                weatherAtt_dB = zeros(size(range));
        end

        % -----------------------------------------------------------------
        %                     GRAFIC 1 — Număr traiectorii
        % -----------------------------------------------------------------
        axes(ax1);
        if ~isempty(rays)
            numR = cellfun(@numel,rays);
        else
            numR = nan(size(range));
        end

        if ~isempty(raysLess)
            numR2 = cellfun(@numel,raysLess);
        else
            numR2 = nan(size(range));
        end

        plot(range/1e3, numR, 'o'); hold on;
        plot(range/1e3, numR2, 'x'); hold off;
        title('Număr traiectorii vs distanță');
        xlabel('Distanța (km)'); ylabel('Număr traiectorii');
        legend({'Separare unghiulară medie','Separare unghiulară 0,2°'}, 'Location','best');
 grid on;

        % -----------------------------------------------------------------
        %                     GRAFIC 2 — Path Gain (Ray vs FSPL)
        % -----------------------------------------------------------------
        axes(ax2);

        rayPL = nan(size(range));
        for kidx = 1:numel(rx)
            if isempty(raysLess{kidx}), continue; end
            E = sum(exp(1i*[raysLess{kidx}.PhaseShift]) ./ ...
                10.^([raysLess{kidx}.PathLoss]/20));
            rayPL(kidx) = -20*log10(abs(E));
        end
        rayPL = rayPL + weatherAtt_dB;

        FSPL = fspl(range,physconst('LightSpeed')/f);

        plot(range/1e3, -rayPL, 'o'); hold on;
        plot(range/1e3, -FSPL, '-'); hold off;
        title('Path Gain vs distanță');
        xlabel('Distanța (km)'); ylabel('Path Gain (dB)');
        legend({'Ray Tracing (0,2° AS) + Vreme','Spațiu liber'}, 'Location','best');
 grid on;

       
    % ---------------------------------------------------------------------
    %               AFIȘARE SITE VIEWER (DOAR VIZUAL)
    % ---------------------------------------------------------------------
function siteviewprop()
    try
        idx = popupPort.Value;
        p = ports(idx);

        % =================================================
        % Creează 100 Rx (coordonatele tale)
        % =================================================
        rxLatSV = linspace(p.rxStart(1), p.rxEnd(1), numRxSV);
        rxLonSV = linspace(p.rxStart(2), p.rxEnd(2), numRxSV);

        txAntSV = design(dipoleCylindrical, f);
        rxAntSV = design(dipoleCylindrical, f);

        txSV = txsite( ...
            Latitude=p.txLat, ...
            Longitude=p.txLon, ...
            TransmitterFrequency=f, ...   % IMPORTANT
            Antenna=txAntSV, ...
            AntennaHeight=txHeight);

        rxSV = rxsite( ...
            Latitude=rxLatSV, ...
            Longitude=rxLonSV, ...
            Antenna=rxAntSV, ...
            AntennaHeight=rxHeight);

        % =================================================
        % Deschide Site Viewer 
        % =================================================
        siteviewer(Terrain="none");   
        drawnow;

        % =============================================
        % Afișează antenele
        % =============================================
        show(txSV,ShowAntennaHeight=true);
        show(rxSV,ShowAntennaHeight=true);

        % =============================================
        % Ray tracing pentru toate rx
        % =============================================
        pmSV = propagationModel("raytracing", MaxNumReflections=1, ...
            TerrainMaterial=terrainName, ...
            TerrainMaterialPermittivity=terrainParams.Permittivity, ...
            TerrainMaterialConductivity=terrainParams.Conductivity);

        raysSV = raytrace(txSV, rxSV, pmSV);

        % =============================================
        % Afișează doar prima conexiune ca în exemplu
        % =============================================
        if ~isempty(raysSV{1})
            plot(raysSV{1});
        end

    catch err
        errordlg("Eroare Site Viewer: " + err.message);
    end
end
    end
end