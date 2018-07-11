@testset "helper" begin
    @testset "project function" begin
        @test pso.project(5.0,4.0,6.0,3.0,8.0) == 5.5
        @test pso.project(2.0,0.0,1.0,0.0,1.0) == 2
        @test pso.project(0.3,1.0,0.0,0.0,1.0) == 0.7
    end

    @testset "circle_position function" begin
        @test pso.circle_position(10) ≈ [-1, 0]
        @test pso.circle_position(10, center=[1, 0]) ≈ [0, 0] atol=1E-15
        @test pso.circle_position(10, radius=2, center=[1, 0]) ≈ [-1, 0]
    end
end
