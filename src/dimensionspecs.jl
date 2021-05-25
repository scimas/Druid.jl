JSON.lower(ds::DimensionSpec) = non_nothing_dict(ds)

struct DefaultDS <: DimensionSpec
    type::String
    dimension::String
    outputName
    outputType
    function DefaultDS(dimension; outputName=nothing, outputType=nothing)
        nothing_or_type(outputName, String)
        outputType === nothing || uppercase(outputType) ∈ ["STRING", "LONG", "FLOAT"] || error("Invalid outputType")
        new("default", dimension, outputName, uppercase(outputType))
    end
end

struct ListFiltered <: DimensionSpec
    type::String
    delegate::DimensionSpec
    values::Vector{String}
    isWhitelist
    function ListFiltered(delegate, values; isWhitelist=nothing)
        nothing_or_type(isWhitelist, Bool)
        new("listFiltered", delegate, values, isWhitelist)
    end
end

struct RegexFiltered <: DimensionSpec
    type::String
    delegate::DimensionSpec
    pattern::String
    RegexFiltered(delegate, pattern) = new("regexFiltered", delegate, pattern)
end

struct PrefixFiltered <: DimensionSpec
    type::String
    delegate::DimensionSpec
    prefix::String
    PrefixFiltered(delegate, prefix) = new("prefixFiltered", delegate, prefix)
end

struct LookupDS <: DimensionSpec
    type::String
    dimension::String
    name::String
    outputName
    function LookupDS(dimension, name; outputName=nothing)
        nothing_or_type(outputName, String)
        new("lookup", dimension, name, outputName)
    end
end

struct Map
    isOneToOne::Bool
    dict::Dict
end

JSON.lower(m::Map) = Dict("type" => "map", "map" => m.dict, "isOneToOne" => m.isOneToOne)

struct MapLookupDS <: DimensionSpec
    type::String
    dimension::String
    lookup::Map
    outputName
    retainMissingValue
    replaceMissingValueWith
    optimize
    function MapLookupDS(dimension, lookup; outputName=nothing, retainMissingValue=nothing, replaceMissingValueWith=nothing, optimize=nothing)
        nothing_or_type(outputName, String)
        nothing_or_type(retainMissingValue, Bool)
        nothing_or_type(replaceMissingValueWith, String)
        nothing_or_type(optimize, Bool)
        retainMissingValue != true || !isa(replaceMissingValueWith, String) || error("Cannon specify replaceMissingValueWith when retainMissingValue == true")
        new("lookup", dimension, lookup, outputName, retainMissingValue, replaceMissingValueWith, optimize)
    end
end
