@testset "SimpleGranularity" begin
    @test_throws ErrorException("Unknown type of simple granularity") SimpleGranularity("a")
end

@testset "DurationGranularity" begin
    @test_throws TypeError DurationGranularity(2, origin=1)
end

@testset "PeriodGranularity" begin
    @test_throws TypeError PeriodGranularity("a", origin=1)
    @test_throws TypeError PeriodGranularity("a", timezone=1)
end
