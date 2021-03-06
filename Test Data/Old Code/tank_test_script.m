%This script is used to verify the Nitrous Oxide Tank simulation Only.
%The complete Engine simulation is handled by "engine_script.m"

%Nitrous Oxide Parameters
pCrit = 72.51;     % critical pressure, Bar Abs 
rhoCrit = 452.0;   % critical density, kg/m3 
tCrit = 309.57;    % critical temperature, Kelvin (36.42 Centigrade) */
ZCrit = 0.28;      % critical compressibility factor 
gamma = 1.3;       % average over subcritical range 
nox_prop = [pCrit, rhoCrit, tCrit, ZCrit, gamma];

%Set Up time Vector
t_end = 8.3; %determine length of simulation
dt = 0.001; % time step
t = 0:dt:t_end;  %make the actual vector
max_t = length(t);  %sets a useful flag and variable
%this initializes the vctor that contains the resulting N2O Tank parameters
%with respect to time
N2O_Tank_Time = zeros(21,max_t); 
%Set the initial values in the N2O the instant before engine firing
N2O_Tank_Time(:,1) = Ox_Tank_Init(nox_prop);
%this initializes the vctor that contains the resulting Combustion Chamber
%parameters with respect to time
Comb_Chamber_Time = zeros(6,max_t);
%Set the initial values of the Combustion Chamber
Comb_Chamber_Time(:,1) = Comb_Chamber_Init;
%this initializes the vctor that contains the controller valve
%parameters with respect to time
N2O_Valve_Time = zeros(4, max_t);
%Set the initial values of the controller valve
N2O_Valve_Time(:,1) = [0,0,0,0];

%loop that actually runs the simulation
for t_k=2:max_t
%The purposeof this if/else loop appears to have been lost, as no evidence
%of 'Validation_Data2(something, something) can be found.  Likely, it was
%supposed to be a way to update these variables overtime, and just use them
%for 20 iterations.

%     if mod(t_k,20) == 0
%         index = t_k/20
%         Comb_Chamber_Time(2, t_k) = Validation_Data2(index,3);
%         Comb_Chamber_Time(1, t_k) = Validation_Data2(index,2);
%         Comb_Chamber_Time(3, t_k) = Validation_Data2(index,6);
%     else
        
        %Makes the Combustion Pressure the same as the previous iteration
        Comb_Chamber_Time(2, t_k) = Comb_Chamber_Time(2, t_k-1);
        %Makes the Fuel Grain Radius the same as the previous iteration
        Comb_Chamber_Time(1, t_k) = Comb_Chamber_Time(1, t_k-1);
        %Makes the Mass of Fuel lost the same as the previous iteration
        Comb_Chamber_Time(3, t_k) = Comb_Chamber_Time(3, t_k-1);
%    end    
        
    N2O_Tank_Time(:,t_k) = ...
        Ox_Tank_Update(N2O_Tank_Time(:, t_k-1), ...
                            Comb_Chamber_Time(:, t_k-1), ...
                            N2O_Valve_Time(:, t_k-1), ...
                            nox_prop, dt);
end    

figure(1);clf;hold on;
subplot(2,1,1)  
%plot(t,mdot,'r')
plot(t,N2O_Tank_Time(7,:),'r', ...
    t,Comb_Chamber_Time(1,:),'b'); %t,Comb_Chamber_Time(2,:),'k', ...
subplot(2,1,2)  
plot(t,N2O_Tank_Time(2,:),'r', ...
    t,Comb_Chamber_Time(3,:),'b');%,t,N2O_Tank_Time(10,:),'r')
%subplot(3,1,3); hold on;  
%plot(t,50*sw,'g')
%plot(t,m,'k')