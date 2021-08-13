%Esta función define el par de carga en el tiempo, 
%para usarla con modelo.m y sim_motor.m

function tauL=par_carga(t)
global tau_ref tipo_carga f tf %declaración

%Motor vacío
if(tipo_carga==0)
    tauL=0;
end

%Carga plena
if(tipo_carga==1)
    tauL=tau_ref;
end

%Carga plena + cambio brusco (*2)
if(tipo_carga==2)
    tauL=tau_ref;
    if(0.4*tf<t && t<0.6*tf)
        tauL=1.5*tau_ref;
    end
end

%Vacío + carga brusca
if(tipo_carga==3)
    tauL=0;
    if(0.4*tf<t && t<tf)
        tauL=tau_ref;
    end
end

%Par sinusoidal con frecuencia de un cuarto de la velocidad del motor
if(tipo_carga==4)
    tauL=tau_ref*0.1+tau_ref*0.9*sin(2*pi*f*t/4);
end

%Par de carga creciente
if(tipo_carga==5)
    tauL=6*tau_ref*t/(2/f);
end

