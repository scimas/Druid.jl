JSON.lower(::Aggregator) = error("Unknown Aggregator")

struct Count <: Aggregator
    as::String
end

JSON.lower(a::Count) = Dict("type" => "count", "name" => a.as)

struct SingleField <: Aggregator
    type::String
    fieldName::String
    name::String
    function SingleField(type, of, as)
        type ∈ [
            "longSum", "doubleSum", "floatSum",
            "longMin", "doubleMin", "floatMin",
            "longMax", "doubleMax", "floatMax",
            "longFirst", "doubleFirst", "floatFirst",
            "longLast", "doubleLast", "floatLast",
            "longAny", "doubleAny", "floatAny",
            "doubleMean"
        ] || error("Unknown SingleField aggregation")
        new(type, of, as)
    end
end

JSON.lower(a::SingleField) = non_nothing_dict(a, Dict())

struct StringAgg <: Aggregator
    type::String
    fieldName::String
    name::String
    maxStringBytes
    function StringAgg(type, of, as, maxStringBytes)
        type = lowercase(type)
        type ∈ ["first", "last", "any"] || error("Unknown StringAgg aggregation")
        maxStringBytes === nothing || (isa(maxStringBytes, Integer) && maxStringBytes >= 0) || error("maxStringBytes must be a positive integer")
        new("string" * titlecase(type), of, as, maxStringBytes)
    end
end

StringAgg(type, of, as; maxStringBytes=nothing) = StringAgg(type, of, as, maxStringBytes)

function JSON.lower(a::StringAgg)
    d = Dict()
    d["type"] = a.type
    d["fieldName"] = a.fieldName
    d["name"] = a.name
    if !(a.maxStringBytes === nothing)
        d["maxStringBytes"] = a.maxStringBytes
    end
    d
end

struct Grouping <: Aggregator
    groupings::Vector{String}
    as::String
end

JSON.lower(a::Grouping) = Dict("type" => "grouping", "name" => a.as, "groupings" => a.groupings)

struct Filtered <: Aggregator
    filter::Filter
    aggregator::Aggregator
end

JSON.lower(a::Filtered) = Dict("type" => "filtered", "filter" => a.filter, "aggregator" => a.aggregator)
