@testset "Contains" begin
    @test_throws TypeError Contains("a", case_sensitive=1)
end

@testset "Fragment" begin
    @test_throws TypeError Fragment("a", case_sensitive=1)
end

@testset "SearchF" begin
    @test_throws TypeError SearchF("dimensions", Contains("a"), extractionFn=1)
end

@testset "Like" begin
    @test_throws TypeError Like("dimension", "pattern", escape=1)
    @test_throws TypeError Like("dimension", "pattern", extractionFn=1)
end

@testset "Bound" begin
    @test_throws TypeError Bound("dimension", lower=1)
    @test_throws TypeError Bound("dimension", upper=1)
    @test_throws ErrorException("At least one of lower and upper must be specified") Bound("diimension")
    @test_throws TypeError Bound("dimension", lower="a", lowerStrict=1)
    @test_throws TypeError Bound("dimension", lower="a", upperStrict=1)
    @test_throws TypeError Bound("dimension", lower="a", ordering=1)
    @test_throws TypeError Bound("dimension", lower="a", extractionFn=1)
end

@testset "IntervalF" begin
    @test_throws TypeError IntervalF("dimension", [Interval("a", "b")], extractionFn=1)
end
