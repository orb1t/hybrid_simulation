% Margaret Mary Fernandez's Master's Thesis
% Non Ideal (Peng-Robinson), High Pressure Equilibrium Model
% draining Tank Calculation - ODE45 Solution File

function N2O_Tank = Model2_drainA_FD(N2O_Tank, Pe, dt)
all_rocket_prop = Rocket_Prop();
all_nox_prop = nox_prop();

T = N2O_Tank(2);
P = N2O_Tank(7)*100000;  %N2O_Tank pressure is in Bar, conver to Pa
n2l = N2O_Tank(12);
n2v = N2O_Tank(13);

n_tot = n2l + n2v;
% Given constants
nHe = 0;
Vol = all_rocket_prop(1);   % total volume of tank [m^3]
m_T = all_rocket_prop(4);   % tank mass [kg]
Inj_Loss_Coeff = all_rocket_prop(11);  % discharge coefficient: Test 1

MW2 = all_nox_prop(6);      % molecular weight of N2O [kg/kmol]
R = all_nox_prop(7);        % universal gas constant [J/(kmol*K)];

y2 = n2v/(n2v+nHe);         % mol fraction of N2O

Tc1 = 5.19;
Tc2 = 309.6;
Pc1 = 0.227e6;
Pc2 = 7.24e6;
w1 = -0.365;
w2 = 0.165;

% Peng-Robinson parameters
kappa1 = 0.37464 + 1.54226*w1 - 0.26992*w1^2;   % Sandler p.250
kappa2 = 0.37464 + 1.54226*w2 - 0.26992*w2^2;   
alpo1 = (1 + kappa1*(1-sqrt(T/Tc1)))^2;
alpo2 = (1 + kappa2*(1-sqrt(T/Tc2)))^2;

a1 = 0.45724*R^2*Tc1^2*alpo1/Pc1;               % Sandler p.250
a2 = 0.45724*R^2*Tc2^2*alpo2/Pc2;
b1 = 0.0778*R*Tc1/Pc1;
b2 = 0.0778*R*Tc2/Pc2;
daldT = -0.45724*R^2*Tc1^2*kappa1*sqrt(alpo1/(T*Tc1))/Pc1;
da2dT = -0.45724*R^2*Tc2^2*kappa2*sqrt(alpo2/(T*Tc2))/Pc2;
d2aldT2 = (-0.45724*R^2*Tc1^2/Pc1)*kappa1*0.5*(alpo1/(T*Tc1))^-0.5* ...
    ((-kappa1*sqrt(alpo1*T*Tc1)-alpo1*Tc1)/(T*Tc1)^2);
d2a2dT2 = (-0.45724*R^2*Tc2^2/Pc2)*kappa2*0.5*(alpo2/(T*Tc2))^-0.5* ...
    ((-kappa2*sqrt(alpo2*T*Tc2)-alpo2*Tc2)/(T*Tc2)^2);

A2 = P*a2/(R*T)^2;                        % Sandler p.251
B2 = P*b2/(R*T);

Z2l = PR_Find_Z(A2, B2, 'l');

% Gas - Mixture
% Z_m^3 + d2*Z_m^2 + d1*Z_m + d0 = 0
        
k12 = 0;                                    % binary interaction parameter (He/N2O mix)
a21 = sqrt(a1*a2)*(1-k12);                  % Sandler p.423
am = (1-y2)^2*a1 + 2*y2*(1-y2)*a21 + y2^2*a2;
bm = (1-y2)*b1 + y2*b2;

da21dT = (1-k12)/2*((a1*a2)^-0.5*(daldT*a2+a1*da2dT));
d2a21dT2 = (1-k12)/2*(-0.5*(a1*a2)^(-3/2)*(daldT*a2+a1*da2dT)^2+(a1*a2)^-0.5* ...
    (d2aldT2*a2+2*daldT*da2dT+a1*d2a2dT2));
damdT = (1-y2)^2*daldT + 2*y2*(1-y2)*da21dT + y2^2*da2dT;
d2amdT2 = (1-y2)^2*d2aldT2 + 2*y2*(1-y2)*d2a21dT2 + y2^2*d2a2dT2;
d2amdTdy2 = -2*(1-y2)*daldT + 2*(1-2*y2)*da21dT + 2*y2*da2dT;
damdy2 = -2*(1-y2)*a1 + 2*a21*(1-2*y2) + 2*y2*a2;    % @T
dbmdy2 = -b1 + b2;

Am = P*am/(R*T)^2;                      % Sandler p.425
Bm = P*bm/(R*T);
A2l = P*a21/(R*T)^2;
        
Zm = PR_Find_Z(Am, Bm, 'm');

H2lex = R*T*(Z2l-1) + (T*da2dT-a2)/(2*sqrt(2)*b2)*log((Z2l+(1+sqrt(2))*B2)/(Z2l+(1-sqrt(2))*B2));
Hgex = R*T*(Zm-1) + (T*damdT-am)/(2*sqrt(2)*bm)*log((Zm+(1+sqrt(2))*Bm)/(Zm+(1-sqrt(2))*Bm));
phi2l = exp((Z2l-1) - log(Z2l - B2) - (A2/(2*sqrt(2)*B2))*log((Z2l+(1+sqrt(2))*B2)/(Z2l+(1-sqrt(2))*B2)));
phi2v = exp((B2/Bm)*(Zm-1) - log(Zm - Bm) - (Am/(2*sqrt(2)*Bm))*((2*((1-y2)*A2l+y2*A2)/Am) - B2/Bm)*...
        log((Zm+(1+sqrt(2))*Bm)/(Zm+(1-sqrt(2))*Bm)));
        
%%Analytical Derivatives %%
dA2dT = (P/R^2)*(da2dT/T^2-2*a2/T^3);   % @P
dA2dP = a2/(R*T)^2;                     % @T
dB2dT = -P*b2/(R*T^2);                  % @P
dB2dP = b2/(R*T);                       % @T
dA2ldT = (P/R^2)*(da21dT/T^2-2*a21/T^3);
dA2ldP = a21/(R*T)^2;
dAmdT = (P/R^2)*(damdT/T^2-2*am/T^3);   % @P,y2
dAmdP = am/(R*T)^2;                     % @T,y2
dAmdy2 = P/(R*T)^2*damdy2;              % @T,P
dBmdT = -P*bm/(R*T^2);                  % @P,y2
dBmdP = bm/(R*T);                       % @T,y2
dBmdy2 = P/(R*T)*dbmdy2;                % @T,P

% helpful substitutions
Z2lpB2 = Z2l + (1+sqrt(2))*B2;
Z2lmB2 = Z2l + (1-sqrt(2))*B2;
ZmpBm = Zm + (1+sqrt(2))*Bm;
ZmmBm = Zm + (1-sqrt(2))*Bm;
dABT = (dA2dT*B2 - A2*dB2dT)/B2^2;
dABP = (dA2dP*B2 - A2*dB2dP)/B2^2;
dB2mT = (dB2dT*Bm - B2*dBmdT)/Bm^2;
dB2mP = (dB2dP*Bm - B2*dBmdP)/Bm^2;
dABmT = (dAmdT*Bm - Am*dBmdT)/Bm^2;
dABmP = (dAmdP*Bm - Am*dBmdP)/Bm^2;
dABmy2 = (dAmdy2*Bm - Am*dBmdy2)/Bm^2;
AB21m = 2*((1-y2)*A2l+y2*A2)/Am - B2/Bm;
dAB21mT = (2/Am^2)*(((1-y2)*dA2ldT+y2*dA2dT)*Am-((1-y2)*A2l+y2*A2)*dAmdT) - dB2mT;
dAB21mP = (2/Am^2)*(((1-y2)*dA2ldP+y2*dA2dP)*Am-((1-y2)*A2l+y2*A2)*dAmdP) - dB2mP;
dAB21my2 = (2/Am^2)*((-A2l+A2)*Am-((1-y2)*A2l+y2*A2)*dAmdy2) + B2*dBmdy2/Bm^2;
exp2l = exp(Z2l-1-log(Z2l-B2)-(A2/(2*sqrt(2)*B2))*log(Z2lpB2/Z2lmB2));
exp2v = exp((B2/Bm)*(Zm-1)-log(Zm-Bm)-(Am/(2*sqrt(2)*Bm))*AB21m*log(ZmpBm/ZmmBm));

% analytical derivatives [T,P,Z(T,P,y2(n2v)),y2(n2v)]
AdZ2ldT = ((-Z2l^2+6*B2*Z2l+2*Z2l+A2-2*B2-3*B2^2)*dB2dT + ...
    (-Z2l+B2)*dA2dT)/(3*Z2l^2-(1-B2)*2*Z2l+A2-3*B2^2-2*B2);
AdZ2ldP = ((-Z2l^2+6*B2*Z2l+2*Z2l+A2-2*B2-3*B2^2)*dB2dP + ...
    (-Z2l+B2)*dA2dP)/(3*Z2l^2-(1-B2)*2*Z2l+A2-3*B2^2-2*B2);
AdZmdT = ((-Zm^2+6*Bm*Zm+2*Zm+Am-2*Bm-3*Bm^2)*dBmdT + ...
    (-Zm+Bm)*dAmdT)/(3*Zm^2-(1-Bm)*2*Zm+Am-3*Bm^2-2*Bm);
AdZmdP = ((-Zm^2+6*Bm*Zm+2*Zm+Am-2*Bm-3*Bm^2)*dBmdP + ...
    (-Zm+Bm)*dAmdP)/(3*Zm^2-(1-Bm)*2*Zm+Am-3*Bm^2-2*Bm);
AdZmdy2 = ((-Zm^2+6*Bm*Zm+2*Zm+Am-2*Bm-3*Bm^2)*dBmdy2 + ...
    (-Zm+Bm)*dAmdy2)/(3*Zm^2-(1-Bm)*2*Zm+Am-3*Bm^2-2*Bm);
AdH21dT = R*(Z2l-1) + (1/(2*sqrt(2)*b2))*(T*d2a2dT2)*log(Z2lpB2/Z2lmB2) + ...
    ((T*da2dT-a2)/b2)*(Z2l/(Z2lpB2*Z2lmB2))*dB2dT;
AdH21dP = (T*da2dT-a2)/b2*(Z2l/(Z2lpB2*Z2lmB2))*dB2dP;
AdH21dZ2l = R*T + (T*da2dT-a2)/b2*(-B2/(Z2lpB2*Z2lmB2));
AdHgdT = R*(Zm-1) + (1/(2*sqrt(2)*bm))*(T*d2amdT2)*log(ZmpBm/ZmmBm) + ...
    ((T*damdT-am)/bm)*(Zm/(ZmpBm*ZmmBm))*dBmdT;
AdHgdP = (T*damdT-am)/bm*(Zm/(ZmpBm*ZmmBm))*dBmdP;
AdHgdy2 = (((T*d2amdTdy2-damdy2)*2*sqrt(2)*bm-(T*damdT-am)*2*sqrt(2)*dbmdy2)/(8*bm^2))*log(ZmpBm/ZmmBm) + ...
    ((T*damdT-am)/(2*sqrt(2)*bm))*(ZmmBm/ZmpBm)*(2*sqrt(2)*Zm/ZmmBm^2)*dBmdy2;
AdHgdZm = R*T + (T*damdT-am)/(2*sqrt(2)*bm)*(ZmmBm/ZmpBm)*(-2*sqrt(2)*Bm/ZmmBm^2);
Adphi21dT = exp2l*(dB2dT/(Z2l-B2)-dABT/(2*sqrt(2))*log(Z2lpB2/Z2lmB2)-...
    (A2/B2)*(Z2l/(Z2lpB2*Z2lmB2))*dB2dT);
Adphi21dP = exp2l*(dB2dP/(Z2l-B2)-dABP/(2*sqrt(2))*log(Z2lpB2/Z2lmB2)-...
    (A2/B2)*(Z2l/(Z2lpB2*Z2lmB2))*dB2dP);
Adphi21dZ2l = exp2l*(1-1/(Z2l-B2)+A2/(Z2lpB2*Z2lmB2));
Adphi2vdT = exp2v*((Zm-1)*dB2mT+dBmdT/(Zm-Bm)-(1/(2*sqrt(2)))*(dABmT*AB21m+(Am/Bm)*dAB21mT)*...
    log(ZmpBm/ZmmBm)-(Am/Bm)*(AB21m/ZmpBm)*(Zm*dBmdT/ZmmBm));
Adphi2vdP = exp2v*((Zm-1)*dB2mP+dBmdP/(Zm-Bm)-(1/(2*sqrt(2)))*(dABmP*AB21m+(Am/Bm)*dAB21mP)*...
    log(ZmpBm/ZmmBm)-(Am/Bm)*(AB21m/ZmpBm)*(Zm*dBmdP/ZmmBm));
Adphi2vdy2 = exp2v*((Zm-1)*-B2/Bm^2*dBmdy2+dBmdy2/(Zm-Bm)-(1/(2*sqrt(2)))*...
    (dABmy2*AB21m+(Am/Bm)*dAB21my2)*log(ZmpBm/ZmmBm)-(Am/Bm)*(AB21m/ZmpBm)*(Zm*dBmdy2/ZmmBm));
Adphi2vdZm = exp2v*(B2/Bm-1/(Zm-Bm)+Am*AB21m/(ZmpBm*ZmmBm));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ng = n2v + nHe;

Cp_2v = nox_CpG(T,'J_kmolK');    
    % specific heat of N2O gas at constant volume [J/kmol*K)];
Cp_T = (4.8 + 0.00322*T)*155.239;                  
    % specific heat of tank, Aluminum 6061-T6 [J/(kg*K)]
Cp_2l = nox_CpL(T,'J_kmolK');
    % specific heat of N2O liquid at constant volume, approx. same as at
    % constant pressure [J/(kmol*K)]
deltaH_2v = nox_enthV(T,'J_kmol');       % heat of vapourization of N2) [J/kmol];

D = n2v*Cp_2v + ng*AdHgdZm*AdZmdT + ng*AdHgdT - ng*R*(Zm + T*AdZmdT);
N = m_T*Cp_T + n2l*(Cp_2l + AdH21dZ2l*AdZ2ldT + AdH21dT - R*(Z2l+T*AdZ2ldT));
E = ng*(AdHgdZm*AdZmdP + AdHgdP - R*T*AdZmdP);
Q = n2l*(AdH21dZ2l*AdZ2ldP + AdH21dP - R*T*AdZ2ldP);
M = Hgex - Zm*R*T + (1-y2)*(AdHgdZm*AdZmdy2 + AdHgdy2 - R*T*AdZmdy2);
K = (Inj_Loss_Coeff*sqrt(2/MW2))*sqrt(P*(P-Pe)/(Z2l*R*T));
beta = ng*AdZmdT + n2l*AdZ2ldT + (Zm*ng+Z2l*n2l)/T;
gamma = ng*AdZmdP + n2l*AdZ2ldP - Vol/(R*T);
delta = Zm + (1-y2)*AdZmdy2;
theta = ng*(Adphi21dZ2l*AdZ2ldT + Adphi21dT) - n2v*(Adphi2vdZm*AdZmdT + Adphi2vdT);
lamda = ng*(Adphi21dZ2l*AdZ2ldP + Adphi21dP) - n2v*(Adphi2vdZm*AdZmdP + Adphi2vdP);
psi = phi2l - phi2v - y2*(1-y2)*(Adphi2vdZm*AdZmdy2 + Adphi2vdy2);

X = D+N;
W = E+Q;
Y = -Z2l*R*T;
Z = deltaH_2v + M - H2lex;

% Solve using Cramer's Rule
Col1 = [X 0 beta theta]';
Col2 = [W 0 gamma lamda]';
Col3 = [Y 1 Z2l 0]';
Col4 = [Z 1 delta psi]';
Col5 = [0 -K 0 0]';

AA = [Col1 Col2 Col3 Col4];
BB = [Col5 Col2 Col3 Col4];
CC = [Col1 Col5 Col3 Col4];
DD = [Col1 Col2 Col5 Col4];
EE = [Col1 Col2 Col3 Col5];

if det(AA) ~= 0 %Hacky statement added by Steve to fix odd errors
    dTdt   = det(BB)/det(AA);
    dPdt   = det(CC)/det(AA);
    dn2ldt = det(DD)/det(AA);
    dn2vdt = det(EE)/det(AA);
elseif det(CC) == 0
    dTdt   = det(BB);
    dPdt   = det(CC);
    dn2ldt = det(DD);
    dn2vdt = det(EE);
else
    disp('Error finding dPdt')
end

dx(1,1) = dTdt;
dx(2,1) = dPdt;
dx(3,1) = dn2ldt;
dx(4,1) = dn2vdt;
    n2l = n2l + dn2ldt*dt;
    n2v = n2v + dn2vdt*dt;
    n_loss = n_tot - n2l - n2v;
    m_loss = n_loss*MW2/dt;
   %update tank contents for next iteration
    N2O_Tank(2) = T + dTdt*dt;   %tank_fluid_temperature_K;
%    N2O_Tank(3) = tank_liquid_mass;
%    N2O_Tank(4) = tank_vapour_mass;
%    N2O_Tank(5) = mdot_tank_outflow_returned;
%    N2O_Tank(6) = tank_vapourized_mass_old2;
    N2O_Tank(7) = (P + dPdt*dt)/100000;
%    N2O_Tank(8) = tank_propellant_contents_mass;
%    N2O_Tank(9) = tank_liquid_density;
%    N2O_Tank(10) = tank_vapour_density;
    N2O_Tank(11) = m_loss;
    N2O_Tank(12) = n2l;
    N2O_Tank(13) = n2v;