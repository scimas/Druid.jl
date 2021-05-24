JSON.lower(::Aggregator) = error("Unknown Aggregator")

struct Count <: Aggregator
    name::String
end

JSON.lower(a::Count) = non_nothing_dict(a, Dict{Any, Any}("type" => "count"))

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

JSON.lower(a::StringAgg) = non_nothing_dict(a, Dict())

struct Grouping <: Aggregator
    groupings::Vector{String}
    name::String
end

JSON.lower(a::Grouping) = non_nothing_dict(a, Dict{Any, Any}("type" => "grouping"))

struct Filtered <: Aggregator
    filter::Filter
    aggregator::Aggregator
end

JSON.lower(a::Filtered) = non_nothing_dict(a, Dict{Any, Any}("type" => "filtered"))
