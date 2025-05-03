% ----------------------------
% PLANIFICAREA TRANSPORTULUI AERIAN DE MARFA
% ----------------------------

function proiect()
    % Bucla principala pentru selectarea task-urilor
    continua = true;
    
    while continua
        % Afiseaza meniul de optiuni
        afiseazaMeniu();
        
        % Citeste selectia utilizatorului
        optiune = input('Introduceti numarul task-ului dorit: ');
        
        % Proceseaza selectia utilizatorului
        switch optiune
            case 1
                disp('Executare task 1: Planificarea rutelor de transport');
                executaTask1();
            case 2
                disp('Executare task 2: Analiza complexitatii algoritmului Dijkstra');
                executaTask2();
            case 3
                disp('Executare task 3: Comparare aeroporturi și rute');
                executaTask3();
            case 4
                disp('Executare task 4: Comparare algoritmi Dijkstra vs A*');
                executaTask4();
            case 5
                disp('Executare task 5: Vizualizare grafic aeroporturi');
                executaTask5();
            case 6
                disp('Executare task 6: Solutia naiva (zbor direct)');
                executaTask6();
            case 0
                disp('Ieșire din program');
                continua = false;
            otherwise
                disp('Optiune invalida! Va rugam sa alegeti un numar din meniu.');
        end
        
        % Verifica daca utilizatorul doreste sa continue
        if continua
            raspuns = input('Doriti sa executati un alt task? (da/nu): ', 's');
            if strcmpi(raspuns, 'nu') || strcmpi(raspuns, 'n')
                continua = false;
                disp('La revedere!');
            end
        end
    end
end

function afiseazaMeniu()
    fprintf('\n====== MENIU TASK-URI TRANSPORT AERIAN ======\n');
    fprintf('1. Planificarea rutelor de transport\n');
    fprintf('2. Analiza complexitatii algoritmului Dijkstra\n');
    fprintf('3. Comparare aeroporturi și rute\n');
    fprintf('4. Comparare algoritmi Dijkstra vs A*\n');
    fprintf('5. Vizualizare grafic aeroporturi\n');
    fprintf('6. Solutia naiva (zbor direct)\n');
    fprintf('0. Ieșire\n');
    fprintf('============================================\n');
end

function executaTask1()
    % Integrarea datelor din fișierul KML
    [lat, lon, names] = parseKML('aeroporturi.kml');

    % Selectam un subset de aeroporturi pentru exemplul nostru
    num_aeroporturi = 20;
    selected_indices = round(linspace(1, length(names), num_aeroporturi));

    % Aeroporturile selectate
    aeroporturi = names(selected_indices);
    coordonate = [lat(selected_indices), lon(selected_indices)];

    % Calcularea distantelor directe între aeroporturi (în km)
    costuri = zeros(num_aeroporturi);
    R = 6371; % Raza Pamântului în km
    for i = 1:num_aeroporturi
        for j = 1:num_aeroporturi
            if i ~= j
                dLat = deg2rad(coordonate(j,1) - coordonate(i,1));
                dLon = deg2rad(coordonate(j,2) - coordonate(i,2));
                a = sin(dLat/2)^2 + cos(deg2rad(coordonate(i,1))) * cos(deg2rad(coordonate(j,1))) * sin(dLon/2)^2;
                c = 2 * atan2(sqrt(a), sqrt(1-a));
                distance = R * c;
                if distance < 2000
                    costuri(i,j) = distance;
                else
                    costuri(i,j) = 0;
                end
            end
        end
    end

    % Verificam conectivitatea grafului
    G_test = graph(costuri~=0);
    bins = conncomp(G_test);
    if max(bins) > 1
        disp('Atentie: Graful nu este complet conectat!');
        for b = 2:max(bins)
            idx1 = find(bins == 1, 1);
            idx2 = find(bins == b, 1);
            dLat = deg2rad(coordonate(idx2,1) - coordonate(idx1,1));
            dLon = deg2rad(coordonate(idx2,2) - coordonate(idx1,2));
            a = sin(dLat/2)^2 + cos(deg2rad(coordonate(idx1,1))) * cos(deg2rad(coordonate(idx2,1))) * sin(dLon/2)^2;
            c = 2 * atan2(sqrt(a), sqrt(1-a));
            distance = R * c;
            costuri(idx1, idx2) = distance;
            costuri(idx2, idx1) = distance;
        end
    end

    disp('Aeroporturi selectate pentru planificarea transportului:');
    for i = 1:num_aeroporturi
        fprintf('%d. %s (%.4f, %.4f)\n', i, aeroporturi{i}, coordonate(i,1), coordonate(i,2));
    end

    % Alegere mod introducere cereri
    fprintf('\nMod introducere cereri:\n1. Aleator\n2. Manual\n');
    mod_cerere = input('Alege optiunea (1 sau 2): ');

    switch mod_cerere
        case 1
            num_cereri = 10;
            cereri = cell(num_cereri, 3);
            for i = 1:num_cereri
                idx1 = randi(num_aeroporturi);
                idx2 = randi(num_aeroporturi);
                while idx2 == idx1
                    idx2 = randi(num_aeroporturi);
                end
                cereri{i,1} = aeroporturi{idx1};
                cereri{i,2} = aeroporturi{idx2};
                cereri{i,3} = randi([1, 8]);
            end
        case 2
            num_cereri = input('Câte cereri dorești sa introduci?: ');
            cereri = cell(num_cereri, 3);
            for i = 1:num_cereri
                fprintf('\n--- Cerere %d ---\n', i);
                idx1 = input('Index aeroport plecare: ');
                idx2 = input('Index aeroport destinatie: ');
                while idx2 == idx1
                    disp('Destinatia nu poate fi aceeași. Reintrodu.');
                    idx2 = input('Index aeroport destinatie: ');
                end
                marfa = input('Cantitate marfa (tone): ');
                cereri{i,1} = aeroporturi{idx1};
                cereri{i,2} = aeroporturi{idx2};
                cereri{i,3} = marfa;
            end
        otherwise
            error('Optiune invalida. Se folosește modul aleator.');
            num_cereri = 5;
            cereri = cell(num_cereri, 3);
            for i = 1:num_cereri
                idx1 = randi(num_aeroporturi);
                idx2 = randi(num_aeroporturi);
                while idx2 == idx1
                    idx2 = randi(num_aeroporturi);
                end
                cereri{i,1} = aeroporturi{idx1};
                cereri{i,2} = aeroporturi{idx2};
                cereri{i,3} = randi([1, 8]);
            end
    end

    capacitate_avion = 10;
    factor_emisii = 0.05;

    total_cost = 0;
    total_emisii = 0;
    total_distanta = 0;
    rute_salvate = cell(num_cereri, 1);

    disp('--- Rute optime pentru cereri ---');
    for i = 1:size(cereri,1)
        plecare = cereri{i,1};
        destinatie = cereri{i,2};
        marfa = cereri{i,3};
        
        if marfa > capacitate_avion
            fprintf('\n[!] Cerere %d depașește capacitatea avionului (%.0f > %.0f tone) — Se va împarti în zboruri multiple!\n', i, marfa, capacitate_avion);
        end

        start_idx = find(strcmp(aeroporturi, plecare));
        end_idx = find(strcmp(aeroporturi, destinatie));

        [dist, path] = dijkstra(costuri, start_idx, end_idx);
        rute_salvate{i} = path;
        cost = dist * marfa;
        emisii = dist * marfa * factor_emisii;

        fprintf('\nCerere %d: %s -> %s (%.0f tone)\n', i, plecare, destinatie, marfa);
        fprintf('Ruta: ');
        for j = 1:length(path)
            fprintf('%s', aeroporturi{path(j)});
            if j < length(path), fprintf(' -> '); end
        end
        fprintf('\nDistanta totala: %.2f km\nCost transport: %.2f unitati\nEmisii estimate: %.2f kg CO2\n', dist, cost, emisii);

        total_cost = total_cost + cost;
        total_emisii = total_emisii + emisii;
        total_distanta = total_distanta + dist;
    end

    fprintf('\n==============================\n Rezumat total transport:\n------------------------------\n');
    fprintf(' Numar cereri: %d\n Distanta totala: %.2f km\n Cost total: %.2f unitati\n Emisii totale: %.2f kg CO2\n==============================\n', size(cereri,1), total_distanta, total_cost, total_emisii);
    
    % Intreaba utilizatorul daca doreste sa vizualizeze harta
    vizualizare = input('\nDoriti sa vizualizati harta cu rutele? (1=Da/0=Nu): ');
    if vizualizare == 1
        figure;
        worldmap([min(coordonate(:,1))-5, max(coordonate(:,1))+5], ...
                 [min(coordonate(:,2))-5, max(coordonate(:,2))+5]);
        geoshow('landareas.shp', 'FaceColor', [0.8 0.8 0.8]);
        geoshow(coordonate(:,1), coordonate(:,2), 'DisplayType', 'point', ...
                'Marker', 'o', 'MarkerFaceColor', 'blue', 'MarkerSize', 8);
        textm(coordonate(:,1), coordonate(:,2), aeroporturi, 'FontSize', 8);
        colors = lines(size(cereri,1));
        for i = 1:size(cereri,1)
            path = rute_salvate{i};
            for j = 1:length(path)-1
                lat_segment = [coordonate(path(j),1); coordonate(path(j+1),1)];
                lon_segment = [coordonate(path(j),2); coordonate(path(j+1),2)];
                geoshow(lat_segment, lon_segment, 'Color', colors(i,:), 'LineWidth', 2);
            end
        end
        title('Rute transport marfa');
    end
end
function executaTask2()
    fprintf('\n[Task 2] Complexitatea algoritmului Dijkstra\n');
    fprintf('Pentru implementarea cu matrice de adiacenta:\n');
    fprintf('- Complexitate de timp: O(n^2) unde n este numarul de noduri\n');
    fprintf('- În cazul unei implementari cu coada de prioritati: O((n+e)*log n)\n');
    fprintf('  unde n este numarul de noduri și e numarul de muchii\n');
    fprintf('- Spatiu: O(n) pentru distante și marcaje de vizitare\n');
end

function executaTask3()
    [lat, lon, names] = parseKML('aeroporturi.kml');
    
    fprintf('\n[Task 3] Comparare aeroporturi și rute\n');
    
    % Calculeaza si afiseaza cateva statistici
    fprintf('Numar total de aeroporturi în fișier: %d\n', length(names));
    
    % Afiseaza primele 5 aeroporturi
    fprintf('\nPrimele 5 aeroporturi:\n');
    for i = 1:min(5, length(names))
        fprintf('%d. %s (%.4f, %.4f)\n', i, names{i}, lat(i), lon(i));
    end
    
    % Calculeaza distantele intre primele 3 aeroporturi
    fprintf('\nDistante între primele 3 aeroporturi:\n');
    R = 6371; % Raza Pamantului in km
    for i = 1:min(3, length(names))
        for j = i+1:min(3, length(names))
            dLat = deg2rad(lat(j) - lat(i));
            dLon = deg2rad(lon(j) - lon(i));
            a = sin(dLat/2)^2 + cos(deg2rad(lat(i))) * cos(deg2rad(lat(j))) * sin(dLon/2)^2;
            c = 2 * atan2(sqrt(a), sqrt(1-a));
            distance = R * c;
            fprintf('%s -> %s: %.2f km\n', names{i}, names{j}, distance);
        end
    end
end

function executaTask4()
    % Integrarea datelor din fisierul KML
    [lat, lon, names] = parseKML('aeroporturi.kml');
    num_aeroporturi = 10;
    selected_indices = round(linspace(1, length(names), num_aeroporturi));
    
    % Aeroporturile selectate
    aeroporturi = names(selected_indices);
    coordonate = [lat(selected_indices), lon(selected_indices)];
    
    % Calcularea distantelor directe între aeroporturi (în km)
    costuri = zeros(num_aeroporturi);
    R = 6371; % Raza Pamantului in km
    for i = 1:num_aeroporturi
        for j = 1:num_aeroporturi
            if i ~= j
                dLat = deg2rad(coordonate(j,1) - coordonate(i,1));
                dLon = deg2rad(coordonate(j,2) - coordonate(i,2));
                a = sin(dLat/2)^2 + cos(deg2rad(coordonate(i,1))) * cos(deg2rad(coordonate(j,1))) * sin(dLon/2)^2;
                c = 2 * atan2(sqrt(a), sqrt(1-a));
                distance = R * c;
                if distance < 2000
                    costuri(i,j) = distance;
                else
                    costuri(i,j) = 0;
                end
            end
        end
    end
    
    % Verificam conectivitatea grafului
    G_test = graph(costuri~=0);
    bins = conncomp(G_test);
    if max(bins) > 1
        disp('Atentie: Graful nu este complet conectat!');
        for b = 2:max(bins)
            idx1 = find(bins == 1, 1);
            idx2 = find(bins == b, 1);
            dLat = deg2rad(coordonate(idx2,1) - coordonate(idx1,1));
            dLon = deg2rad(coordonate(idx2,2) - coordonate(idx1,2));
            a = sin(dLat/2)^2 + cos(deg2rad(coordonate(idx1,1))) * cos(deg2rad(coordonate(idx2,1))) * sin(dLon/2)^2;
            c = 2 * atan2(sqrt(a), sqrt(1-a));
            distance = R * c;
            costuri(idx1, idx2) = distance;
            costuri(idx2, idx1) = distance;
        end
    end
    
    % Generam o cerere de transport pentru testare
    start_idx = randi(num_aeroporturi);
    end_idx = randi(num_aeroporturi);
    while end_idx == start_idx
        end_idx = randi(num_aeroporturi);
    end
    
    fprintf('\n[Task 4] Comparare algoritmi Dijkstra vs A*\n');
    fprintf('Ruta: %s -> %s\n', aeroporturi{start_idx}, aeroporturi{end_idx});
    
    % Masurarea timpului pentru Dijkstra
    tic;
    [dist_d, path_d] = dijkstra(costuri, start_idx, end_idx);
    timp_dijkstra = toc;
    
    % Masurarea timpului pentru A*
    tic;
    [dist_a, path_a] = astar(costuri, coordonate, start_idx, end_idx);
    timp_astar = toc;
    
    % Afisarea rezultatelor
    fprintf('\nDijkstra:\n');
    fprintf('- Distanta: %.2f km\n', dist_d);
    fprintf('- Numar de noduri în ruta: %d\n', length(path_d));
    fprintf('- Timp executie: %.6f secunde\n', timp_dijkstra);
    fprintf('- Ruta: ');
    for j = 1:length(path_d)
        fprintf('%s', aeroporturi{path_d(j)});
        if j < length(path_d), fprintf(' -> '); end
    end
    fprintf('\n');
    
    fprintf('\nA*:\n');
    fprintf('- Distanta: %.2f km\n', dist_a);
    fprintf('- Numar de noduri în ruta: %d\n', length(path_a));
    fprintf('- Timp executie: %.6f secunde\n', timp_astar);
    fprintf('- Ruta: ');
    for j = 1:length(path_a)
        fprintf('%s', aeroporturi{path_a(j)});
        if j < length(path_a), fprintf(' -> '); end
    end
    fprintf('\n');
    
    % Comparare directa
    fprintf('\nComparatie:\n');
    fprintf('- Raport timp (A*/Dijkstra): %.2f\n', timp_astar/timp_dijkstra);
    if dist_d == dist_a
        fprintf('- Ambii algoritmi au gasit aceeași distanta optima\n');
    else
        fprintf('- Diferenta de distanta: %.2f km\n', dist_a - dist_d);
    end
end

function executaTask5()
    % Integrarea datelor din fisierul KML
    [lat, lon, names] = parseKML('aeroporturi.kml');

    % Selectam un subset de aeroporturi pentru exemplul nostru
    num_aeroporturi = 10;
    selected_indices = round(linspace(1, length(names), num_aeroporturi));
    
    % Aeroporturile selectate
    aeroporturi = names(selected_indices);
    coordonate = [lat(selected_indices), lon(selected_indices)];
    
    % Calcularea distantelor directe între aeroporturi (in km)
    costuri = zeros(num_aeroporturi);
    R = 6371; % Raza Pamantului în km
    for i = 1:num_aeroporturi
        for j = 1:num_aeroporturi
            if i ~= j
                dLat = deg2rad(coordonate(j,1) - coordonate(i,1));
                dLon = deg2rad(coordonate(j,2) - coordonate(i,2));
                a = sin(dLat/2)^2 + cos(deg2rad(coordonate(i,1))) * cos(deg2rad(coordonate(j,1))) * sin(dLon/2)^2;
                c = 2 * atan2(sqrt(a), sqrt(1-a));
                distance = R * c;
                if distance < 2000
                    costuri(i,j) = distance;
                else
                    costuri(i,j) = 0;
                end
            end
        end
    end
    
    % Cream un grafic pentru vizualizare
    figure;
    
    % Plotam aeroporturile pe harta
    geoplot(coordonate(:,1), coordonate(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    hold on;
    
    for i = 1:num_aeroporturi
        text(coordonate(i,2), coordonate(i,1), aeroporturi{i}, 'FontSize', 8);
    end
   
    for i = 1:num_aeroporturi
        for j = i+1:num_aeroporturi
            if costuri(i,j) > 0
                plot([coordonate(i,2), coordonate(j,2)], [coordonate(i,1), coordonate(j,1)], 'b-', 'LineWidth', 1);
            end
        end
    end
    
    title('Reteaua de aeroporturi și rute disponibile');
    xlabel('Longitudine');
    ylabel('Latitudine');
    geobasemap('streets');
    
    fprintf('\n[Task 5] Vizualizare grafica a retelei de aeroporturi\n');
    fprintf('- S-a generat graficul cu toate cele %d aeroporturi\n', num_aeroporturi);
    fprintf('- Aeroporturile sunt marcate cu puncte roșii\n');
    fprintf('- Rutele disponibile sunt desenate cu linii albastre\n');
end

function executaTask6()
    % Integrarea datelor din fișierul KML
    [lat, lon, names] = parseKML('aeroporturi.kml');

    % Selectam un subset de aeroporturi pentru exemplul nostru
    num_aeroporturi = 10;
    selected_indices = round(linspace(1, length(names), num_aeroporturi));
    
    % Aeroporturile selectate
    aeroporturi = names(selected_indices);
    coordonate = [lat(selected_indices), lon(selected_indices)];
    
    fprintf('\n[Task 6] Solutia naiva (zbor direct)\n');
    
    % Alegem doua aeroporturi aleator
    idx1 = randi(num_aeroporturi);
    idx2 = randi(num_aeroporturi);
    while idx2 == idx1
        idx2 = randi(num_aeroporturi);
    end
    
    fprintf('Ruta solicitata: %s -> %s\n', aeroporturi{idx1}, aeroporturi{idx2});
    
    % Calculam distanta directa
    R = 6371;
    dLat = deg2rad(coordonate(idx2,1) - coordonate(idx1,1));
    dLon = deg2rad(coordonate(idx2,2) - coordonate(idx1,2));
    a = sin(dLat/2)^2 + cos(deg2rad(coordonate(idx1,1))) * cos(deg2rad(coordonate(idx2,1))) * sin(dLon/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    distanta_directa = R * c;
    
    fprintf('- Distanta zbor direct: %.2f km\n', distanta_directa);
    
    % Calcularea costurilor pentru toate perechile
    costuri = zeros(num_aeroporturi);
    for i = 1:num_aeroporturi
        for j = 1:num_aeroporturi
            if i ~= j
                dLat = deg2rad(coordonate(j,1) - coordonate(i,1));
                dLon = deg2rad(coordonate(j,2) - coordonate(i,2));
                a = sin(dLat/2)^2 + cos(deg2rad(coordonate(i,1))) * cos(deg2rad(coordonate(j,1))) * sin(dLon/2)^2;
                c = 2 * atan2(sqrt(a), sqrt(1-a));
                distance = R * c;
                if distance < 2000
                    costuri(i,j) = distance;
                else
                    costuri(i,j) = 0;
                end
            end
        end
    end
    
    % Verifica daca exista zbor direct disponibil (sub 2000 km)
    if distanta_directa < 2000
        fprintf('- Zbor direct disponibil (sub 2000 km)\n');
        fprintf('- Cost estimat: %.2f unitati\n', distanta_directa);
        fprintf('- Emisii estimate: %.2f kg CO2\n', distanta_directa * 0.05);
    else
        fprintf('- Zbor direct indisponibil (peste 2000 km)\n');
        fprintf('- Este necesara o ruta cu escale\n');
        
        % Calculam ruta cu Dijkstra
        [dist, path] = dijkstra(costuri, idx1, idx2);
        
        fprintf('- Ruta recomandata cu escale: ');
        for j = 1:length(path)
            fprintf('%s', aeroporturi{path(j)});
            if j < length(path), fprintf(' -> '); end
        end
        fprintf('\n- Distanta totala: %.2f km\n', dist);
        fprintf('- Cost estimat: %.2f unitati\n', dist);
        fprintf('- Emisii estimate: %.2f kg CO2\n', dist * 0.05);
    end
end

function [dist, path] = dijkstra(costuri, start_idx, end_idx)
    n = size(costuri, 1);
    dist = inf(1, n);
    dist(start_idx) = 0;
    vizitat = false(1, n);
    parinte = zeros(1, n);
    while any(~vizitat)
        [~, u] = min(dist + vizitat * 1e10);
        vizitat(u) = true;
        if u == end_idx, break; end
        for v = 1:n
            if costuri(u, v) > 0 && ~vizitat(v)
                if dist(u) + costuri(u, v) < dist(v)
                    dist(v) = dist(u) + costuri(u, v);
                    parinte(v) = u;
                end
            end
        end
    end
    path = end_idx;
    while path(1) ~= start_idx
        path = [parinte(path(1)), path];
    end
    dist = dist(end_idx);
end

function [dist, path] = astar(costuri, coordonate, start_idx, end_idx)
    n = size(costuri, 1);
    dist = inf(1, n);
    dist(start_idx) = 0;
    parinte = zeros(1, n);
    openSet = true(1, n);
    fScore = inf(1, n);
    h = zeros(1, n);
    R = 6371;
    for i = 1:n
        dLat = deg2rad(coordonate(end_idx,1) - coordonate(i,1));
        dLon = deg2rad(coordonate(end_idx,2) - coordonate(i,2));
        a = sin(dLat/2)^2 + cos(deg2rad(coordonate(i,1))) * cos(deg2rad(coordonate(end_idx,1))) * sin(dLon/2)^2;
        c = 2 * atan2(sqrt(a), sqrt(1 - a));
        h(i) = R * c;
    end
    fScore(start_idx) = h(start_idx);
    while any(openSet)
        [~, u] = min(fScore + ~openSet * 1e10);
        openSet(u) = false;
        if u == end_idx, break; end
        for v = 1:n
            if costuri(u,v) > 0 && openSet(v)
                tentative_gScore = dist(u) + costuri(u,v);
                if tentative_gScore < dist(v)
                    parinte(v) = u;
                    dist(v) = tentative_gScore;
                    fScore(v) = dist(v) + h(v);
                end
            end
        end
    end
    path = end_idx;
    while path(1) ~= start_idx
        path = [parinte(path(1)), path];
    end
    dist = dist(end_idx);
end

function [lat, lon, names] = parseKML(kmlFile)
    xDoc = xmlread(kmlFile);
    placemarks = xDoc.getElementsByTagName('Placemark');
    numPlacemarks = placemarks.getLength;
    lat = zeros(numPlacemarks, 1);
    lon = zeros(numPlacemarks, 1);
    names = cell(numPlacemarks, 1);
    count = 0;
    for i = 0:numPlacemarks-1
        placemark = placemarks.item(i);
        nameNodes = placemark.getElementsByTagName('name');
        if nameNodes.getLength > 0
            name = char(nameNodes.item(0).getTextContent);
        else
            name = ['Aeroport ', num2str(i+1)];
        end
        pointNodes = placemark.getElementsByTagName('Point');
        if pointNodes.getLength > 0
            point = pointNodes.item(0);
            coordNodes = point.getElementsByTagName('coordinates');
            if coordNodes.getLength > 0
                coordStr = char(coordNodes.item(0).getTextContent);
                coordParts = strsplit(strtrim(coordStr), ',');
                if length(coordParts) >= 2
                    count = count + 1;
                    lon(count) = str2double(coordParts{1});
                    lat(count) = str2double(coordParts{2});
                    names{count} = name;
                end
            end
        end
    end
    lat = lat(1:count);
    lon = lon(1:count);
    names = names(1:count);
end