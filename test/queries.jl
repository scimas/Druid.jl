ds = Table("wikipedia")
intervals = [Interval("a", "b")]
granularity = SimpleGranularity("hour")
dimspec = DefaultDS("dimension")
tpnmetric = Dimension()
query = Contains("a")

@testset "Timeseries" begin
    @test_throws TypeError(:typeassert, "", Filter, 1) Timeseries(
        ds, intervals, granularity, filter=1)
    @test_throws TypeError(:typeassert, "", Vector{<:Aggregator}, 1) Timeseries(
        ds, intervals, granularity, aggregations=1)
    @test_throws TypeError(:typeassert, "", Vector{<:PostAggregator}, 1) Timeseries(
        ds, intervals, granularity, postAggregations=1)
    @test_throws TypeError(:typeassert, "", Vector{<:VirtualColumn}, 1) Timeseries(
        ds, intervals, granularity, virtualColumns=1)
    @test_throws TypeError(:typeassert, "", Bool, 1) Timeseries(
        ds, intervals, granularity, descending=1)
    @test_throws ErrorException("limit must be a non-negative integer") Timeseries(
        ds, intervals, granularity, limit=-1)
    @test_throws TypeError(:typeassert, "", Dict, 1) Timeseries(
        ds, intervals, granularity, context=1)
end

@testset "Dimension" begin
    @test_throws ErrorException("Invalid ordering") Dimension(ordering="a")
    @test_throws TypeError(:typeassert, "", String, 1) Dimension(previousStop=1)
end

@testset "TopN" begin
    @test_throws TypeError(:typeassert, "", Filter, 1) TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, filter=1)
    @test_throws TypeError(:typeassert, "", Vector{<:Aggregator}, 1) TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, aggregations=1)
    @test_throws TypeError(:typeassert, "", Vector{<:PostAggregator}, 1) TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, postAggregations=1)
    @test_throws TypeError(:typeassert, "", Vector{<:VirtualColumn}, 1) TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, virtualColumns=1)
    @test_throws TypeError(:typeassert, "", Dict, 1) TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, context=1)
end

@testset "OrderByColumn" begin
    @test_throws ErrorException("Invalid direction") OrderByColumn("dimension", "a")
    @test_throws ErrorException("Invalid dimensionOrder") OrderByColumn("dimension", "ascending", dimensionOrder="a")
end

@testset "DefaultLS" begin
    @test_throws ErrorException("limit must be a non-negative integer") DefaultLS(limit=-1)
    @test_throws ErrorException("offset must be a non-negative integer") DefaultLS(offset=-1)
end

@testset "GroupBy" begin
    @test_throws TypeError(:typeassert, "", Filter, 1) GroupBy(
        ds, [dimspec], intervals, granularity, filter=1)
    @test_throws TypeError(:typeassert, "", Vector{<:Aggregator}, 1) GroupBy(
        ds, [dimspec], intervals, granularity, aggregations=1)
    @test_throws TypeError(:typeassert, "", Vector{<:PostAggregator}, 1) GroupBy(
        ds, [dimspec], intervals, granularity, postAggregations=1)
    @test_throws TypeError(:typeassert, "", Vector{<:VirtualColumn}, 1) GroupBy(
        ds, [dimspec], intervals, granularity, virtualColumns=1)
    @test_throws TypeError(:typeassert, "", LimitSpec, 1) GroupBy(
        ds, [dimspec], intervals, granularity, limitSpec=1)
    @test_throws TypeError(:typeassert, "", Dict, 1) GroupBy(
        ds, [dimspec], intervals, granularity, context=1)
    @test_throws TypeError(:typeassert, "", Union{HavingSpec, Filter}, 1) GroupBy(
        ds, [dimspec], intervals, granularity, having=1)
    @test_throws TypeError(:typeassert, "", Vector{Vector{String}}, 1) GroupBy(
        ds, [dimspec], intervals, granularity, subtotalsSpec=1)
end

@testset "Scan" begin
    @test_throws TypeError(:typeassert, "", Filter, 1) Scan(
        ds, intervals, filter=1)
    @test_throws TypeError(:typeassert, "", Vector{String}, 1) Scan(
        ds, intervals, columns=1)
    @test_throws ErrorException("Invalid order") Scan(
        ds, intervals, order="a")
    @test_throws TypeError(:typeassert, "", Vector{<:VirtualColumn}, 1) Scan(
        ds, intervals, virtualColumns=1)
    @test_throws ErrorException("limit must be a non-negative integer") Scan(
        ds, intervals, limit=-1)
    @test_throws ErrorException("offset must be a non-negative integer") Scan(
        ds, intervals, offset=-1)
    @test_throws ErrorException("Invalid resultFormat") Scan(
        ds, intervals, resultFormat=1)
    @test_throws ErrorException("batchSize must be a non-negative integer") Scan(
        ds, intervals, batchSize=-1)
    @test_throws TypeError(:typeassert, "", Dict, 1) Scan(
        ds, intervals, context=1)
    @test_throws TypeError(:typeassert, "", Bool, 1) Scan(
        ds, intervals, legacy=1)
end

@testset "Search" begin
    @test_throws TypeError(:typeassert, "", Granularity, 1) Search(
        ds, intervals, query, granularity=1)
    @test_throws TypeError(:typeassert, "", Filter, 1) Search(
        ds, intervals, query, filter=1)
    @test_throws TypeError(:typeassert, "", Vector{<:VirtualColumn}, 1) Search(
        ds, intervals, query, virtualColumns=1)
    @test_throws ErrorException("Invalid sort value") Search(
        ds, intervals, query, sort="a")
    @test_throws ErrorException("limit must be a non-negative integer") Search(
        ds, intervals, query, limit=-1)
    @test_throws TypeError(:typeassert, "", Dict, 1) Search(
        ds, intervals, query, context=1)
end

@testset "TimeBoundary" begin
    @test_throws ErrorException("Invalid bound") TimeBoundary(ds, bound="a")
    @test_throws TypeError(:typeassert, "", Filter, 1) TimeBoundary(ds, filter=1)
    @test_throws TypeError(:typeassert, "", Vector{<:VirtualColumn}, 1) TimeBoundary(ds, virtualColumns=1)
    @test_throws TypeError(:typeassert, "", Dict, 1) TimeBoundary(ds, context=1)
end

@testset "SegmentMetadata" begin
    @test_throws TypeError(:typeassert, "", Vector{<:Interval}, 1) SegmentMetadata(
        ds, intervals=1)
    @test_throws TypeError(:typeassert, "", Union{String, Vector{String}}, 1) SegmentMetadata(
        ds, toInclude=1)
    @test_throws TypeError(:typeassert, "", Bool, 1) SegmentMetadata(
        ds, merge=1)
    @test_throws ErrorException("Invalid analysisTypes") SegmentMetadata(
        ds, analysisTypes=["a"])
    @test_throws TypeError(:typeassert, "", Bool, 1) SegmentMetadata(
        ds, lenientAggregatorMerge=1)
    @test_throws TypeError(:typeassert, "", Vector{<:VirtualColumn}, 1) SegmentMetadata(
        ds, virtualColumns=1)
    @test_throws TypeError(:typeassert, "", Dict, 1) SegmentMetadata(
        ds, context=1)
end

@testset "DatasourceMetadata" begin
    @test_throws TypeError(:typeassert, "", Dict, 1) DatasourceMetadata(ds, context=1)
end

@testset "Parameter" begin
    @test_throws ErrorException("Invalid 'type'") Parameter("a", 1)
end

@testset "SQL" begin
    @test_throws TypeError(:typeassert, "", Vector{Parameter}, 1) Sql("query", parameters=1)
    @test_throws ErrorException("Invalid resultFormat") Sql("query", resultFormat="a")
    @test_throws TypeError(:typeassert, "", Bool, 1) Sql("query", header=1)
    @test_throws TypeError(:typeassert, "", Dict, 1) Sql("query", context=1)
end
