ds = Table("wikipedia")
intervals = [Interval("a", "b")]
granularity = SimpleGranularity("hour")
dimspec = DefaultDS("dimension")
tpnmetric = Dimension()
query = Contains("a")

@testset "Timeseries" begin
    @test_throws TypeError Timeseries(
        ds, intervals, granularity, filter=1)
    @test_throws TypeError Timeseries(
        ds, intervals, granularity, aggregations=1)
    @test_throws TypeError Timeseries(
        ds, intervals, granularity, postAggregations=1)
    @test_throws TypeError Timeseries(
        ds, intervals, granularity, virtualColumns=1)
    @test_throws TypeError Timeseries(
        ds, intervals, granularity, descending=1)
    @test_throws ErrorException("limit must be a non-negative integer") Timeseries(
        ds, intervals, granularity, limit=-1)
    @test_throws TypeError Timeseries(
        ds, intervals, granularity, context=1)
end

@testset "Dimension" begin
    @test_throws ErrorException("Invalid ordering") Dimension(ordering="a")
    @test_throws TypeError Dimension(previousStop=1)
end

@testset "TopN" begin
    @test_throws TypeError TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, filter=1)
    @test_throws TypeError TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, aggregations=1)
    @test_throws TypeError TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, postAggregations=1)
    @test_throws TypeError TopN(
        ds, intervals, granularity, dimspec, 1, tpnmetric, virtualColumns=1)
    @test_throws TypeError TopN(
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
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, filter=1)
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, aggregations=1)
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, postAggregations=1)
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, virtualColumns=1)
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, limitSpec=1)
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, context=1)
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, having=1)
    @test_throws TypeError GroupBy(
        ds, [dimspec], intervals, granularity, subtotalsSpec=1)
end

@testset "Scan" begin
    @test_throws TypeError Scan(
        ds, intervals, filter=1)
    @test_throws TypeError Scan(
        ds, intervals, columns=1)
    @test_throws ErrorException("Invalid order") Scan(
        ds, intervals, order="a")
    @test_throws TypeError Scan(
        ds, intervals, virtualColumns=1)
    @test_throws ErrorException("limit must be a non-negative integer") Scan(
        ds, intervals, limit=-1)
    @test_throws ErrorException("offset must be a non-negative integer") Scan(
        ds, intervals, offset=-1)
    @test_throws ErrorException("Invalid resultFormat") Scan(
        ds, intervals, resultFormat=1)
    @test_throws ErrorException("batchSize must be a non-negative integer") Scan(
        ds, intervals, batchSize=-1)
    @test_throws TypeError Scan(
        ds, intervals, context=1)
    @test_throws TypeError Scan(
        ds, intervals, legacy=1)
end

@testset "Search" begin
    @test_throws TypeError Search(
        ds, intervals, query, granularity=1)
    @test_throws TypeError Search(
        ds, intervals, query, filter=1)
    @test_throws TypeError Search(
        ds, intervals, query, virtualColumns=1)
    @test_throws ErrorException("Invalid sort value") Search(
        ds, intervals, query, sort="a")
    @test_throws ErrorException("limit must be a non-negative integer") Search(
        ds, intervals, query, limit=-1)
    @test_throws TypeError Search(
        ds, intervals, query, context=1)
end

@testset "TimeBoundary" begin
    @test_throws ErrorException("Invalid bound") TimeBoundary(ds, bound="a")
    @test_throws TypeError TimeBoundary(ds, filter=1)
    @test_throws TypeError TimeBoundary(ds, virtualColumns=1)
    @test_throws TypeError TimeBoundary(ds, context=1)
end

@testset "SegmentMetadata" begin
    @test_throws TypeError SegmentMetadata(
        ds, intervals=1)
    @test_throws TypeError SegmentMetadata(
        ds, toInclude=1)
    @test_throws TypeError SegmentMetadata(
        ds, merge=1)
    @test_throws ErrorException("Invalid analysisTypes") SegmentMetadata(
        ds, analysisTypes="a")
    @test_throws TypeError SegmentMetadata(
        ds, lenientAggregatorMerge=1)
    @test_throws TypeError SegmentMetadata(
        ds, virtualColumns=1)
    @test_throws TypeError SegmentMetadata(
        ds, context=1)
end

@testset "DatasourceMetadata" begin
    @test_throws TypeError DatasourceMetadata(ds, context=1)
end

@testset "Parameter" begin
    @test_throws ErrorException("Invalid 'type'") Parameter("a", 1)
end

@testset "SQL" begin
    @test_throws TypeError Sql("query", parameters=1)
    @test_throws ErrorException("Invalid resultFormat") Sql("query", resultFormat="a")
    @test_throws TypeError Sql("query", header=1)
    @test_throws TypeError Sql("query", context=1)
end
