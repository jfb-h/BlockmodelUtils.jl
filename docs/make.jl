using BlockmodelUtils
using Documenter

DocMeta.setdocmeta!(BlockmodelUtils, :DocTestSetup, :(using BlockmodelUtils); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [BlockmodelUtils],
    authors = "Jakob Hoffmann <jfb-hoffmann@homtail.de>",
    repo = "https://github.com/jfb-h/BlockmodelUtils.jl/blob/{commit}{path}#{line}",
    sitename = "BlockmodelUtils.jl",
    format = Documenter.HTML(; canonical = "https://jfb-h.github.io/BlockmodelUtils.jl"),
    pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/jfb-h/BlockmodelUtils.jl")
