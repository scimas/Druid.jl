using Druid
using Test

@testset "Aggregations" begin
    include("aggregations.jl")
end

@testset "Datasources" begin
    include("datasources.jl")
end

@testset "Dimensionspecs" begin
    include("dimensionspecs.jl")
end
