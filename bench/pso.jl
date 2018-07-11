using BenchmarkTools
import Optimizers
op = Optimizers

op.local_best([0.5, 0.5, 0.5, 0.4, 0.5], [2, 4, 5], <)

@benchmark op.local_best([0.5, 0.5, 0.5, 0.4, 0.5], [2, 4, 5], <)
@benchmark op.local_best([0.5, 0.5, 0.5, 0.4, 0.5], [2], <)
