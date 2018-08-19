@testset "neighbourhood" begin
    @testset "LocalNeighbourhood" begin
        ln = pso.LocalNeighbourhood(5)
        @test ln[2] == [1, 2, 3]
        @test ln[5] == [4, 5, 1]
        @test length(ln) == 5
        @test_throws AssertionError pso.LocalNeighbourhood(5, 4)
    end

    @testset "GlobalNeighbourhood" begin
        gn = pso.GlobalNeighbourhood(10)
        @test gn[1] == collect(1:10)
        @test gn[4] == collect(1:10)
        @test gn[10] == collect(1:10)
        @test size(gn) == (10,)
    end

    @testset "HirachicalNeighbourhood" begin
        hn = pso.HierachicalNeighbourhood(21, 4)
        @testset "bestchild" begin
            @test pso.bestchild(hn.graph_to_particle, hn.childs[1], vcat(1.0, 0.0, fill(1.0, 19)), <) == 2
            @test pso.bestchild(hn.graph_to_particle, hn.childs[1], vcat(0.0, 1.0, fill(0.0, 19)), <) == 3
        end
        @testset "swapifnecessary" begin
            pso.swapifnecessary!(hn, fill(0.0, 21), 2, 1, 2, 1, <)
            @test hn.particle_to_graph == collect(1:21)
            @test hn.graph_to_particle == collect(1:21)
            pso.swapifnecessary!(hn, vcat(1.0, fill(0.0, 20)), 2, 1, 2, 1, <)
            @test hn.particle_to_graph == vcat(2, 1, collect(3:21))
            @test hn.graph_to_particle == vcat(2, 1, collect(3:21))
        end
        childs = pso.getchilds(4, 2)
        @test childs == [[2, 3], [4], Int[], Int[]]
        @test pso.getparents(childs) == [1, 1, 1, 2]
        childs = pso.getchilds(8, 3)
        @test childs == [[2, 3, 4], [5, 8], [6], [7], Int[], Int[], Int[], Int[]]
        @test pso.getparents(childs) == [1, 1, 1, 1, 2, 3, 4, 2]
        hn1 = pso.HierachicalNeighbourhood(21, 4)
        @test hn1[1] == [1]
        @test hn1[3] == [1]
        @test hn1[10] == [2]
        @test hn1[15] == [3]
        pso.rearrange!(hn1, vcat(1.0, fill(0.0, 19), -1.0), <)
        @test hn1[2] == [2]
        @test hn1[3] == [2]
        @test hn1[21] == [2]
        @test hn1.graph_to_particle[hn1.particle_to_graph] == collect(1:21)
        @test hn1.particle_to_graph[hn1.graph_to_particle] == collect(1:21)
        pso.rearrange!(hn1, vcat(1.0, fill(0.0, 19), -1.0), <)
        @test hn1[21] == [21]
        @test hn1[3] == [21]
        @test hn1[2] == [21]
        @test hn1.graph_to_particle[hn1.particle_to_graph] == collect(1:21)
        @test hn1.particle_to_graph[hn1.graph_to_particle] == collect(1:21)
        @test length(hn1) == 21
        hn2 = pso.HierachicalNeighbourhoodByTreeHeight(3, 4)
        @test hn2[1] == [1]
        @test hn2[3] == [1]
        @test hn2[21] == [5]
        @test size(hn2) == (21,)
        hn3 = pso.HierachicalNeighbourhood(40, 3)
        @test hn3[9] == [3]
        @test hn3[17] == [6]
        @test hn3[39] == [10]
        @test hn3[40] == [13]
        hn4 = pso.HierachicalNeighbourhoodByTreeHeight(5, 2)
        @test hn4[9] == [6]
        @test hn4[17] == [12]
        @test hn4[23] == [15]
    end
    
end
