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
S = [6 11; 11 8]

groups = repeat(['a', 'b'], inner = 5)
bm = blockmodel(g, groups)

@testset "BlockmodelUtils.jl" begin
    @test bm isa Blockmodel

    m = Matrix(bm)

    @test m isa Matrix{Int64}
    @test m[bm.permidx, bm.permidx] == A

    @test BlockmodelUtils.groupsizes(bm) == [5, 5]

    @test bm.labels == ["a", "b"]

    @test map(sum, bm) == S
    @test density(bm) == [
        S[1,1] / 20  S[1,2] / 25;
        S[2,1] / 25  S[2,2] / 20
    ]
end
