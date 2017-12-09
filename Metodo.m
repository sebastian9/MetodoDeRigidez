%% Setup
clear; clc; close all;
ne = 2; % input('Inserte el n�mero de elementos que componen a la estructura\n');
nn = 3; % input('Inserte el n�mero de nodos que componen a la estructura\n');

n = 1; % Nodo en registro
nodos = struct; % Base de datos de nodos:
for i=1:nn, nodos.(['nodo_',num2str(i)]) = struct('x',100000,'y',100000); end
k_total = zeros(nn*3); % Matriz de Rigidez Total

fn = zeros(nn*3,1); % Vector de Fuerzas Nodales
feq = fn; % Vector de Fuerzas Equivalentes

%% Generar Elementos y su Contribuci�n a la Matriz Global
for i=1:ne
    % Elemento en registro: elementos.(['elemento_',num2str(i)])
    
    xi = input(['Coordenada x inicial del elemento ',num2str(i),'\n']);
    yi = input(['Coordenada y inicial del elemento ',num2str(i),'\n']);
    xf = input(['Coordenada x final del elemento ',num2str(i),'\n']);
    yf = input(['Coordenada y final del elemento ',num2str(i),'\n']);
    % Verificaci�n de existencia o creaci�n del nodo inicial
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
    % Verificaci�n de existencia o creaci�n del nodo final
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
    if input('�Desea cambiar E, I o A?\nS�: 1\nNo: 0\n')
        E = input(['Inserte el m�dulo de Elasticidad del elemento ',num2str(i),'\n']); % 2e11; 
        I = input(['Inserte la Inercia del elemento ',num2str(i),' I=0 para barras\n']); % 171/100^4;
        A = input(['Inserte el �rea de la ST del elemento ',num2str(i),' A=0 para vigas\n']); % 6/100^2; 
    end
    elementos.(['elemento_',num2str(i)]).e = E;
    elementos.(['elemento_',num2str(i)]).inercia = I;
    elementos.(['elemento_',num2str(i)]).area = A;    
    elementos.(['elemento_',num2str(i)]).k = RigidezLocal(elementos.(['elemento_',num2str(i)]).e,elementos.(['elemento_',num2str(i)]).inercia,elementos.(['elemento_',num2str(i)]).area,elementos.(['elemento_',num2str(i)]).largo);
    theta = elementos.(['elemento_',num2str(i)]).theta;
    % Matriz de Transformaci�n
    T = [ cos(theta), -sin(theta), 0,0,0,0; sin(theta), cos(theta), 0,0,0,0; 0, 0, 1,0,0,0; 0,0,0,cos(theta), -sin(theta), 0; 0,0,0, sin(theta), cos(theta), 0; 0,0,0, 0, 0, 1 ];
    elementos.(['elemento_',num2str(i)]).k_global = T * elementos.(['elemento_',num2str(i)]).k * transpose(T); % Matriz de Rigidez Global del Elemento
    % Suma de la contribuci�n del elemento a la rigidez total
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
%}
%% Generar el Vector de Fuerzas Nodales 
for i=1:input('�Cu�ntas Fuerzas Nodales Existen?\n')
    elemento = input(['�En qu� elemento se encuentra la Fuerza Nodal ', num2str(i),'?\n']);
    if input(['�En qu� nodo se encuentra la Fuerza Nodal ', num2str(i),'?\nInicial: 1\nFinal: 0\n'])
        lugar = 'nodo_inicial'; else lugar = 'nodo_final'; end
    gl = input(['�La Fuerza Nodal ', num2str(i),'es?\nHorizontal: 1\nVertical: 2\nMomento: 3\n']); % Es el caso general, no es "necesario" hacer casos particulares
    j = (elementos.(['elemento_',num2str(elemento)]).(lugar)-1)*3 + gl;
    fn(j) = input(['Ingrese la magnitud de la Fuerza Nodal ', num2str(i),'\n']);
end
%% Generar k_total_pp, fn_pp, y feq_pp
k_total_pp = k_total;
fn_pp = fn;
for i=1:input('�Cu�ntas grados de libertad restringidos existen?\n')
    elemento = input(['�En qu� elemento se encuentra el gl restringido ', num2str(i),'?\n']);
    if input(['�En qu� nodo se encuentra el gl restringido ', num2str(i),'?\nInicial: 1\nFinal: 0\n'])
        lugar = 'nodo_inicial'; else lugar = 'nodo_final'; end
    gl = input(['�El gl restringido corresponde a ', num2str(i),'es?\nEl desplazamiento en x: 1\nEl desplazamiento en y: 2\nLa rotaci�n: 3\n']); % Es el caso general, no es "necesario" hacer casos particulares
    j = (elementos.(['elemento_',num2str(elemento)]).(lugar)-1)*3 + gl;
    fn(j) = 0;
    k_total_pp(j,:) = 0;
    k_total_pp(:,j) = 0;
end
% Formar Kpp
k = 0;
l = 0;
for i=1:nn*3
   for j = 1:nn*3
       if ~k_total_pp(i,j); k_pp(k,l) = ~k_total_pp(i,j); end
   end
end
%% Resolver los Desplazamientos
delta = k_total_pp^-1*fn_pp;  % Vector de desplazamientos
%% Generar archivo con variables generadas
% save metodo_de_rigidez elementos k_total nodos T k_total_pp