using BlockmodelUtils
using Graphs
using Test

A = [
    0 0 0 0 0   0 1 1 0 0;
    0 0 1 1 0   0 1 1 1 0;
    0 1 0 0 0   0 0 0 1 0;
    0 1 0 0 1   0 1 0 0 1;
    0 0 0 1 0   1 1 1 0 0;

    0 0 0 0 1   0 0 1 0 0;
    1 1 0 1 1   0 0 0 1 1;
    1 1 0 0 1   1 0 0 0 0;
    0 1 1 0 0   0 1 0 0 1;
    0 0 0 1 0   0 1 0 1 0
]

g = SimpleGraph(A)

groups = ['b', 'a', 'a', 'a', 'b', 'a', 'b', 'a', 'b', 'b']
bm = blockmodel(g, groups)

@testset "BlockmodelUtils.jl" begin
    @test bm isa Blockmodel

    m = Matrix(bm)

    @test m isa Matrix{Int64}
    @test A[bm.permidx, bm.permidx] == Matrix(bm)

    @test BlockmodelUtils.groupsizes(bm) == [5, 5]

    @test bm.labels == ["a", "b"]

    S = map(sum, bm)

    saa = sum(edges(g)) do e
        groups[src(e)] == groups[dst(e)] == 'a'
    end

    sbb = sum(edges(g)) do e
        groups[src(e)] == groups[dst(e)] == 'b'
    end

    sab = sum(edges(g)) do e
        (groups[src(e)] == 'a' && groups[dst(e)] == 'b') ||
        (groups[src(e)] == 'b' && groups[dst(e)] == 'a')
    end

    @test S[1,1] / 2 == saa
    @test S[2,2] / 2 == sbb
    @test S[1,2] == sab

    @test density(bm) == [
        S[1,1] / 20  S[1,2] / 25;
        S[2,1] / 25  S[2,2] / 20
    ]
end
