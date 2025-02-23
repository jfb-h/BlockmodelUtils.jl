# Blockmodels

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://jfb-h.github.io/Blockmodels.jl/stable)
[![In development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://jfb-h.github.io/Blockmodels.jl/dev)
[![Build Status](https://github.com/jfb-h/Blockmodels.jl/workflows/Test/badge.svg)](https://github.com/jfb-h/Blockmodels.jl/actions)
[![Test workflow status](https://github.com/jfb-h/Blockmodels.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/jfb-h/Blockmodels.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Docs workflow Status](https://github.com/jfb-h/Blockmodels.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/jfb-h/Blockmodels.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jfb-h/Blockmodels.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jfb-h/Blockmodels.jl)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)

Represent, analyse, and plot [network blockmodels](https://en.wikipedia.org/wiki/Blockmodeling), i.e., blocked graph adjacency matrices based on some node partition. As of now, this package does *not* contain functionality to infer node partitions (i.e., clusters or equivalence-based) from network structure. Its main purpose is instead to provide a simple representation of blockmodels and some plotting utilities.

# Getting started

For a graph `g` and a vector of group labels `groups`, create a blockmodel with the `blockmodel` function:

```julia
using Graphs, Blockmodels

n = 20
g = erdos_renyi(n, 0.1)
groups = rand('a':'d', n)

bm = blockmodel(g, groups)
```

The resulting `Blockmodel` prints the blockdensity matrix:

```julia-repl
Blockmodel{Int64, SimpleGraph{Int64}}
4 groups with sizes [6, 7, 4, 3]
┌───┬───────┬───────┬───────┬───────┐
│   │     1 │     2 │     3 │     4 │
├───┼───────┼───────┼───────┼───────┤
│ a │ 0.200 │ 0.214 │ 0.250 │ 0.278 │
├───┼───────┼───────┼───────┼───────┤
│ b │ 0.214 │ 0.095 │ 0.179 │ 0.286 │
├───┼───────┼───────┼───────┼───────┤
│ c │ 0.250 │ 0.179 │ 0.167 │ 0.083 │
├───┼───────┼───────┼───────┼───────┤
│ d │ 0.278 │ 0.286 │ 0.083 │ 0.000 │
└───┴───────┴───────┴───────┴───────┘
```


## How to Cite

If you use Blockmodels.jl in your work, please cite using the reference given in [CITATION.cff](https://github.com/jfb-h/Blockmodels.jl/blob/main/CITATION.cff).

