postagg = FieldAccess("name", "field")

@testset "Arithmetic" begin
    @test_throws ErrorException("Unknown arithmetic function") Arithmetic("name", "%", [postagg])
    @test_throws ErrorException("Invalid ordering") Arithmetic("name", "+", [postagg], ordering="a")
end

@testset "Greatest" begin
    @test_throws ErrorException("Invalid data type") Greatest("name", [postagg], "float")
end

@testset "Least" begin
    @test_throws ErrorException("Invalid data type") Least("name", [postagg], "float")
end
