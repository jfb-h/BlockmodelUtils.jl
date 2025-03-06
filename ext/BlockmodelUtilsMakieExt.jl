module BlockmodelUtilsMakieExt

using BlockmodelUtils
import Makie


function midpoints(x)
    res = Float64[]
    for i in eachindex(x)[1:(end - 1)]
        val, nextval = x[i], x[i + 1]
        push!(res, val + (nextval - val) / 2)
    end
    return res
end

function BlockmodelUtils.permuteplot!(
        ax, bm::Blockmodel;
        cellcolor = :black,
        linecolor = :black,
        framecolor = linecolor,
        backgroundcolor = :white,
        rotate_xlabels = false,
        xticklabels = bm.labels,
        yticklabels = bm.labels,
    )
    pcounts = cumsum(BlockmodelUtils.groupsizes(bm))
    centers = midpoints(vcat(0, pcounts)) .+ 0.5

    Makie.heatmap!(ax, Matrix(bm); colormap = [backgroundcolor, cellcolor])
    Makie.vlines!(ax, pcounts .+ 0.5; color = linecolor)
    Makie.hlines!(ax, pcounts .+ 0.5; color = linecolor)

    ax.xticks = (centers, xticklabels)
    ax.yticks = (centers, yticklabels)
    ax.xgridvisible = false
    ax.ygridvisible = false
    ax.leftspinecolor = ax.rightspinecolor = framecolor
    ax.topspinecolor = ax.bottomspinecolor = framecolor
    ax.aspect = 1

    if rotate_xlabels
        ax.xticklabelrotation = 1
        ax.xticklabelalign = (:right, :center)
    end

    return ax
end

function circlepoints(N, p0, r)
    x(n) = p0[1] + r * cos(2π * n / N)
    y(n) = p0[2] + r * sin(2π * n / N)
    return [Makie.Point2(x(n), y(n)) for n in 1:N]
end

function circlelayout(bm::Blockmodel; radii)
    sizes = BlockmodelUtils.groupsizes(bm)
    Nproj = length(sizes)
    centers = vcat([Makie.Point2(0.0, 0.0)], circlepoints(Nproj - 1, (0.0, 0.0), 5.0))
    return mapreduce(vcat, centers, sizes, radii) do c, s, r
        circlepoints(s, (c[1], c[2]), r)
    end
end

function BlockmodelUtils.flowerplot!(
        ax, bm;
        edgecolor = :grey70,
        edgewidth = 1,
        nodecolor = :black,
        showlabels = true,
        radii = fill(1, length(bm.labels)),
        args...
    )
    positions = circlelayout(bm; radii)
    invidx = sortperm(bm.permidx)
    edgepos = [
        (positions[invidx[e.src]], positions[invidx[e.dst]])
        for e in BlockmodelUtils.Graphs.edges(bm.graph)
    ]

    Makie.linesegments!(ax, edgepos; color = edgecolor, linewidth = edgewidth)
    Makie.scatter!(ax, positions; color = nodecolor, args...)

    sizes = BlockmodelUtils.groupsizes(bm)

    if showlabels
        textpos = vcat(
            [Makie.Point2(0.0, 0.0)],
            circlepoints(length(sizes) - 1, (0.0, 0.0), 5.0)
        )
        Makie.text!(
            ax, textpos;
            text = bm.labels,
            align = (:center, :center),
            font = :bold
        )
    end

    Makie.hidedecorations!(ax)
    Makie.hidespines!(ax)

    return ax
end

function BlockmodelUtils.densityplot!(
        ax, bm::Blockmodel;
        xticklabels = bm.labels,
        yticklabels = bm.labels,
        rotate_xlabels = false,
        kwargs...
    )
    m = BlockmodelUtils.Graphs.density(bm)

    Makie.heatmap!(ax, m; kwargs...)

    ax.xticks = (1:length(xticklabels), xticklabels)
    ax.yticks = (1:length(yticklabels), yticklabels)
    ax.aspect = 1

    if rotate_xlabels
        ax.xticklabelrotation = 1
        ax.xticklabelalign = (:right, :center)
    end

    return ax
end

_drop_fig_ax(nt) = Base.structdiff(nt, NamedTuple{(:figure, :axis)})

function _impl_plotfun(fun!, bm::Blockmodel; kwargs...)
    nt = NamedTuple(kwargs)
    figureargs = haskey(nt, :figure) ? nt.figure : (;)
    axisargs = haskey(nt, :axis) ? nt.figure : (;)
    plotargs = _drop_fig_ax(nt)

    fg = Makie.Figure(; figureargs...)
    ax = Makie.Axis(fg[1, 1]; axisargs...)
    ax.aspect = 1

    fun!(ax, bm; plotargs...)

    return fg
end

BlockmodelUtils.permuteplot(bm; kwargs...) = _impl_plotfun(permuteplot!, bm; kwargs...)
BlockmodelUtils.densityplot(bm; kwargs...) = _impl_plotfun(densityplot!, bm; kwargs...)
BlockmodelUtils.flowerplot(bm; kwargs...) = _impl_plotfun(flowerplot!, bm; kwargs...)

end
