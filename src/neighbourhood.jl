export Neighbourhood, LocalNeighbourhood, GlobalNeighbourhood, HierachicalNeighbourhood

abstract type Neighbourhood <: AbstractVector{AbstractVector{<:Integer}} end
Base.IndexStyle(::Type{<:Neighbourhood}) = IndexLinear()
Base.size(n::Neighbourhood) = (n.particle_number,)
Base.length(n::Neighbourhood) = n.particle_number
Base.getindex(n::Neighbourhood, i::Int) = getneighbour(n, i)
Base.setindex!(n::Neighbourhood, v, i::Int) = error("Not supported!")
rearrange!(n::Neighbourhood, results_best::AbstractVector{<:Number}, compare::Function) = nothing

"""
    LocalNeighbourhood


"""
struct LocalNeighbourhood <: Neighbourhood
    particle_number::Integer
    neighbours::AbstractVector{<:AbstractVector{<:Integer}}
end
function LocalNeighbourhood(particle_number::Integer, width::Integer=1)
    all_neigs = Vector{Vector{Int}}(particle_number)
    for current in 1:particle_number
        neighbours = collect((current-width):(current+width))
        neighbours[neighbours.<1] .+= particle_number
        neighbours[neighbours.>particle_number] .-= particle_number
        all_neigs[current] = neighbours
    end
    LocalNeighbourhood(particle_number, all_neigs)
end
getneighbour(l::LocalNeighbourhood, i::Integer) = l.neighbours[i]

"""
    GlobalNeighbourhood


"""
struct GlobalNeighbourhood <: Neighbourhood
    particle_number::Integer
    neighbours::AbstractVector{<:Integer}
end
function GlobalNeighbourhood(particle_number::Integer)
    GlobalNeighbourhood(particle_number, collect(1:particle_number))
end
getneighbour(g::GlobalNeighbourhood, i::Integer) = g.neighbours

"""
    HierachicalNeighbourhood


"""
struct HierachicalNeighbourhood <: Neighbourhood
    particle_number::Integer
    branching_degree::Integer
    childs::AbstractVector{<:AbstractVector{<:Integer}}
    parent::AbstractVector{<:Integer}
    particle_to_graph::AbstractVector{<:Integer}
    graph_to_particle::AbstractVector{<:Integer}
end
function HierachicalNeighbourhood(particle_number::Integer, branching_degree::Integer)
    # @assert particle_number ≤ max_particle_number "With d=$branching_degree and h=$tree_height you can use $max_particle_number particles at most."
    childs = getchilds(particle_number, branching_degree)
    parent = getparents(childs)
    particle_to_graph = collect(1:particle_number)
    graph_to_particle = collect(1:particle_number)
    HierachicalNeighbourhood(particle_number, branching_degree, childs, parent, particle_to_graph, graph_to_particle)
end
function HierachicalNeighbourhoodByTreeHeight(tree_height::Integer, branching_degree::Integer)
    particle_number = convert(Int, (branching_degree^tree_height - 1)/(branching_degree - 1))
    HierachicalNeighbourhood(particle_number, branching_degree)
end
getneighbour(g::HierachicalNeighbourhood, i::Integer) = [g.graph_to_particle[g.parent[g.particle_to_graph[i]]]]

function getchilds(particle_number::T, branching_degree::T) where T <: Integer
    childs = [T[] for _ in 1:particle_number]
    last_childs = [1]
    cummmulative_width = 1
    current_height = 1
    while true
        width = branching_degree^current_height
        for current_branch in 1:width
            child_index = cummmulative_width + current_branch
            child_index > particle_number && return childs
            push!(childs[last_childs[(current_branch - 1) % length(last_childs) + 1]], child_index)
        end
        last_childs = vcat(childs[last_childs]...)
        cummmulative_width += width
        current_height += 1
    end
    childs
end

function getparents(childs::AbstractVector{<:AbstractVector{<:Integer}})
    parents = ones(eltype(childs[1]), length(childs))
    for parent_index in 2:length(childs)
        isempty(childs[parent_index]) && continue
        parents[childs[parent_index]] = parent_index
    end
    return parents
end

function rearrange!(n::HierachicalNeighbourhood, personal_best::AbstractVector{<:Number}, compare::Function)
    for (parent_graph, childs_graph) in enumerate(n.childs)
        isempty(childs_graph) && continue
        childs_particle = n.graph_to_particle[childs_graph]
        child_min_particle = childs_particle[indmin(personal_best[childs_particle])]
        child_min_graph = n.particle_to_graph[child_min_particle]
        parent_particle = n.graph_to_particle[parent_graph]
        if compare(personal_best[child_min_particle], personal_best[parent_particle])
            n.particle_to_graph[child_min_particle], n.particle_to_graph[parent_particle] = n.particle_to_graph[parent_particle], n.particle_to_graph[child_min_particle]
            n.graph_to_particle[child_min_graph], n.graph_to_particle[parent_graph] = n.graph_to_particle[parent_graph], n.graph_to_particle[child_min_graph]
        end
    end
end
