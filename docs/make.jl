using Blockmodels
using Documenter

DocMeta.setdocmeta!(Blockmodels, :DocTestSetup, :(using Blockmodels); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [Blockmodels],
    authors = "Jakob Hoffmann <jfb-hoffmann@homtail.de>",
    repo = "https://github.com/jfb-h/Blockmodels.jl/blob/{commit}{path}#{line}",
    sitename = "Blockmodels.jl",
    format = Documenter.HTML(; canonical = "https://jfb-h.github.io/Blockmodels.jl"),
    pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/jfb-h/Blockmodels.jl")
