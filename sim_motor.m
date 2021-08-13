%Este código simula un motor de pasos bifásico tipo híbrido.
%Para ello define los parámetros del motor, y utiliza el solver ode23 para
%resolver la ecuación diferencial. Posteriormente grafica los estados del motor: la posición, la
%velocidad y las corrientes de fase. También calcula y grafica del par desarrollado.
clc
%clear;
close all;
global Km Kd R L Nr B J Vnom f a b tau_ref tf modo_paso tipo_carga %declaración parámetros

disp('Simulación Motor de Pasos Híbrido:'); 
%disp(' ');
Km=0.1645; %Constante de par [Nm/A] 0,3084
Kd=0; %Par de detención [Nm]
R=0.295; %Rsistencia por fase [ohms]
L=0.0028; %Inductancia por fase [H]
Nr=50; %Número de dientes del rotor (Nr=2N). N es el número de pares de polos del rotor
B=0.0086; %Coeficiente de roce [Nms/rad] 0,0169
J=0.00048; %Inecia del rotor [kgm^2]
Vnom=0.5; %Tensión nominal [V]
f=1; %Frecuencia de pulsos [Hz] (existe una limitante de simulación)
a=3; %Constante de división de ángulo de paso para microstepping
b=0; %Constante de inversión de giro b=0 horario, b=1 antihorario
tau_ref=0.01; %Par de carga de referencia [Nm], ver par_carga.m  (también limitado)
to=0; tf=2/f+0.03; %Tiempos inicial y final de simulación [s]
muestras=1e4; %cantidad de muestras a tomar

%%%Selección del modo de operación:%%%
modo_paso=1;
%Paso completo doble => 1
%Medio paso => 2
%Micropasos => 3 (con a=2 Paso completo simple)
%Micropasos inf => 4

disp('Modo de operación:');
if(modo_paso==1)
 disp('FULL STEP'); a=1;
elseif(modo_paso==2)
 disp('HALF STEP'); a=2;
elseif(modo_paso==3)
 disp('MICRO STEP'); %'a' se define arriba
else
 disp('MICRO STEP (Alta resolución)'); a=inf;
end
%Fórmulas de comprobación
 resolucion=4*Nr*a; %[pasos/rev]
 angulo_paso=360/resolucion; %[°/paso]
 fp=4*f*a; %[pasos/s ó Hz]
 if(modo_paso==1 || modo_paso==2 || modo_paso==3 )
  thetasim=fp*tf/resolucion; %[rev]
  omega=60*fp/resolucion; %[rpm]
 else
  thetasim=f*tf/Nr; %[rev]
  omega=60*f/Nr; %[rpm]
 end

%%%Selección del tipo de carga:%%%
tipo_carga=0;
%Motor vacío => 0
%Plena carga => 1
%Plena carga + cambio => 2
%Vacío + cambio => 3
%Carga sinusoidal => 4
%Carga creciente => 5

%Resolución
disp(['Cambio de posición: ' num2str(angulo_paso) ' º/paso = ' num2str(1/resolucion) ' rev/paso'] );
disp(['Frecuencia de paso: ' num2str(fp) ' pasos/s'] );
disp(['Resolución: ' num2str(resolucion) ' pasos/rev'] );

%Definicion de estados: x=[theta, omega, ia, ib]
%Estado inicial:
xo=[0, 0, 0, 0];

%Parámetros de la simulación:
dt=tf/muestras; %Intervalo del tiempo discreto (dt=0.001 <=> fs=1000 Hz frecuencia de muestreo)
tspan=0:dt:tf; % Lapso temporal (time span) del solver

%Cálculo del estado:
%La rutina de integración 'ode23' llama a la función 'modelo'
%para resolver las dinámicas del sistema
[t,x]=ode23('modelo', tspan, xo);

%El par desarrollado:
tau_des=Km*(-x(:,3).*sin((Nr)*x(:,1)) + x(:,4).*cos((Nr)*x(:,1))) - Kd*sin((4*Nr)*x(:,1));

%El par de carga:
tau_L=[];
for contador=1:length(t)
    temporal=par_carga(t(contador));
    tau_L=[tau_L; temporal];
end

%%{ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gráfica de las variables de estado %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%posición en revoluciones
figure(1);
plot(t,x(:,1)/(2*pi),'k');
xlabel('Tiempo [s]');
ylabel('Posición [rev]');
axis([0 2/f+0.03 -0.005 0.04]);
%title('Respuesta del motor de pasos');
%{
%Posición exportada desde simulink
hold on
plot(theta1.time,theta1.signals.values,'k:');
hold on
plot(theta2.time,theta2.signals.values,'k--');
legend('Script','Modelo Simulink','Bloques Simulink');
%save('theta1.mat')
%save('theta2.mat')
%}

%%{
%velocidad en rpm
media=mean(x(:,2));
figure(2);
plot(t,x(:,2)*(60/(2*pi)),'k',t,media*(60/(2*pi)),'b');
xlabel('Tiempo [s]');
ylabel('Velocidad [rpm]');
axis([0 2/f+0.03 -15 25]);
legend('Velocidad del rotor','Velocidad media',0);

%ambas corrientes
figure(3);
plot(t,x(:,3),'k',t,x(:,4),'k--');
xlabel('Tiempo [s]');
ylabel('Corriente de fase [A]');
legend('Corriente ia','Corriente ib',0);
grid off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gráfica de la estimación del par desarrollado%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4);
plot(t,tau_des,'k');
hold on;
plot(t,tau_L,'k--');
grid off;
%title('Par desarrollado contra tiempo');
legend('Par desarrollado','Par carga',0);
xlabel('Tiempo [s]');
ylabel('Par [Nm]');
hold off;
%}

disp('Análisis de posición:');
disp(['Posición máxima esperada: ' num2str(thetasim) ' rev']);
disp(['Posición máxima: ' num2str(max(abs(x(:,1)*(1/(2*pi))))) ' rev']);

disp('Análisis de corrientes:');
disp(['Corriente ia rms : ' num2str(rms(x(:,3))) ' A']);
disp(['Corriente ib rms : ' num2str(rms(x(:,4))) ' A']);

disp('Análisis de velocidad:');
disp(['Velocidad esperada dada la frecuencia: ' num2str(omega) ' rpm']);
disp(['Velocidad media : ' num2str(mean(x(:,2))*(60/(2*pi))) ' rpm']);
disp(['Velocidad mínima: ' num2str(min(x(:,2)*(60/(2*pi)))) ' rpm']);
disp(['Velocidad máxima: ' num2str(max(x(:,2)*(60/(2*pi)))) ' rpm']);

disp('Análisis del par desarrollado:');
disp(['Par de carga medio: ' num2str(mean(tau_L)) ' Nm']);
disp(['Par motor medio : ' num2str(mean(tau_des)) ' Nm']);
disp(['Par motor mínimo: ' num2str(min(tau_des)) ' Nm']);
disp(['Par motor máximo: ' num2str(max(tau_des)) ' Nm']);

disp('Fin de simulación del motor de pasos.');