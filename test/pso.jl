@testset "pso" begin
    obj = pso.Objective(pso.TestFunctions.sphere, 3, (-5.0, 5.0))
    @testset "Objective" begin
        @test obj.search_space == [(-5.0, 5.0), (-5.0, 5.0), (-5.0, 5.0)]
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
    @testset "confinements" begin
        position = [6.0, 2.0]
        velocity = [1.0, -2.0]
        pso.confinement!(position, velocity, [(-5.0, 5.0), (-5.0, 5.0)])
        @test position == [5.0, 2.0]
        @test velocity == [-0.5, -2.0]
    end
    @testset "evaluate" begin
        position = [1.0, 1.0]
        pos_best = [2.0, -2.0]
        res_best = [4.0, 3.0, pso.TestFunctions.sphere(pos_best), 5.0]
        pso.evaluate!(position, res_best, pos_best, 3, <, pso.TestFunctions.sphere)
        @test position == [1.0, 1.0]
        @test pos_best == [1.0, 1.0]
        @test res_best == [4.0, 3.0, pso.TestFunctions.sphere(position), 5.0]
    end
    @testset "get_localbest" begin
        @test pso.get_localbest([0.2, 0.5, 0.6, 0.1], [1, 3], <) == 1
        @test pso.get_localbest([0.2, 0.5, 0.6, 0.1], [1, 3], >) == 3
        @test pso.get_localbest([0.5, 0.5, 0.5, 0.4, 0.5], [2, 4, 5], <) == 4
    end
    neig = pso.GlobalNeighbourhood(20)
    optimizer = pso.PSO(obj, neig)
    @testset "PSO object" begin
        @test size(optimizer.position_matrix) == (3, 20)
        @test size(optimizer.velocity_matrix) == (3, 20)
        for el in optimizer.position_matrix
            @test -5 ≤ el ≤ 5
        end
        for el in optimizer.position_matrix.+optimizer.velocity_matrix
            @test -5 ≤ el ≤ 5
        end
    end
    @testset "optimize! function" begin
        pso.optimize!(optimizer, 500)
        result = pso.getoptimum(optimizer)
        @test all(result[1] .< [1e-10, 1e-10, 1e-10])
        @test result[2] < 1e-10
    end
end
