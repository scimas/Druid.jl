@testset "Expression" begin
    @test_throws ErrorException("Invalid outputType") Expression("name", "expr", outputType="a")
end
