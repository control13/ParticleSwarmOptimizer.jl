export Neighbourhood, LocalNeighbourhood, GlobalNeighbourhood, HierachicalNeighbourhood

abstract type Neighbourhood{I} <: AbstractVector{AbstractVector{I<:Integer}} end
# Base.eltype(::Type{<:Neighbourhood{I}}) = I
# Base.eltype(n::Neighbourhood{I}) = I
Base.IndexStyle(::Type{<:Neighbourhood}) = IndexLinear()
Base.size(n::Neighbourhood) = (n.particle_number,)
Base.length(n::Neighbourhood) = n.particle_number
Base.getindex(n::Neighbourhood, i::Integer) = getneighbour(n, i)
Base.setindex!(n::Neighbourhood, v, i::Integer) = error("Not supported!")
rearrange!(n::Neighbourhood, results_best::AbstractVector{<:Number}, compare::Function) = nothing

"""
    LocalNeighbourhood

The LocalNeighbourhood organizes the particle in a ring topology. For width=1 for example,
each particle has three neighbours, one to the left, one to the right and itself.
The width says to how many particles on the left and on the right it is connected.
"""
struct LocalNeighbourhood{I} <: Neighbourhood{I}
    particle_number::I
    neighbours::AbstractVector{<:AbstractVector{<:I}}
end
function LocalNeighbourhood(particle_number::I, width::I=one(I)) where I <: Integer
    @assert (particle_number ≥ 2*width + 1) "For $particle_number particles the width can be $(Int(round((particle_number-1)/2))) at most."
    all_neigs = Vector{Vector{I}}(particle_number)
    for current in one(particle_number):particle_number
        neighbours = collect((current-width):(current+width))
        neighbours[neighbours.<one(I)] .+= particle_number
        neighbours[neighbours.>particle_number] .-= particle_number
        all_neigs[current] = neighbours
    end
    LocalNeighbourhood(particle_number, all_neigs)
end
getneighbour(l::LocalNeighbourhood, i::Integer) = l.neighbours[i]

"""
    GlobalNeighbourhood

In the GlobalNeighbourhood all particle are connected to all other particles.
"""
struct GlobalNeighbourhood{I} <: Neighbourhood{I}
    particle_number::I
    neighbours::AbstractVector{<:I}
end
function GlobalNeighbourhood(particle_number::Integer)
    GlobalNeighbourhood(particle_number, collect(one(particle_number):particle_number))
end
getneighbour(g::GlobalNeighbourhood, i::Integer) = g.neighbours

"""
    HierachicalNeighbourhood

Inspired by this paper: https://ieeexplore.ieee.org/abstract/document/1299745/
It arranges all particles in a tree. The parent of a node is the only neighbour. The root has itself as neighbours.
After every iteration, the tree will be updated. Particles can climbe up and down in the tree.

# Initialization
HierachicalNeighbourhood(particle_number::Integer, branching_degree::Integer)
HierachicalNeighbourhoodByTreeHeight(tree_height::Integer, branching_degree::Integer)
        - The particle number results from the full tree.
"""
struct HierachicalNeighbourhood{I} <: Neighbourhood{I}
    single_particle::AbstractVector{<:AbstractVector{<:I}}
    particle_number::I
    branching_degree::I
    childs::AbstractVector{<:AbstractVector{<:I}}
    parent::AbstractVector{<:I}
    particle_to_graph::AbstractVector{<:I}
    graph_to_particle::AbstractVector{<:I}
end
function HierachicalNeighbourhood(particle_number::I, branching_degree::I) where I<:Integer
    # @assert particle_number ≤ max_particle_number "With d=$branching_degree and h=$tree_height you can use $max_particle_number particles at most."
    childs = getchilds(particle_number, branching_degree)
    parent = getparents(childs)
    particle_to_graph = collect(one(I):particle_number)
    graph_to_particle = collect(one(I):particle_number)
    HierachicalNeighbourhood([[i] for i in one(I):particle_number], particle_number, branching_degree, childs, parent, particle_to_graph, graph_to_particle)
end
function HierachicalNeighbourhoodByTreeHeight(tree_height::I, branching_degree::I) where I<:Integer
    particle_number = convert(Int, (branching_degree^tree_height - one(I))/(branching_degree - one(I)))
    HierachicalNeighbourhood(particle_number, branching_degree)
end
getneighbour(g::HierachicalNeighbourhood, i::Integer) = g.single_particle[g.graph_to_particle[g.parent[g.particle_to_graph[i]]]]

"""
    getchilds(particle_number::T, branching_degree::T) where T <: Integer

Get a list of all childs for each particle number.
"""
function getchilds(particle_number::I, branching_degree::I) where I <: Integer
    childs = [I[] for _ in one(I):particle_number]
    last_childs = [one(I)]
    cummmulative_width = one(I)
    current_height = one(I)
    while true
        width = branching_degree^current_height
        for current_branch in one(I):width
            child_index = cummmulative_width + current_branch
            child_index > particle_number && return childs
            push!(childs[last_childs[(current_branch - one(I)) % length(last_childs) + one(I)]], child_index)
        end
        last_childs = vcat(childs[last_childs]...)
        cummmulative_width += width
        current_height += one(I)
    end
end

"""
    getparents(childs::AbstractVector{<:AbstractVector{<:Integer}})

Get a list of parents from a list of cilds.
"""
function getparents(childs::AbstractVector{<:AbstractVector{<:I}}) where I<:Integer
    parents = ones(eltype(childs[one(I)]), length(childs))
    for parent_index in (one(I)+one(I)):length(childs)
        isempty(childs[parent_index]) && continue
        parents[childs[parent_index]] = parent_index
    end
    return parents
end

"""
    function bestchild(graph_to_particle::AbstractVector{I}, childs_graph::AbstractVector{I}, personal_best::AbstractVector{<:Number}, compare::Function) where I<:Integer

Resturns the "best" child of a node in the neighbourhood tree. What the best is, is determined by compare function. If more than one particle have the "best" personal best value, the first in the row is taken.
"""
@inline function bestchild(graph_to_particle::AbstractVector{I}, childs_graph::AbstractVector{I}, personal_best::AbstractVector{<:Number}, compare::Function) where I<:Integer
    @inbounds child_min_particle = graph_to_particle[childs_graph[one(I)]]
    @inbounds minval = personal_best[child_min_particle]
    @inbounds for child in childs_graph
        childs_particle = graph_to_particle[child]
        nextval = personal_best[childs_particle]
        if compare(nextval, minval)
            minval = nextval
            child_min_particle = childs_particle
        end
    end
    return child_min_particle
end

"""
    function swapifnecessary!(n::HierachicalNeighbourhood{I}, personal_best::AbstractVector{<:Number}, child_min_particle::I, parent_particle::I, child_min_graph::I, parent_graph::I, compare::Function) where I<:Integer

Swaps to particles in the neighbourhood tree if the personal_best of the particle in the subtree is "better" than the node. "better" means if the `compare` function results in true.
"""
@inline function swapifnecessary!(n::HierachicalNeighbourhood{I}, personal_best::AbstractVector{<:Number}, child_min_particle::I, parent_particle::I, child_min_graph::I, parent_graph::I, compare::Function) where I<:Integer
    @inbounds if compare(personal_best[child_min_particle], personal_best[parent_particle])
        swap!(n.particle_to_graph, child_min_particle, parent_particle)
        swap!(n.graph_to_particle, child_min_graph, parent_graph)
    end
    return
end

"""
    rearrange!(n::HierachicalNeighbourhood, personal_best::AbstractVector{<:Number}, compare::Function)

If a parent node has a worse (higher or lesser) evaluation than the best child, they will be swapped.
The tree will be checked from the top to the bottom. A particle can at most climbe one level up,
but can travel down from the top to the bottom in one function call.
"""
function rearrange!(n::HierachicalNeighbourhood, personal_best::AbstractVector{<:Number}, compare::Function)
    n_childs::Int = n.particle_number
    @inbounds for parent_graph in 1:n_childs
        childs_graph = n.childs[parent_graph]
        isempty(childs_graph) && continue
        child_min_particle = bestchild(n.graph_to_particle, childs_graph, personal_best, compare)
        child_min_graph = n.particle_to_graph[child_min_particle]
        parent_particle = n.graph_to_particle[parent_graph]
        swapifnecessary!(n, personal_best, child_min_particle, parent_particle, child_min_graph, parent_graph, compare)
    end
    return
end
