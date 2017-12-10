%% Setup
clear; clc; close all;
ne = input('Inserte el número de elementos que componen a la estructura\n');
nn = input('Inserte el número de nodos que componen a la estructura\n');

n = 1; % Nodo en registro
nodos = struct; % Base de datos de nodos:
for i=1:nn, nodos.(['nodo_',num2str(i)]) = struct('x',1e10,'y',1e10); end
k_total = zeros(nn*3); % Matriz de Rigidez Total

fn = zeros(nn*3,1); % Vector de Fuerzas Nodales

%% Generar Elementos y su Contribución a la Matriz Global
for i=1:ne
    % Elemento en registro: elementos.(['elemento_',num2str(i)])
    xi = input(['Coordenada x inicial del elemento ',num2str(i),'\n']);
    yi = input(['Coordenada y inicial del elemento ',num2str(i),'\n']);
    xf = input(['Coordenada x final del elemento ',num2str(i),'\n']);
    yf = input(['Coordenada y final del elemento ',num2str(i),'\n']);
    % Verificación de existencia o creación del nodo inicial
    ni_existe = false; % Se asume que no existe
    for j=1:nn % Se busca que exista y si existe se asigna al elemento
        if nodos.(['nodo_',num2str(j)]).x == xi && nodos.(['nodo_',num2str(j)]).y == yi
            elementos.(['elemento_',num2str(i)]).nodo_inicial = j; ni_existe = true; break
        end
    end
    if ~ni_existe % Si no existe se asigna el nodo en registro al elemento y se "crea" el nodo en registro
        elementos.(['elemento_',num2str(i)]).nodo_inicial = n; 
        nodos.(['nodo_',num2str(n)]).x = xi;
        nodos.(['nodo_',num2str(n)]).y = yi;
        n = n + 1;
    end
    % Verificación de existencia o creación del nodo final
    nf_existe = false;
    for j=1:nn
        if nodos.(['nodo_',num2str(j)]).x == xf && nodos.(['nodo_',num2str(j)]).y == yf
            elementos.(['elemento_',num2str(i)]).nodo_final = j; nf_existe = true; break
        end
    end
    if ~nf_existe
        elementos.(['elemento_',num2str(i)]).nodo_final = n;
        nodos.(['nodo_',num2str(n)]).x = xf;
        nodos.(['nodo_',num2str(n)]).y = yf;
        n = n + 1;
    end
    
    elementos.(['elemento_',num2str(i)]).largo = sqrt( (xf-xi)^2 + (yf-yi)^2 );
    elementos.(['elemento_',num2str(i)]).theta = atan( (yf-yi)/(xf-xi) );
    if input('¿Desea cambiar E, I o A?\nSí: 1\nNo: 0\n')
        E = input(['Inserte el módulo de Elasticidad del elemento ',num2str(i),'\n']); % 2e11; 
        I = input(['Inserte la Inercia del elemento ',num2str(i),' I=0 para barras\n']); % 171/100^4;
        A = input(['Inserte el área de la ST del elemento ',num2str(i),' A=0 para vigas\n']); % 10.6/100^2 pi*0.025^2; 
    end
    elementos.(['elemento_',num2str(i)]).e = E;
    elementos.(['elemento_',num2str(i)]).inercia = I;
    elementos.(['elemento_',num2str(i)]).area = A;    
    elementos.(['elemento_',num2str(i)]).k = RigidezLocal(elementos.(['elemento_',num2str(i)]).e,elementos.(['elemento_',num2str(i)]).inercia,elementos.(['elemento_',num2str(i)]).area,elementos.(['elemento_',num2str(i)]).largo);
    theta = elementos.(['elemento_',num2str(i)]).theta;
    % Matriz de Transformación
    T = [ cos(theta), -sin(theta), 0,0,0,0; sin(theta), cos(theta), 0,0,0,0; 0, 0, 1,0,0,0; 0,0,0,cos(theta), -sin(theta), 0; 0,0,0, sin(theta), cos(theta), 0; 0,0,0, 0, 0, 1 ];
    elementos.(['elemento_',num2str(i)]).k_global = T * elementos.(['elemento_',num2str(i)]).k * transpose(T); % Matriz de Rigidez Global del Elemento
    % Suma de la contribución del elemento a la rigidez total
    for j=1:3
        for k=1:3
            ji = j + (elementos.(['elemento_',num2str(i)]).nodo_inicial-1)*3;
            ki = k + (elementos.(['elemento_',num2str(i)]).nodo_inicial-1)*3;
            jf = j + (elementos.(['elemento_',num2str(i)]).nodo_final-1)*3;
            kf = k + (elementos.(['elemento_',num2str(i)]).nodo_final-1)*3;
            k_total(ji,ki) = k_total(ji,ki) + elementos.(['elemento_',num2str(i)]).k_global(j,k); % Primer Cuadrante            
            k_total(jf,kf) = k_total(jf,kf) + elementos.(['elemento_',num2str(i)]).k_global(j+3,k+3); % Cuarto Cuadrante
            k_total(ji,kf) = k_total(ji,kf) + elementos.(['elemento_',num2str(i)]).k_global(j,k+3); 
            k_total(jf,ki) = k_total(jf,ki) + elementos.(['elemento_',num2str(i)]).k_global(j+3,k);
        end
    end
end
%% Generar el Vector de Fuerzas Nodales
for i=1:input('¿Cuántas Fuerzas Nodales Existen?\n')
    elemento = input(['¿En qué elemento se encuentra la Fuerza Nodal ', num2str(i),'?\n']);
    if input(['¿En qué nodo se encuentra la Fuerza Nodal ', num2str(i),'?\nInicial: 1\nFinal: 0\n'])
        lugar = 'nodo_inicial'; else lugar = 'nodo_final'; end
    gl = input(['¿La Fuerza Nodal ', num2str(i),'es?\nHorizontal: 1\nVertical: 2\nMomento: 3\n']); % Es el caso general, no es "necesario" hacer casos particulares
    j = (elementos.(['elemento_',num2str(elemento)]).(lugar)-1)*3 + gl;
    fn(j) = input(['Ingrese la magnitud de la Fuerza Nodal ', num2str(i),'\n']);
end
%% Generar kpp y fpp
GLR = zeros(input('¿Cuántos grados de libertad restringidos existen?\n'),1);
for i=1:length(GLR)
    elemento = input(['¿En qué elemento se encuentra el gl restringido ', num2str(i),'?\n']);
    if input(['¿En qué nodo se encuentra el gl restringido ', num2str(i),'?\nInicial: 1\nFinal: 0\n'])
        lugar = 'nodo_inicial'; else, lugar = 'nodo_final'; end
    gl = input(['¿El gl restringido ', num2str(i),'es?\nEl desplazamiento en x: 1\nEl desplazamiento en y: 2\nLa rotación: 3\n']); % Es el caso general, no es "necesario" hacer casos particulares
    GLR(i) = (elementos.(['elemento_',num2str(elemento)]).(lugar)-1)*3 + gl;
end
% Formar Kpp
GLLi = 0;
GLL = nn*3-length(GLR);
kpp = zeros(GLL);
for i=1:nn*3
    for j=1:nn*3
        if ~ismember(i,GLR) && ~ismember(j,GLR)
            kpp(mod(GLLi,GLL)+1,ceil((GLLi+1)/GLL)) = k_total(j,i);
            GLLi = GLLi + 1;            
        end
    end
end
GLLi = 1;
fpp = zeros(GLL,1);
for i=1:nn*3
    if ~ismember(i,GLR)
        fpp(GLLi) = fn(i);
        GLLi = GLLi + 1;
    end
end
%% Resolver los Desplazamientos
deltapp = kpp^-1*fpp;  % Vector de desplazamientos
%% Calcular Reacciones
GLLi = 1;
delta = zeros(nn*3,1);
for i=1:nn*3
    if ~ismember(i,GLR)
        delta(i) = deltapp(GLLi);
        GLLi = GLLi + 1;
    end
end
R =  k_total*delta; % Vector de Reacciones
%% Graficar
% crear el vector de nodos
nodosv = zeros(nn,2);
for i=1:nn
   nodosv(i,1) = nodos.(['nodo_',num2str(i)]).x;
   nodosv(i,2) = nodos.(['nodo_',num2str(i)]).y; 
end
% graficar estructura sin deformar
plot(nodosv(:,1),nodosv(:,2),'k.')
hold on; axis equal;
for i=1:ne
    nodose = [ elementos.(['elemento_',num2str(i)]).nodo_inicial elementos.(['elemento_',num2str(i)]).nodo_final ];
    nodoxy = nodosv(nodose, :);
    plot(nodoxy(:,1),nodoxy(:,2),'k--')
end
% Graficar estructura deformada
lupa = 100;
delta_ordenado = transpose(reshape(delta,3,nn));
nodosv2 = nodosv + lupa*delta_ordenado(:,1:2);
plot(nodosv2(:,1),nodosv2(:,2),'o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10)
for i=1:ne
    nodose = [ elementos.(['elemento_',num2str(i)]).nodo_inicial elementos.(['elemento_',num2str(i)]).nodo_final ];
    nodoxy = nodosv2(nodose, :);
    plot(nodoxy(:,1),nodoxy(:,2),'k-','LineWidth',2)
end
%% Generar archivo con variables generadas
save metodo_de_rigidez elementos k_total nodos kpp delta fn fpp 