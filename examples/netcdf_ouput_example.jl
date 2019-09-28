using Oceananigans, Random, Printf

####
#### Model set-up
####

# Two cases from Van Roekel et al (JAMES, 2018)
parameters = Dict(:free_convection => Dict(:Fb=>3.39e-8, :Fu=>0.0,     :f=>1e-4, :N²=>1.96e-5),
                  :wind_stress     => Dict(:Fb=>0.0,     :Fu=>9.66e-5, :f=>0.0,  :N²=>9.81e-5))

# Simulation parameters
case = :free_convection
 N = 32                   # Resolution
 Δ = 0.5                  # Grid spacing
tf = hour/2               # Final simulation time

N², Fb, Fu, f = (parameters[case][p] for p in (:N², :Fb, :Fu, :f))
βT, g = 2e-4, 9.81
Fθ, dTdz = Fb / (g*βT), N² / (g*βT)

# Create boundary conditions. Note that temperature = buoyancy because βT=g=1.
ubcs = HorizontallyPeriodicBCs(top=BoundaryCondition(Flux, Fu))
Tbcs = HorizontallyPeriodicBCs(top=BoundaryCondition(Flux, Fθ), bottom=BoundaryCondition(Gradient, dTdz))

# Instantiate the model
model = Model(
           architecture = CPU(), # GPU() # this example will run on the GPU if cuda is available.
                   grid = RegularCartesianGrid(N = (N, N, N), L = (N*Δ, N*Δ, N*Δ)),
               coriolis = FPlane(f=f),
               buoyancy = SeawaterBuoyancy(equation_of_state=LinearEquationOfState(α=βT)),
                closure = AnisotropicMinimumDissipation(), # closure = ConstantSmagorinsky(),
    boundary_conditions = BoundaryConditions(u=ubcs, T=Tbcs)
)

# Set initial condition. Initial velocity and salinity fluctuations needed for AMD.
Ξ(z) = randn() * z / model.grid.Lz * (1 + z / model.grid.Lz) # noise
T0(x, y, z) = 20 + dTdz * z + dTdz * model.grid.Lz * 1e-6 * Ξ(z)
ϵ₀(x, y, z) = 1e-4 * Ξ(z)

set!(model, u=ϵ₀, w=ϵ₀, T=T0, S=ϵ₀)

####
#### Set up output
####

WriteGeometry(model)
ncow = NCOutputWriter(model, Dict("v"=>model.velocities.v,
                                  "u"=>model.velocities.u,
                                  "w"=>model.velocities.w,
                                  "T"=>model.tracers.T,
                                  "S"=>model.tracers.S),
                      interval=hour/10, filename="dump.nc",
                      xC=3:7, xF=5:8, yC=20:30, yF=10:30, zC=5:15, zF=3:21)
push!(model.output_writers, ncow)

####
#### Run the simulation
####

function terse_message(model, walltime, Δt)
    wmax = maximum(abs, model.velocities.w.data.parent)
    cfl = Δt / Oceananigans.cell_advection_timescale(model)
    return @sprintf("i: %d, t: %.4f hours, Δt: %.1f s, wmax: %.6f ms⁻¹, cfl: %.3f, wall time: %s\n",
                    model.clock.iteration, model.clock.time/3600, Δt, wmax, cfl, prettytime(walltime))
end

# A wizard for managing the simulation time-step.
wizard = TimeStepWizard(cfl=0.2, Δt=1.0, max_change=1.1, max_Δt=90.0)

# Run the model
while model.clock.time < tf
    update_Δt!(wizard, model)
    walltime = @elapsed time_step!(model, 10, wizard.Δt)
    @printf "%s" terse_message(model, walltime, wizard.Δt)
end
OWClose(ncow)