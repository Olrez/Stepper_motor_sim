%Esta función genera el modelo en variables de estado de la máquina híbrida (modelo matemático dinámico).
%Llama a la función tensiones_entrada.m para introducirla al modelo.

function xdot=modelo(t,x)
global Km Kd R L Nr B J %declaración

%Cálculo de las tensiones de entrada:
tensiones=tensiones_entrada(t);
Va=tensiones(1);
Vb=tensiones(2);

%Establecimiento xdot como un vector columna:
xdot=zeros(4,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CÁLCULO DE LA DERIVADA DEL ESTADO%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Definicion del vector de estado: 
%x=[theta; omega; ia; ib]
%x=[ x(1); x(2); x(3); x(4)]

xdot(1)=x(2);
xdot(2)=(-Km*x(3)*sin(Nr*x(1))+Km*x(4)*cos(Nr*x(1))-B*x(2)-(par_carga(t))-Kd*sin(4*Nr*x(1)))/J;
xdot(3)=(Va-R*x(3)+Km*x(2)*sin((Nr)*x(1)))/L;
xdot(4)=(Vb-R*x(4)-Km*x(2)*cos((Nr)*x(1)))/L;