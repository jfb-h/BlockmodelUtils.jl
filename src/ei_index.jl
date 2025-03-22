isdir(::T) where {T <: AbstractGraph} = Val(is_directed(T))

"""
    ei_index(g, groups; level=:graph, mode=:both)

Compute Krackhardt's EI-index (Krackhardt & Stern 1988) for graph `g` and vector of group affiliations `groups`,
defined as (E - I) / (E + I) for external (between group) edges E and internal (withing group) edges I.

Specify the `level` at wich to compute the index by setting the respective keyword to `graph`, `group`, or `node`.
For directed `g`, specify the `mode` as `both`, `in`, or `out`. For `level=graph`, the three modes will be the same.

# Example

```julia
using Graphs, BlockmodelUtils

g = erdos_renyi(20, 0.1);
gs = rand('a':'c', 20);
ei_index(g, gs; level=:group)
```
"""
function ei_index(g::AbstractGraph, groups::AbstractVector; level = :graph, mode = :both)
    return ei_index(isdir(g), g, groups; level, mode)
end

function ei_index(::Val{false}, g, groups; level, mode)
    return _ei_index(all_neighbors, g, groups; level)
end

function ei_index(::Val{true}, g, groups; level, mode)
    if mode == :both
        return _ei_index(all_neighbors, g, groups; level)
    elseif mode == :in
        return _ei_index(inneighbors, g, groups; level)
    elseif mode == :out
        return _ei_index(outneighbors, g, groups; level)
    else
        throw(ArgumentError("mode $mode not supported."))
    end
end

function _ei_index(nbfun, g, groups; level)
    if level == :graph
        return _ei_graph(g, groups)
    elseif level == :group
        return _ei_group(nbfun, g, groups)
    elseif level == :node
        return _ei_node(nbfun, g, groups)
    else
        throw(ArgumentError("level $level not supported."))
    end
end

function _ei_graph(g, groups)
    I = sum(@views groups[src(e)] == groups[dst(e)] for e in edges(g))
    L = ne(g)
    return (L - 2I) / L
end

function _ei_group(nbfun, g, groups::Vector{T}) where {T}
    L = Dict{T, Int}(u => 0 for u in unique(groups))
    I = copy(L)
    for v in vertices(g)
        for n in nbfun(g, v)
            L[groups[v]] += 1
            if @views groups[v] == groups[n]
                I[groups[v]] += 1
            end
        end
    end
    return Dict(k => (L[k] - 2 * I[k]) / L[k] for k in keys(L))
end

function _ei_node(nbfun, g, groups)
    return map(vertices(g)) do v
        I = L = 0
        for n in nbfun(g, v)
            L += 1
            if @views groups[v] == groups[n]
                I += 1
            end
        end
        (L - 2I) / L
    end
end
