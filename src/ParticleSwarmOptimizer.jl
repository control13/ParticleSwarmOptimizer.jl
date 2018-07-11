__precompile__(true)
module ParticleSwarmOptimizer

include("TestFunctions.jl")
include("helper.jl")
include("neighbourhood.jl")
include("pso.jl")

export TestFunctions

end # module
