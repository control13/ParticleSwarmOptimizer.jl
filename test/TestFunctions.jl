const tfn = pso.TestFunctions

@testset "TestFunctions" begin

    @testset "sphere function" begin
        @test tfn.sphere([0]) == 0
        @test tfn.sphere([0.0]) == 0
        @test tfn.sphere(zeros(Vector{Float64}(10))) == 0
        @test tfn.sphere([3.0, 4.0]) == 25
    end
    
    @testset "euclidean_distance function" begin
        @test tfn.euclidean_distance([0]) == 0
        @test tfn.euclidean_distance([0.0]) == 0
        @test tfn.euclidean_distance(zeros(Vector{Float64}(10))) == 0
        @test tfn.euclidean_distance([3.0, 4.0]) == 5
    end

    @testset "rastrigin function" begin
        @test tfn.rastrigin([0]) == 0
        @test tfn.rastrigin([0.0]) == 0
        @test tfn.rastrigin(zeros(Vector{Float64}(10))) == 0
        @test tfn.rastrigin([0.0, 0.0], A=-2.3) == 0.0
    end

    @testset "ackley's function" begin
        @test tfn.ackley([0,0]) == 0
        @test tfn.ackley([0.0, 0.0]) == 0
    end

    @testset "rosenbrock's function" begin
        @test tfn.rosenbrock([1.0]) == 0
        @test tfn.rosenbrock([1, 1]) == 0
        @test tfn.rosenbrock(ones(Vector{Float64}(10))) == 0.0
    end

    @testset "eggholder function" begin
        @test tfn.eggholder(512, 404.2319) ≈ -959.6407 atol=0.0001
        @test tfn.eggholder([512, 404.2319]) ≈ -959.6407 atol=0.0001
    end

    @testset "beale function" begin
        @test tfn.beale(3, 0.5) == 0
        @test tfn.beale([3, 0.5]) == 0
    end

    @testset "square_movingpeak function" begin
        @test tfn.square_movingpeak([0, 0]) == 0
        @test tfn.square_movingpeak([3, 4]) == 25
        @test tfn.square_movingpeak([1, 1], optimum=[1, 1]) == 0
        @test tfn.square_movingpeak([2, 2], optimum=[1, 1]) ≈ 2
    end

    @testset "ellipse function" begin
        @test tfn.ellipse(-0.5, -1.5) == 0
        @test tfn.ellipse([-0.5, -1.5]) == 0
    end

    @testset "stybliski function" begin
        for i in 1:5
            @test tfn.stybliski(fill(-2.903534, i)) ≈ -39.16616*i atol=0.0001
        end
    end

    @testset "mccormick function" begin
        @test tfn.mccormick(0, 0) == 1
        @test tfn.mccormick([0, 0]) == 1
        @test tfn.mccormick(-0.54719, -1.54719) ≈ -1.9133 atol=0.0001
    end

    @testset "himmelblau function" begin
        @test tfn.himmelblau(-0.270845, -0.923039) ≈ 181.617 atol=0.001
        @test tfn.himmelblau(3, 2) ≈ 0
        @test tfn.himmelblau([3, 2]) ≈ 0
        @test tfn.himmelblau(-2.805118,  3.131312) ≈ 0 atol=0.0001
        @test tfn.himmelblau(-3.77931 , -3.283186) ≈ 0 atol=0.0001
        @test tfn.himmelblau( 3.584428, -1.848126) ≈ 0 atol=0.0001
    end

    @testset "griewank function" begin
        @test tfn.griewank([0, 0]) == 0
    end

    @testset "schafferf6 function" begin
        @test tfn.schafferf6(0, 0) == 0
        @test tfn.schafferf6([0, 0]) == 0
    end

end
