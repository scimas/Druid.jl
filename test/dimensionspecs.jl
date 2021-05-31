extractionfn = PartialEF("partial")
@testset "DefaultDS" begin
    @test_throws ErrorException("Invalid outputType") DefaultDS("dimension", outputName="name", outputType="type")
    @test_throws TypeError DefaultDS("dimension", outputName="name", outputType=1)
    @test_throws TypeError DefaultDS("dimension", outputName=0, outputType="string")
end

@testset "ExtractionDS" begin
    @test_throws ErrorException("Invalid outputType") ExtractionDS("dimension", PartialEF("partial"), outputName="name", outputType="type")
    @test_throws TypeError ExtractionDS("dimension", extractionfn, outputName="name", outputType=1)
    @test_throws TypeError ExtractionDS("dimension", extractionfn, outputName=0, outputType="string")
end

dimspec = DefaultDS("dimension")
@testset "ListFiltered" begin
    @test_throws TypeError ListFiltered(dimspec, ["a", "b"], isWhitelist=1)
end

@testset "LookupDS" begin
    @test_throws TypeError LookupDS("dimension", "name", outputName=1)
end

lookupmap = Map(true, Dict())
@testset "MapLookupDS" begin
    @test_throws TypeError MapLookupDS("dimension", lookupmap, outputName=1)
    @test_throws TypeError MapLookupDS("dimension", lookupmap, retainMissingValue=1)
    @test_throws TypeError MapLookupDS("dimension", lookupmap, replaceMissingValueWith=1)
    @test_throws TypeError MapLookupDS("dimension", lookupmap, optimize=1)
    @test_throws ErrorException("Cannon specify replaceMissingValueWith when retainMissingValue == true") MapLookupDS("dimension", lookupmap, retainMissingValue=true, replaceMissingValueWith="a")
end

@testset "RegexEF" begin
    @test_throws ErrorException("index must be a non-negative integer") RegexEF("a", index=-1)
    @test_throws ErrorException("index must be a non-negative integer") RegexEF("a", index="a")
    @test_throws TypeError RegexEF("a", replaceMissingValue=1)
end

@testset "SubstringEF" begin
    @test_throws ErrorException("length must be a non-negative integer") SubstringEF(1, length=-1)
    @test_throws ErrorException("length must be a non-negative integer") SubstringEF(1, length="a")
end

@testset "TimeFormatEF" begin
    @test_throws TypeError TimeFormatEF(format=1)
    @test_throws TypeError TimeFormatEF(timeZone=1)
    @test_throws TypeError TimeFormatEF(locale=1)
    @test_throws TypeError TimeFormatEF(granularity=1)
    @test_throws TypeError TimeFormatEF(asMillis=1)
end

@testset "TimeParseEF" begin
    @test_throws TypeError TimeParseEF("format", "format", joda=1)
end

@testset "JavaScriptEF" begin
    @test_throws TypeError JavaScriptEF("function", injective=1)
end

@testset "RegisteredLookupEF" begin
    @test_throws TypeError RegisteredLookupEF("lookup", injective=1)
    @test_throws TypeError RegisteredLookupEF("lookup", retainMissingValue=1)
    @test_throws TypeError RegisteredLookupEF("lookup", replaceMissingValueWith=1)
    @test_throws TypeError RegisteredLookupEF("lookup", optimize=1)
    @test_throws ErrorException("Cannon specify replaceMissingValueWith when retainMissingValue == true") RegisteredLookupEF("lookup", retainMissingValue=true, replaceMissingValueWith="a")
end

@testset "InlineLookupEF" begin
    @test_throws TypeError InlineLookupEF(lookupmap, injective=1)
    @test_throws TypeError InlineLookupEF(lookupmap, retainMissingValue=1)
    @test_throws TypeError InlineLookupEF(lookupmap, replaceMissingValueWith=1)
    @test_throws TypeError InlineLookupEF(lookupmap, optimize=1)
    @test_throws ErrorException("Cannon specify replaceMissingValueWith when retainMissingValue == true") InlineLookupEF(lookupmap, retainMissingValue=true, replaceMissingValueWith="a")
end

@testset "StringFormatEF" begin
    @test_throws ErrorException("Invalid nullHandling") StringFormatEF("format", nullHandling=1)
    @test_throws ErrorException("Invalid nullHandling") StringFormatEF("format", nullHandling="a")
end

@testset "UpperEF" begin
    @test_throws TypeError UpperEF(locale=1)
end

@testset "LowerEF" begin
    @test_throws TypeError LowerEF(locale=1)
end

@testset "BucketEF" begin
    @test_throws ErrorException("size must be a non-negative integer") BucketEF(size="a")
    @test_throws ErrorException("size must be a non-negative integer") BucketEF(size=-1)
    @test_throws ErrorException("offset must be a non-negative integer") BucketEF(offset="a")
    @test_throws ErrorException("offset must be a non-negative integer") BucketEF(offset=-1)
end
