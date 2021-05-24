JSON.lower(::DimensionSpec) = error("Unknown DimensionSpec")

struct DefaultDS <: DimensionSpec
    dimension::String
    outputName
    outputType
    function DefaultDS(dimension; outputName=nothing, outputType=nothing)
        outputName === nothing || isa(outputName, String) || error("outputName must be a String")
        if !(outputType === nothing)
            outputType = uppercase(outputType)
        end
        outputType === nothing || outputType ∈ ["STRING", "LONG", "FLOAT"] || error("Invalid outputType")
        new(dimension, outputName, outputType)
    end
end

JSON.lower(ds::DefaultDS) = non_nothing_dict(ds, Dict{Any, Any}("type" => "default"))

struct ListFiltered <: DimensionSpec
    delegate::DimensionSpec
    values::Vector{String}
    isWhitelist
    function ListFiltered(delegate, values; isWhitelist=nothing)
        isWhitelist === nothing || isa(isWhitelist, Bool) || error("isWhitelist must be a Bool")
        new(delegate, values, isWhitelist)
    end
end

JSON.lower(ds::ListFiltered) = non_nothing_dict(ds, Dict{Any, Any}("type" => "listFiltered"))

struct RegexFiltered <: DimensionSpec
    delegate::DimensionSpec
    pattern::String
end

JSON.lower(ds::RegexFiltered) = non_nothing_dict(ds, Dict{Any, Any}("type" => "regexFiltered"))

struct PrefixFiltered <: DimensionSpec
    delegate::DimensionSpec
    prefix::String
end

JSON.lower(ds::PrefixFiltered) = non_nothing_dict(ds, Dict{Any, Any}("type" => "prefixFiltered"))

struct LookupDS <: DimensionSpec
    dimension::String
    name::String
    outputName
    function LookupDS(dimension, name; outputName=nothing)
        outputName === nothing || isa(outputName, String) || error("outputName must be a String")
    end
end

JSON.lower(ds::LookupDS) = non_nothing_dict(ds, Dict{Any, Any}("type" => "lookup"))

struct Map
    isOneToOne::Bool
    dict::Dict
end

JSON.lower(m::Map) = Dict("type" => "map", "map" => m.dict, "isOneToOne" => m.isOneToOne)

struct MapLookupDS <: DimensionSpec
    dimension::String
    lookup::Map
    outputName
    retainMissingValue
    replaceMissingValueWith
    optimize
    function MapLookupDS(dimension, lookup; outputName=nothing, retainMissingValue=nothing, replaceMissingValueWith=nothing, optimize=nothing)
        outputName === nothing || isa(outputName, String) || error("outputName must be a String")
        retainMissingValue === nothing || isa(retainMissingValue, Bool) || error("retainMissingValue must be a Bool")
        replaceMissingValueWith === nothing || isa(replaceMissingValueWith, String) || error("replaceMissingValueWith must be a String")
        optimize === nothing || isa(optimize, Bool) || error("optimize must be a Bool")
        retainMissingValue != true || !isa(replaceMissingValueWith, String) || error("Cannon specify replaceMissingValueWith when retainMissingValue == true")
        new(dimension, lookup, outputName, retainMissingValue, replaceMissingValueWith, optimize)
    end
end

JSON.lower(ds::MapLookupDS) = non_nothing_dict(ds, Dict{Any, Any}("type" => "lookup"))
