using Documenter, ParticleSwarmOptimizer

makedocs(
    format = :html,
    assets = ["assets/pso_animation_preview.gif"],
    sitename = "ParticleSwarmOptimizer Documentation",
    authors = "Tobias Jagla",
    pages = [
        "Home" => "index.md",
        "Settings" => Any[
            "Parameter" => "parameter.md",
            "Update function" => "updatefunction.md",
            "Neighbourhood" => "neighbourhood.md"
        ],
        "Extension" => Any[
            "Update function" => "own_updatefunction.md",
            "Neighbourhood" => "own_neighbourhood.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/control13/ParticleSwarmOptimizer.jl.git",
    target = "build",
    julia = "0.6",
    deps   = nothing,
    make   = nothing
)
