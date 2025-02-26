module BlockmodelUtils

import IterTools: groupby, partition
import PrettyTables: pretty_table, ft_printf, @crayon_str
import BlockArrays: BlockMatrix
import Graphs: Graphs, AbstractGraph, AbstractSimpleGraph,
    adjacency_matrix, density, is_directed

export Blockmodel, blockmodel

export permuteplot!, permuteplot
export flowerplot!, flowerplot
export densityplot!, densityplot

# TODO: docs, workflows

struct Blockmodel{T <: Real, G <: AbstractGraph}
    permidx::Vector{Int}
    blocks::BlockMatrix{T}
    labels::Vector{String}
    graph::G
end

function groupsizes(bm)
    s = vcat(0, bm.blocks.axes[1].lasts)
    return map(x -> -(reverse(x)...), partition(s, 2, 1))
end

function _print_densities(m, labels)
    return pretty_table(
        m;
        formatters = ft_printf("%.3f"),
        header = collect(eachindex(labels)),
        hlines = :all,
        row_labels = labels,
        border_crayon = crayon"dark_gray"
    )
end

Base.show(io::IO, bm::Blockmodel) = print(io, typeof(bm))
function Base.show(io::IO, ::MIME"text/plain", bm::Blockmodel)
    m = density(bm)
    println(io, typeof(bm))
    return if !get(io, :compact, false)
        println(io, "$(size(m, 1)) groups with sizes ", groupsizes(bm))
        _print_densities(m, bm.labels)
    end
end

function blockmodel(g::AbstractGraph, groups::AbstractVector; by = identity)
    p = sortperm(groups; by)
    s = length.(groupby(identity, groups[p]))
    l = string.(unique(groups[p]))
    a = adjacency_matrix(g)
    b = BlockMatrix(a, s, s)
    return Blockmodel(p, b, l, g)
end

Base.map(fun, bm::Blockmodel) = map(fun, bm.blocks.blocks)
Base.Matrix(bm::Blockmodel) = Matrix(bm.blocks)

# Base.iterate(bm::Blockmodel, state) = iterate(bm.blocks.blocks, state)
# Base.iterate(bm::Blockmodel) = iterate(bm.blocks.blocks)
# Base.length(bm::Blockmodel) = length(bm.blocks.blocks)

function Graphs.density(bm::Blockmodel{T, G}) where {
        T <: Integer, G <: AbstractSimpleGraph,
    }
    B = bm.blocks.blocks
    return map(CartesianIndices(B)) do i
        L = first(Tuple(i)) == last(Tuple(i)) ?
            (length(B[i]) - size(B[i], 1)) :
            length(B[i])
        sum(B[i]) / L
    end
end

function densityplot! end
function densityplot end

function permuteplot! end
function permuteplot end

function flowerplot! end
function flowerplot end

end
