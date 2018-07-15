__precompile__(true)

"""
Implementaion of test functions for the real valued optimizers.
From the [wikipedia article](https://en.wikipedia.org/wiki/Test_functions_for_optimization)
for test functions.
"""
module TestFunctions

export sphere, rastrigin, ackley, rosenbrock, eggholder, beale, square_movingpeak, ellipse, stybliski, mccormick,
       himmelblau, griewank, schafferf6

"""
    sphere(x::AbstractVector{<:Number})

Calculate the square root of the squared sums from the vector `x`.

### Minimum

```math
f(0) = 0
```

### Recommanded searchspace

```math
-\infty ≦ x ≦ \infty
```

### Examples

```jldoctest
julia> sphere([3.0, 4.0])
5.0
```
"""
@inline function sphere(x::AbstractVector{<:Number})
    sum(x.^2)
end

"""
    rastrigin(x::AbstractVector{<:Number}; A::Number = 10)

Rastrigin function. See [Wikipedia](https://en.wikipedia.org/wiki/Rastrigin_function).

### Minimum

```math
f(0) = 0
```

### Recommanded searchspace

```math
-5.12 ≦ x ≦ 5.12
```

### Examples

```jldoctest
julia> rastrigin([0,0])
0
```
"""
@inline function rastrigin(x::AbstractVector{<:Number}; A::Number = 10.0)
    A*length(x) + sum(x.^2 - A.*cos.(2π.*x))
end

"""
    ackley(x::Number, y::Number)

Ackley's fuction.

### Minimum

```math
f(0, ..., 0) = 0
```

### Recommanded searchspace

```math
-32 ≦ x ≦ 32
```

### Examples

```jldoctest
julia> ackley(0.0, 0.0)
0.0
```
"""
@inline function ackley(x::AbstractVector{<:Number})
    # -20.0*e^(-0.2*sqrt((x^2 + y^2)/2.0)) - e^((cos(2π*x) + cos(2π*y))/2.0) + e + 20.0
    -20.0*e^(-0.2*sqrt(sum(x.^2)/length(x))) - e^(sum(cos.(2π.*x))/length(x)) + e + 20.0
end
# @inline ackley(x::AbstractVector{<:Number}) = ackley(x[1], x[2])

"""
    rosenbrock(x::AbstractVector{<:Number})

Rosenbrock function. See [Wikipedia](https://en.wikipedia.org/wiki/Rosenbrock_function).

### Minimum

```math
f(1, 1, ..., 1) = 0
```

### Recommanded searchspace

```math
-\infty ≦ x ≦ \infty
```

### Examples

```jldoctest
julia> rosenbrock([1.0,1.0])
0.0
```
"""
function rosenbrock(x::AbstractVector{<:Number})
    s = 0.0
    @inbounds for i in 1:(length(x)-1)
        s += 100*(x[i+1] - x[i]*x[i])^2 + (x[i] - 1)^2
    end
    s
end

"""
    eggholder(x::Number, y::Number)

Eggholder function.

### Minimum

```math
f(512, 404.2319) = -959.6407
```

### Recommanded searchspace

```math
-512 ≦ x,y ≦ 512
```

### Examples

```jldoctest
julia> eggholder(512, 404.2319)
-959.6406627106155
```
"""
@inline function eggholder(x::Number, y::Number)
    y += 47
    -y*sin(sqrt(abs(x/2 + y))) - x*sin(sqrt(abs(x - y)))
end
@inline eggholder(x::AbstractVector{<:Number}) = eggholder(x[1], x[2])

"""
    beale(x::Number, y::Number)

Beale's function.

### Minimum

```math
f(3, 0.5) = 0
```

### Recommanded searchspace

```math
-4.5 ≦ x,y ≦ 4.5
```

### Examples

```jldoctest
julia> beale(3, 0.5)
0
```
"""
@inline function beale(x::Number, y::Number)
    (1.5 - x + x*y)^2 + (2.25 - x + x*y*y)^2 + (2.625 - x + x*y*y*y)^3
end
@inline beale(x::AbstractVector{<:Number}) = beale(x[1], x[2])

"""
    moving_peak(x::AbstractVector{<:Number}; optimum::Vector{<:Number}=[0.0, 0.0])

Square function with adjustable global optimum.

### Minimum

```nath
f(optimum) = 0.02
```

### Recommanded searchspace

```math
-\infty ≦ x ≦ \infty
```

# Examples

```jldoctest
julia> moving_peak([0.0, 0.0], optimum=[1.0, 1.0])
1.4142135623730951
```
"""
@inline function square_movingpeak(x::AbstractVector{<:Number}; optimum::Vector{<:Number}=[0.0, 0.0])
    sphere(x.-optimum)
end

"""
    ellipse(x::AbstractVector{<:Number}; a::Number=-2, b::Number=1)

Ellipse function recommanded by Thomas Rheinhardt in 2015. Default updatefunction for position and velocity in the PSO
may have problems with this function. A 2011 presented way with a gravity center and a more random selection
seems to be more robust.

### Minimum

```math
f(-0.5, -1.5) = 0.0
```

### Recommanded searchspace

```math
-\infty ≦ x ≦ \infty
```

# Examples

```jldoctest
julia> ellipse(-0.5, -1.5)
0.0
```
"""
@inline function ellipse(x::Number, y::Number; a::Number=-2, b::Number=1)
    (x + y - a)*(x + y - a)/100 + (x - y - b)*(x - y - b)*100
end
@inline ellipse(x::AbstractVector{Number}; a::Number=-2, b::Number=1) = ellipse(x[1], x[2], a=a, b=b)

"""
    stybliski(x::AbstractVector{<:Number})

Styblinski function.

### Minimum

```math
f(-2.903534, ..., -2.903534) ≈ -39.16616*length(input)
```

### Recommanded searchspace

```math
-5 ≦ x ≦ 5
```

# Examples

```jldoctest
julia> stybliski([-2.903534, -2.903534])
-78.3323314075428
```
"""
@inline function stybliski(x::AbstractVector{<:Number})
    sum(x.^4 .- 16.*x.^2 .+ 5.* x)/2
end

"""
    mccormick(x::Number, y::Number)

McCormick's function.

### Minimum

```math
f(-0.54719, -1.54719) = -1.9133
```

### Recommanded searchspace

```math
-1.5 ≦ x ≦ 4
-3   ≦ y ≦ 4.5
```

### Examples

```jldoctest
julia> mccormick(0, 0)
1.0
```
"""
@inline function mccormick(x::Number, y::Number)
    sin(x + y) + (x - y)^2 - 1.5x + 2.5y + 1
end
@inline mccormick(x::AbstractVector{<:Number}) = mccormick(x[1], x[2])

"""
    himmelblau(x::Number, y::Number)

Himmelblau function.

### Minimum

```math
f(-0.270845, -0.923039) = 181.617 (local maximum)

f(3.0, 2.0) = 0.0
f(-2.805118,  3.131312) = 0.0
f(-3.77931 , -3.283186) = 0.0
f( 3.584428, -1.848126) = 0.0
```

### Recommanded searchspace

```math
-5 ≦ x ≦ 5
```

### Examples

```jldoctest
julia> himmelblau(3, 2)
0
```
"""
@inline function himmelblau(x::Number, y::Number)
    (x^2 + y - 11)^2 + (x + y^2 - 7)^2
end
@inline himmelblau(x::AbstractVector{<:Number}) = himmelblau(x[1], x[2])

"""
    griewank(x::AbstractVector{<:Number})

Griewank function. See [Wikipedia](https://en.wikipedia.org/wiki/Griewank_function).

### Minimum

```math
f(0, 0, ..., 0) = 0
```

### Recommanded searchspace

```math
-\infty ≦ x ≦ \infty
```

### Examples

```jldoctest
julia> griewank([0.0, 0.0])
0.0
```
"""
function griewank(x::AbstractVector{<:Number})
    1 + sum(x.^2)/4_000 - prod(cos.(x./(1:length(x))))
end

"""
    schafferf6(x::AbstractVector{<:Number}; optimum::Vector{<:Number}=[0.0, 0.0])

Square function with adjustable global optimum.

### Minimum

```nath
f(0, 0, ..., 0) = 0.0
```

### Recommanded searchspace

```math
-100 ≦ x ≦ 100
```

# Examples

```jldoctest
julia> schafferf6([0.0, 0.0])
0.0
```
"""
@inline function schafferf6(x::Number, y::Number)
    0.5 + (sin(sqrt(x^2 + y^2))^2 - 0.5)/((1 + 0.001*(x^2 + y^2))^2)
end
@inline schafferf6(x::AbstractVector{<:Number}) = schafferf6(x[1], x[2])

end
