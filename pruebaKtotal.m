prueba = zeros(6) + 1;
k_total = zeros(12);

for i=1:ne
    for j=1:3
        for k=1:3
            ji = j + (elementos.(['elemento_',num2str(i)]).nodo_inicial-1)*3;
            ki = k + (elementos.(['elemento_',num2str(i)]).nodo_inicial-1)*3;
            jf = j + (elementos.(['elemento_',num2str(i)]).nodo_final-1)*3;
            kf = k + (elementos.(['elemento_',num2str(i)]).nodo_final-1)*3;
            k_total(ji,ki) = k_total(ji,ki) + prueba(j,k); % Primer Cuadrante            
            k_total(jf,kf) = k_total(jf,kf) + prueba(j+3,k+3); % Cuarto Cuadrante
            k_total(ji,kf) = k_total(ji,kf) + prueba(j,k+3); 
            k_total(jf,ki) = k_total(jf,ki) + prueba(j+3,k);
        end
    end
end