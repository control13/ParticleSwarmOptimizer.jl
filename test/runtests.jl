import ParticleSwarmOptimizer
const pso = ParticleSwarmOptimizer
using Test

@testset "ParticleSwarmOptimizer" begin
    include("TestFunctions.jl")
    include("helper.jl")
    include("neighbourhood.jl")
    include("pso.jl")
end
