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

@testset "Filters" begin
    include("filters.jl")
end

@testset "Granularities" begin
    include("granularities.jl")
end

@testset "Havingspecs" begin
    include("having.jl")
end

@testset "Intervals" begin
    include("intervals.jl")
end

@testset "PostAggregations" begin
    include("post_aggregations.jl")
end

@testset "VirtualColumns" begin
    include("virtualcolumns.jl")
end
