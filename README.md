# ParticleSwarmOptimizer (PSO)

[![Build Status](https://travis-ci.org/control13/ParticleSwarmOptimizer.jl.svg?branch=master)](https://travis-ci.org/control13/ParticleSwarmOptimizer.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/w4cfv06l3dxwsr9o/branch/master?svg=true)](https://ci.appveyor.com/project/control13/particleswarmoptimizer-jl/branch/master)

[![Coverage Status](https://coveralls.io/repos/github/control13/ParticleSwarmOptimizer.jl/badge.svg?branch=master)](https://coveralls.io/github/control13/ParticleSwarmOptimizer.jl?branch=master)
[![codecov.io](http://codecov.io/github/control13/ParticleSwarmOptimizer.jl/coverage.svg?branch=master)](http://codecov.io/github/control13/ParticleSwarmOptimizer.jl?branch=master)

Implementation of the meta heuristic Particle Swarm Optimization in pure Julia.
The aim of this package is a customizable/extensible code for exploring and devoloping Particle Swarm Optimization in teaching and science.
In the notebooks folder is an example for Plotting the current state of a 2d PSO instance and if you want to write your own neighbourhood for a pso, please read the documentation. Because of the pure Julia design, this package integrates nicely with other packages, like for example [Unitful.jl](https://github.com/ajkeller34/Unitful.jl). See also the documentation for examples.
The package [Optim.jl](https://github.com/JuliaNLSolvers/Optim.jl) offers also an implementation of a PSO variant [1] next to many other optimizers, but it seems to generalize more for the purpose of different otimization techniques. This package instead, is specific for PSO algorithms and designed for easily accessing all member variables for more freedom in developing and (visually) debugging new neigbourhoods or methods for adjusting the parameters.

## Current status

This package is in an early development version. If you want to experiment with it, install it with

    Pkg.clone("git@github.com:control13/ParticleSwarmOptimizer.jl.git")
    Pkg.build("ParticleSwarmOptimizer")

## Implemented versions of PSO

- CLERC, Maurice. Standard particle swarm optimisation. 2012.
- JANSON, Stefan; MIDDENDORF, Martin. A hierarchical particle swarm optimizer and its adaptive variant. IEEE Transactions on Systems, Man, and Cybernetics, Part B (Cybernetics), 2005, 35. Jg., Nr. 6, S. 1272-1282. (in progress)

## Planned features (in descend order)

- PSO for dynamic problems: JANSON, Stefan; MIDDENDORF, Martin. A hierarchical particle swarm optimizer for noisy and dynamic environments. Genetic Programming and Evolvable Machines, 2006, 7. Jg., Nr. 4, S. 329-354. (in progress)
- Running the PSO on the GPU with [CUDAnative.jl](https://github.com/JuliaGPU/CUDAnative.jl)

## Documentation

<!-- [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://control13.github.io/ParticleSwarmOptimizer.jl/stable) -->
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://control13.github.io/ParticleSwarmOptimizer.jl/latest)

[1] Zhan, Zhang, and Chung. Adaptive particle swarm optimization, IEEE Transactions on Systems, Man, and Cybernetics, Part B: CyberneticsVolume 39, Issue 6, 2009, Pages 1362-1381 (2009)
