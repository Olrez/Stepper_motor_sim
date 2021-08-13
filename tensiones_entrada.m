%Esto es una simulación del controlador, la función genera las señales de tensión 
%de entrada para el motor. Según el modo de operación genera las señales del tipo Full-Step, 
%Half-Step y Microstepping. Se utiliza en modelo.m.

function V=tensiones_entrada(t)
global Vnom f a b modo_paso
%f es la frecuencia del tren de pulsos a generar
V=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Definición de las entradas:%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Va=0; Vb=0;

%%%%Tren de pulsos full-step%%%%%

%Full-Step Doble
%Una revolución se divide en 4*Nr pasos
%Las fases se excitan como (+Va,-Vb),(+Va,+Vb),(-Va,+Vb),(-Va,-Vb) secuencialmente
if(modo_paso==1)
    Va=Vnom*square(2*pi*f*t);
    Vb=Vnom*square(2*pi*f*t-pi/2-pi*b);
end

%%%%Tren de pulsos half-step%%%%%
%Una revolución se divide en 8*Nr pasos
%Las fases se excitan como (+Va,-Vb),(+Va,0),(+Va,+Vb),(0,+Vb),
%(-Va,+Vb),(-Va,0),(-Va,-Vb),(0,-Vb) secuencialmente
if(modo_paso==2)
    Va=Vnom/2*square(2*pi*f*t)+Vnom/2*square(2*pi*f*t+2*pi/8);
    Vb=Vnom/2*square(2*pi*f*t-pi/2-pi*b)+Vnom/2*square(2*pi*f*t+2*pi/8-pi/2-pi*b);
end

%%%%Entrada microstepping%%%%
%Una revolución se divide en 4*Nr*a pasos (teóricamente)
%Siendo 'a' el número de micropasos que depende de la modulación PWM
%Para controladores comerciales el máximo valor de a es 256 micropasos

%micro step (Quasi Sine Wave)
if(modo_paso==3)
    for i=1:1:a
        Va=Va+(Vnom/a)*square(2*pi*f*t+(2*pi)*(i-1)/(2*a));
        Vb=Vb+(Vnom/a)*square(2*pi*f*t+(2*pi)*(i-1)/(2*a)-pi/2-pi*b);
    end
end

%Completamente sinusoildal (División infinita) - Teórico
if(modo_paso==4)
    Va=Vnom*cos(2*pi*f*t);
    Vb=Vnom*sin(2*pi*f*t-pi*b);
end

V=[Va, Vb];