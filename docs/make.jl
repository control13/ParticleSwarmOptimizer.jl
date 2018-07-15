using Documenter, ParticleSwarmOptimizer

makedocs(
    format = :html,
    assets = ["assets/pso_animation_preview.gif"],
    sitename = "ParticleSwarmOptimizer.jl",
    authors = "Tobias Jagla",
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/control13/ParticleSwarmOptimizer.jl.git",
    julia = "0.6"
)
