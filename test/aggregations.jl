@testset "SingleField" begin
    @test_throws ErrorException("Unknown SingleField aggregation") SingleField("weird_aggregation", "field", "name")
end

@testset "StringAgg" begin
    @test_throws ErrorException("Unknown StringAgg aggregation") StringAgg("second", "field", "name")
    @test_throws ErrorException("maxStringBytes must be a positive integer") StringAgg("first", "field", "name", maxStringBytes="a")
    @test_throws ErrorException("maxStringBytes must be a positive integer") StringAgg("first", "field", "name", maxStringBytes=-1)
end
