using BenchmarkTools
import ParticleSwarmOptimizer
pso = ParticleSwarmOptimizer

pso.get_localbest([0.5, 0.5, 0.5, 0.4, 0.5], [2, 4, 5], <)

@benchmark pso.get_localbest([0.5, 0.5, 0.5, 0.4, 0.5], [2, 4, 5], <)
@benchmark pso.get_localbest([0.5, 0.5, 0.5, 0.4, 0.5], [2], <)
