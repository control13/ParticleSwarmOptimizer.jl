export project, circle_position

"""
    project(x::Number, x1::Number, y1::Number, x2::Number, y2::Number)

Calculate for a `x` from the range `[x1,y1]` its value in the range `[x2,y2]`.

This includes `x`s outside of the input range and reverse.
See the Examples section below.

# Examples

```jldoctest
julia> project(5.0,4.0,6.0,3.0,8.0)
5.5
julia> project(2.0,0.0,1.0,0.0,1.0)
2.0
julia> project(0.3,1.0,0.0,0.0,1.0)
0.7
```
"""
@inline function project(x::Number, x1::Number, y1::Number, x2::Number, y2::Number)
    return (x-x1)/(y1-x1)*(y2-x2)+x2
end

"""
    circle_position(t::Int; radius::Real=1.0, center::Vector{Real}=[0.0, 0.0], number_of_points::Int=20)

Devides a circle in `t` equidistant sections and gives for every t between 0 and `number_of_points`-1 the beginning postion of the secion on the circle beginning on the right most point on the circle. With increasing `t` the position moves counter clockwise.

# Examples

```jldoctest
julia> circle_position(10)
[-1.0, 0.0]
```
"""
function circle_position(t::Int; radius::Number=1.0, center::AbstractVector{<:Number}=[0.0, 0.0], number_of_points::Integer=20)
    x = t/number_of_points * 2π
    radius.*[cos(x), sin(x)] .+ center
end
