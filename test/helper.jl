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

    @testset "swap! function" begin
        vec1 = collect(1:10)
        pso.swap!(vec1, 3, 7)
        @test vec1 == [1, 2, 7, 4, 5, 6, 3, 8, 9, 10]
        vec2 = [1]
        pso.swap!(vec2, 1, 1)
        @test vec2 == [1]
        vec3 = []
        pso.swap!(vec3, 1, 1)
        @test vec3 == []
    end
end
