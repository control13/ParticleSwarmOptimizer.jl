@testset "pso" begin
    @testset "Objective" begin
        @test pso.Objective(x -> x, 3, (-5.0, 5.0)).search_space == [(-5.0, 5.0), (-5.0, 5.0), (-5.0, 5.0)]
    end
    @testset "update_position" begin
        position = [1.0, 2.0]
        pso.update_position!(position, [0.75, -0.25], [0.0, 0.0], [0.0, 0.0])
        @test position == [1.75, 1.75]
    end
    # @testset "update_velocity" begin
    #     velocity = [1.0, 2.0]
    #     Optimizers.update_velocity!([1.0, 2.0], velocity, )
    #     @test velocity == [1.75, 1.75]
    # end
    @testset "get_localbest" begin
        @test pso.get_localbest([0.2, 0.5, 0.6, 0.1], [1, 3], <) == 1
        @test pso.get_localbest([0.2, 0.5, 0.6, 0.1], [1, 3], >) == 3
        @test pso.get_localbest([0.5, 0.5, 0.5, 0.4, 0.5], [2, 4, 5], <) == 4
    end
end
