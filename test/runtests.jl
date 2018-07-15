import ParticleSwarmOptimizer
const pso = ParticleSwarmOptimizer
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@testset "ParticleSwarmOptimizer" begin
    include("TestFunctions.jl")
    include("helper.jl")
    include("neighbourhood.jl")
    include("pso.jl")
end
