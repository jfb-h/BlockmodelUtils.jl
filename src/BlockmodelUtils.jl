module BlockmodelUtils

using IterTools: groupby, partition
using PrettyTables: pretty_table, ft_printf, @crayon_str
using BlockArrays: BlockMatrix
using Graphs: Graphs, AbstractGraph, AbstractSimpleGraph
using Graphs: adjacency_matrix, density, is_directed
using Graphs: vertices, edges, src, dst, ne
using Graphs: all_neighbors, inneighbors, outneighbors

include("ei_index.jl")

export Blockmodel, blockmodel

export ei_index

export permuteplot!, permuteplot
export flowerplot!, flowerplot
export densityplot!, densityplot


"""
Struct representing a graph's blocked adjacency matrix.
"""
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

"""
    blockmodel(g, groups; by=identity)

Create a `Blockmodel` from `Graphs.AbstractGraph` `g` and vector of
group memberships `groups`. The function passed to `by` used to order
the groups in the blockmodel.

# Example

```julia
using Graphs, BlockmodelUtils

g = erdos_renyi(20, 0.1)
gs = rand(['a', 'b'], 20)
bm = blockmodel(g, gs)
"""
function blockmodel(g::AbstractGraph, groups::AbstractVector; by = identity)
    p = sortperm(groups; by)
    s = length.(groupby(identity, groups[p]))
    l = string.(unique(groups[p]))
    a = adjacency_matrix(g)
    b = BlockMatrix(a[p, p], s, s)
    return Blockmodel(p, b, l, g)
end

"""
    map(fun, bm::Blockmodel)

Map function fun over the blocks of the `Blockmodel` bm and return a
k by k matrix, where k is the number of groups constituting the blockmodel.

# Example

```julia
using Graphs, BlockmodelUtils

g = erdos_renyi(20, 0.1)
gs = rand(['a', 'b'], 20)
bm = blockmodel(g, gs)

map(sum, bm) # number of edges in each block
```
"""
Base.map(fun, bm::Blockmodel) = map(fun, bm.blocks.blocks)
Base.Matrix(bm::Blockmodel) = Matrix(bm.blocks)

# Base.iterate(bm::Blockmodel, state) = iterate(bm.blocks.blocks, state)
# Base.iterate(bm::Blockmodel) = iterate(bm.blocks.blocks)
# Base.length(bm::Blockmodel) = length(bm.blocks.blocks)

"""
    density(bm::Blockmodel)

Compute the blockdensity matrix for `Blockmodel` `bm`. For diagonal blocks, the
diagonal is subtracted from the number of possible edges.
"""
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

"""
    densityplot!(ax, bm)
    densityplot(bm)

Plot the block density matrix as a heatmap.

# Attributes

- `xticklabels = bm.labels`
- `yticklabels = bm.labels`
- `rotate_xlabels` = false
- `kwargs...` are passed to `Makie.heatmap`
"""
densityplot!, densityplot


function permuteplot! end
function permuteplot end

"""
    permuteplot!(ax, bm)
    permuteplot(bm)

Plot the permuted adjacency matrix with a grid outlining the blockmodel blocks.

# Attributes

- `cellcolor = :black`
- `linecolor = :black`
- `framecolor = linecolor`
- `rotate_xlabels = fale`
- `xticklabels = bm.labels`
- `yticklabels = bm.labels`
"""
permuteplot!, permuteplot


function flowerplot! end
function flowerplot end

"""
    flowerplot!(ax, bm)
    flowerplot(bm)

Plot the network with nodes positioned in circles according to the blockmodel groups.
The first group is placed in the center.

# Attributes

- `edgecolor = :grey70`
- `edgewidth = 1`
- `nodecolor = :black`
- `showlabels = true`
- `radii = fill(1, length(bm.labels))`
- `args...` further arguments are passed to `Makie.scatter`
"""
flowerplot!, flowerplot

end
