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
struct PSO
    objective::Objective
    w::Number
    c1::Number
    c2::Number

    position_matrix::AbstractMatrix{<:Number}
    velocity_matrix::AbstractMatrix{<:Number}
    position::AbstractVector{<:AbstractVector{<:Number}}
    velocity::AbstractVector{<:AbstractVector{<:Number}}
    position_dimension::AbstractVector{<:AbstractVector{<:Number}}
    velocity_dimension::AbstractVector{<:AbstractVector{<:Number}}
    results::AbstractVector{<:Number}

    pos_best_mat::AbstractMatrix{<:Number}
    pos_best::AbstractVector{<:AbstractVector{<:Number}}
    results_best::AbstractVector{<:Number}

    random_mat::AbstractArray{<:Number, 3}
    rand1::AbstractVector{<:AbstractVector{<:Number}}
    rand2::AbstractVector{<:AbstractVector{<:Number}}

    update_velocity!::Function
    update_position!::Function
    get_localbest::Function

    neighbours::Neighbourhood
    better::BitVector

    compare::Function
end
function PSO(objective::Objective, neighbours::Neighbourhood;
             additional_arguments::Dict{Symbol, <:Any}=Dict{Symbol, Any}(), compare::Function=<,
             w::Number=1.0/(2.0*log(2.0)), c1::Number=0.5 + log(2), c2::Number=c1)

    return_type = eltype(objective.search_space[1])

    number_of_particles = length(neighbours)
    number_of_dimensions = objective.number_of_dimensions
    # Initialization - SPSO 2011 default
    position_matrix = rand(return_type, number_of_dimensions, number_of_particles)
    velocity_matrix = rand(return_type, number_of_dimensions, number_of_particles)
    position = [view(position_matrix, :, i) for i in 1:number_of_particles]
    velocity = [view(velocity_matrix, :, i) for i in 1:number_of_particles]
    position_dimension = [view(position_matrix, i, :) for i in 1:number_of_dimensions]
    velocity_dimension = [view(velocity_matrix, i, :) for i in 1:number_of_dimensions]

    for d in 1:length(position_dimension)
        position_dimension[d] .= project.(position_dimension[d], zero(return_type), oneunit(return_type), objective.search_space[d]...)
        velocity_dimension[d] .= project.(velocity_dimension[d], zero(return_type), oneunit(return_type), 
                                          objective.search_space[d][LOWER_BOUND_IDX].-position_dimension[d],
                                          objective.search_space[d][UPPER_BOUND_IDX].-position_dimension[d])
    end

    results = objective.fun.(position; additional_arguments...)

    pos_best_mat = copy(position_matrix)
    pos_best = [view(pos_best_mat, :, i) for i in 1:length(position)]
    results_best = copy(results)

    rearrange!(neighbours, results_best, compare)

    random_mat = zeros(typeof(w), length(position_dimension), length(position), 2)
    rand1 = [view(random_mat, :, i, 1) for i in 1:length(position)]
    rand2 = [view(random_mat, :, i, 2) for i in 1:length(position)]

    better = BitArray(length(position))

    PSO(objective, w, c1, c2, position_matrix, velocity_matrix, position, velocity, position_dimension,
        velocity_dimension, results, pos_best_mat, pos_best, results_best, random_mat, rand1, rand2, update_velocity!,
        update_position!, get_localbest, neighbours, better, compare)
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
    velocity .= w.*velocity .+ c1.*rand_a.*(personal_best .- position) .+ c2.*rand_b.*(local_best .- position)
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
end

"""
    get_localbest(results_best::AbstractVector{<:Number}, neighbours::AbstractVector{<:Integer}, compare::Function)

Returns the neighbour with the best evaluation of an particle.
"""
@inline function get_localbest(results_best::AbstractVector{<:Number}, neighbours::AbstractVector{<:Integer},
                               compare::Function)
    min_idx = 1
    min_val = results_best[neighbours[min_idx]]
    for neig_idx in 2:endof(neighbours)
        if compare(results_best[neighbours[neig_idx]], min_val)
            min_idx = neig_idx
            min_val = results_best[neighbours[neig_idx]]
        end
    end
    neighbours[min_idx]
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
    for iter in 1:number_of_iterations
        l_best = map(x -> pso.get_localbest(pso.results_best, x, pso.compare), pso.neighbours) #, neighbours.=neighbours
        rand!(pso.random_mat)

        for particle_idx in 1:pso.neighbours.particle_number
            update_velocity!(pso.position[particle_idx], pso.velocity[particle_idx], pso.pos_best[particle_idx],
                             pso.pos_best[l_best[particle_idx]], pso.rand1[particle_idx], pso.rand2[particle_idx],
                             pso.w, pso.c1, pso.c2)
            update_position!(pso.position[particle_idx], pso.velocity[particle_idx], pso.pos_best[particle_idx],
                             pso.pos_best[l_best[particle_idx]])
        end
        # confinements
        for d in 1:pso.objective.number_of_dimensions
            lower = pso.position_dimension[d].<pso.objective.search_space[d][LOWER_BOUND_IDX]
            greater = pso.position_dimension[d].>pso.objective.search_space[d][UPPER_BOUND_IDX]
            pso.velocity_dimension[d][lower .| greater] .*= -0.5
            pso.position_dimension[d][lower] = pso.objective.search_space[d][LOWER_BOUND_IDX]
            pso.position_dimension[d][greater] = pso.objective.search_space[d][UPPER_BOUND_IDX]
        end

        # multiplies every element, which is outside of the search space with 0.5, uses true == 1 and false == 0 and (1*3 - 1)/2 == 1 and (0*3 - 1)/2 == -0.5
        # velocity_matrix .*= (((position_matrix.>search_space[1]) .& (position_matrix.<search_space[2])) .*3.0 .- 1.0) ./2.0

        # evaluation
        pso.results .= pso.objective.fun.(pso.position; additional_arguments...)
        pso.better .= pso.compare.(pso.results, pso.results_best)
        pso.pos_best_mat[:,pso.better] = pso.position_matrix[:,pso.better]

        pso.results_best[pso.better] = pso.results[pso.better]
        rearrange!(pso.neighbours, pso.results_best, pso.compare)
    end
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
    (pso.pos_best_mat[:, all_best], pso.results_best[all_best])
end
