@testset "Join" begin
    @test_throws ErrorException("Invalid joinType") Join(Table("wikipedia"), Lookup("lookup"), "prefix", "condition", "outer")
end
