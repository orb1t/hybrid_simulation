classdef HybridEngine
    %HYBRIDENGINE This class is meant to encapsulate all the aspects of a
    %designed hybrid engine, and methods to calculate derived properties.
    %   Detailed explanation goes here
    
    properties
        injector
        nozzle
        oxidizer_tank
        combustion_chamber
        regression_rate_a=0.0127; %Proportionality constant from HDP to
        %produce regression rate in mm/s
        regression_rate_n=0.65;   %Exponent from HDP, for G_o in kg/(m^2*s)
    end
    
    properties (Dependent)
        regression_rate_t
        chamber_pressure_t
    end
    
    methods
        %% Setters
        function obj=set.nozzle(obj,noz)
            assert(strcmp(class(noz),'Nozzle')==1, ...
                'The nozzle must be input as a Nozzle object, see Nozzle.m')
            obj.nozzle=noz;
        end
        function obj=set.oxidizer_tank(obj,ox_tank)
            assert(strcmp(class(ox_tank),'OxidizerTank')==1, ...
                'The oxidizer tank must be input as an OxidizerTank object, see OxidizerTank.m')
            obj.oxidizer_tank=ox_tank;
        end
        function obj=set.combustion_chamber(obj,comb_cham)
            assert(strcmp(class(comb_cham),'CombustionChamber')==1,...
                'The combustion chamber must be input as a CombustionChamber object, see CombustionChamber.m')
            obj.combustion_chamber=comb_cham;
        end
        function dynamic_properties=simulate_burn(obj)
            dynamic_properties=obj;
        end
        function obj=set.regression_rate_a(obj,r_r_a)
            assert(strcmp(class(r_r_a),'double')==1,...
                'The "a" coefficient for the regression rate calculation must be a real number.')
            obj.regression_rate_a=r_r_a;
        end
        function obj=set.regression_rate_n(obj,r_r_n)
            assert(strcmp(class(r_r_n),'double')==1,...
                'The "n" coefficient for the regression rate calculation must be a real number.')
            obj.regression_rate_n=r_r_n;
        end
        %% Simulate Performance
        function time_series=solve_dynamics(Engine,burn_time)
            %We use ode45 to determine the evolution of the following parameters:
            %    oxidizer tank pressure
            %    oxidizer tank liquid density
            %    oxidizer tank liquid mass
            %    oxidizer tank temperature
            %    chamber pressure 
            %    fuel port radius
            
            %% First, gather initial parameters
            initial_parameters=[Engine.oxidizer_tank.fluid_pressure_t;
                Engine.oxidizer_tank.liquid_density_t;
                Engine.oxidizer_tank.liquid_mass_t;
                Engine.oxidizer_tank.fluid_temperature_t;
                Engine.combustion_chamber.combustion_pressure_t;
                Engine.combustion_chamber.port_radius_t];
            [sim_time,sim_vars]=ode45(@(var_vec) dynamical_derivatives(Engine,var_vec),[0 burn_time],initial_parameters);
            time_series=horzcat(sim_time, sim_vars);
        end
    end
end
function dynamical_derivatives(Engine, var_vec)
%This function takes an engine object and a vector of variables and returns
%the dynamical derivatives of those variables. This is meant for use in
%ODE45 above.

%% Give the variables in the vector names corresponding to their values
tank_p = var_vec(1); tank_rho = var_vec(2); tank_m = var_vec(3);
tank_t = var_vec(4); cham_p = var_vec(5); port_r = var_vec(6);

d_tank_p_dt   = 
d_tank_rho_dt = 
d_tank_m_dt   = 
d_tank_t_dt   = 
d_cham_p_dt   = 

delta_p=tank_p-cham_p;
port_area=Engine.combustion_chamber.n_ports*pi*port_r^2;

d_port_r_dt   = Engine.regression_rate_a*(ox_flux)^(Engine.regression_rate_n); %mm

end



























