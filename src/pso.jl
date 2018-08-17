export Objective, PSO, update_velocity!, update_position!, optimize!

"""
    Objective

Stores the objective function and the related `search_space` the dimensionality.
"""
struct Objective
    fun::Function
    number_of_dimensions::Integer
    search_space::AbstractVector{<:Tuple{Number, Number}} # TODO: other  object for search_space, maybe allow ellipses and more
end
function Objective(fun::Function, number_of_dimensions::Integer, search_space::Tuple{<:Number, <:Number})
    search_space = [search_space for i in 1:number_of_dimensions]
    Objective(fun, number_of_dimensions, search_space)
end

const LOWER_BOUND_IDX = 1
const UPPER_BOUND_IDX = 2

"""
    PSO

Packs all data for the pso.
"""
mutable struct PSO
    objective::Objective
    w::Number
    c1::Number
    c2::Number

    iterations::Int

    position_matrix::AbstractMatrix{<:Number}
    velocity_matrix::AbstractMatrix{<:Number}
    position::AbstractVector{<:AbstractVector{<:Number}}
    velocity::AbstractVector{<:AbstractVector{<:Number}}
    position_dimension::AbstractVector{<:AbstractVector{<:Number}}
    velocity_dimension::AbstractVector{<:AbstractVector{<:Number}}

    pos_best_mat::AbstractMatrix{<:Number}
    pos_best::AbstractVector{<:AbstractVector{<:Number}}
    results_best::AbstractVector{<:Number}

    random_mat::AbstractArray{<:Number, 3}
    rand1::AbstractVector{<:AbstractVector{<:Number}}
    rand2::AbstractVector{<:AbstractVector{<:Number}}

    update_velocity!::Function
    update_position!::Function
    confinement!::Function
    get_localbest::Function

    neighbours::Neighbourhood

    compare::Function
end
function PSO(objective::Objective, neighbours::Neighbourhood;
             additional_arguments::Dict{Symbol, <:Any}=Dict{Symbol, Any}(), compare::Function=<,
             w::Number=1.0/(2.0*log(2.0)), c1::Number=0.5 + log(2), c2::Number=c1, space_type::Type=eltype(objective.search_space[1]))

    number_of_particles = length(neighbours)
    number_of_dimensions = objective.number_of_dimensions
    # Initialization - SPSO 2011 default
    position_matrix = rand(space_type, number_of_dimensions, number_of_particles)
    velocity_matrix = rand(space_type, number_of_dimensions, number_of_particles)
    position = [view(position_matrix, :, i) for i in 1:number_of_particles]
    velocity = [view(velocity_matrix, :, i) for i in 1:number_of_particles]
    position_dimension = [view(position_matrix, i, :) for i in 1:number_of_dimensions]
    velocity_dimension = [view(velocity_matrix, i, :) for i in 1:number_of_dimensions]

    for d in 1:length(position_dimension)
        position_dimension[d] .= project.(position_dimension[d], zero(space_type), oneunit(space_type), objective.search_space[d]...)
        velocity_dimension[d] .= project.(velocity_dimension[d], zero(space_type), oneunit(space_type), 
                                          objective.search_space[d][LOWER_BOUND_IDX].-position_dimension[d],
                                          objective.search_space[d][UPPER_BOUND_IDX].-position_dimension[d])
    end

    results_best = objective.fun.(position; additional_arguments...)

    pos_best_mat = copy(position_matrix)
    pos_best = [view(pos_best_mat, :, i) for i in 1:length(position)]

    rearrange!(neighbours, results_best, compare)

    random_mat = zeros(typeof(w), length(position_dimension), length(position), 2)
    rand1 = [view(random_mat, :, i, 1) for i in 1:length(position)]
    rand2 = [view(random_mat, :, i, 2) for i in 1:length(position)]

    return PSO(objective, w, c1, c2, 0, position_matrix, velocity_matrix, position, velocity, position_dimension,
        velocity_dimension, pos_best_mat, pos_best, results_best, random_mat, rand1, rand2, update_velocity!,
        update_position!, confinement!, get_localbest, neighbours, compare)
end

# update functions
"""
    update_velocity!(position::AbstractVector{T}, velocity::AbstractVector{T}, personal_best::AbstractVector{T},
                     local_best::AbstractVector{T}, rand_a::AbstractVector{T}, rand_b::AbstractVector{T}, w::Number,
                     c1::Number, c2::Number) where T<:Number

Default equation for calculating the velocity for the next step.
"""
@inline function update_velocity!(position::AbstractVector{T}, velocity::AbstractVector{T},
                                  personal_best::AbstractVector{T}, local_best::AbstractVector{T},
                                  rand_a::AbstractVector{<:Number}, rand_b::AbstractVector{<:Number}, w::Number, c1::Number,
                                  c2::Number) where T<:Number
    @inbounds for pidx in eachindex(velocity)
        velocity[pidx] = w*velocity[pidx] + c1*rand_a[pidx]*(personal_best[pidx] - position[pidx]) + c2*rand_b[pidx]*(local_best[pidx] - position[pidx])
    end
    return
end

# @inline function update_velocity_geometric!(position::AbstractVector{T}, velocity::AbstractVector{T}, personal_best::AbstractVector{T}, local_best::AbstractVector{T}, rand_a::AbstractVector{T}, rand_b::AbstractVector{T}, w::Number, c1::Number, c2::Number) where T<:Number
#     velocity .= w.*velocity .+ c1.*rand_a.*(personal_best .- position) .+ c2.*rand_b.*(local_best .- position)
# end

"""
    function update_position!(position::AbstractVector{T}, velocity::AbstractVector{T},
                              personal_best::AbstractVector{T}, local_best::AbstractVector{T}) where T<:Number

Default update of the next position.
"""
@inline function update_position!(position::AbstractVector{T}, velocity::AbstractVector{T},
                                  personal_best::AbstractVector{T}, local_best::AbstractVector{T}) where T<:Number
    position .+= velocity
    return 
end

"""
    confinement!(results_best::AbstractVector{<:Number}, neighbours::AbstractVector{<:Integer}, compare::Function)

Checks, if a particle is over the edge of search space. If yes for a dimension, it will be set on the edge and the velocity for this dimension will be inverted and decreased by the half.
"""
@inline function confinement!(position::AbstractVector{T}, velocity::AbstractVector{T}, limits::AbstractVector{<:Tuple{T,T}}) where T<:Number
    @inbounds for d in eachindex(position)
        if position[d] < limits[d][LOWER_BOUND_IDX]
            velocity[d] *= -0.5
            position[d] = limits[d][LOWER_BOUND_IDX]
        end
        if position[d] > limits[d][UPPER_BOUND_IDX]
            velocity[d] *= -0.5
            position[d] = limits[d][UPPER_BOUND_IDX]
        end
    end
    return
end

"""
    get_localbest(results_best::AbstractVector{<:Number}, neighbours::AbstractVector{<:Integer}, compare::Function)

Returns the neighbour with the best evaluation of an particle.
"""
@inline function get_localbest(results_best::AbstractVector{<:Number}, neighbours::AbstractVector{<:Integer},
                               compare::Function)
    min_idx = 1
    @inbounds min_val = results_best[neighbours[min_idx]]
    @inbounds for neig_idx in 2:endof(neighbours)
        if compare(results_best[neighbours[neig_idx]], min_val)
            min_idx = neig_idx
            min_val = results_best[neighbours[neig_idx]]
        end
    end
    return neighbours[min_idx]
end

function evaluate!(position::AbstractVector{<:Number}, results_best::AbstractVector{T}, pos_best::AbstractVector{T}, idx::Int, cmp::Function, obj::Function) where T<:Number
    result = obj(position)
    if cmp(result, results_best[idx])
        pos_best .= position
        results_best[idx] = result
    end
end

"""
    optimize!(pso::PSO, number_of_iterations::Int; additional_arguments::Dict{Symbol, <:Any}=Dict{Symbol, Any}())

Iterates an PSO object for `number_of_iterations`. `additional_arguments` would be applied to the objective function
as named arguments.

# Examples

```jldoctest
julia> objective = Objective(TestFunctions.sphere, 2, (-10.0, 10.0))
julia> neighbours = GlobalNeighbourhood(20)
julia> pso = PSO(objective, neighbours)
julia> optimize!(pso, 10_000)

```
"""
function optimize!(pso::PSO, number_of_iterations::Int; additional_arguments::Dict{Symbol, <:Any}=Dict{Symbol, Any}())
    num_particles::Int = pso.neighbours.particle_number

    for iter in 1:number_of_iterations
        rand!(pso.random_mat)

        @inbounds for particle_idx in 1:num_particles
            l_best = pso.get_localbest(pso.results_best,  pso.neighbours[particle_idx], pso.compare)
            pso.update_velocity!(pso.position[particle_idx], pso.velocity[particle_idx], pso.pos_best[particle_idx],
                             pso.pos_best[l_best], pso.rand1[particle_idx], pso.rand2[particle_idx],
                             pso.w, pso.c1, pso.c2)
            pso.update_position!(pso.position[particle_idx], pso.velocity[particle_idx], pso.pos_best[particle_idx],
                             pso.pos_best[l_best])
            pso.confinement!(pso.position[particle_idx], pso.velocity[particle_idx], pso.objective.search_space)
            evaluate!(pso.position[particle_idx], pso.results_best, pso.pos_best[particle_idx], particle_idx, pso.compare, pso.objective.fun)
        end

        rearrange!(pso.neighbours, pso.results_best, pso.compare)
        pso.iterations += 1
    end
    return
end

"""
    getoptimum(pso::PSO)

Returns a tuple with the n-dimensional position of the current found optimum and the function value on this position.

# Examples

```jldoctest
julia> getoptimum()

```
"""
function getoptimum(pso::PSO)
    all_best = get_localbest(pso.results_best, 1:pso.neighbours.particle_number, pso.compare)
    return (pso.pos_best_mat[:, all_best], pso.results_best[all_best])
end
