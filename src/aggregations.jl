JSON.lower(a::Aggregator) = non_nothing_dict(a)

struct Count <: Aggregator
    type::String
    name::String
    Count(name) = new("count", name)
end

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

struct StringAgg <: Aggregator
    type::String
    fieldName::String
    name::String
    maxStringBytes
    function StringAgg(type, of, as; maxStringBytes=nothing)
        type = lowercase(type)
        type ∈ ["first", "last", "any"] || error("Unknown StringAgg aggregation")
        maxStringBytes === nothing || (isa(maxStringBytes, Integer) && maxStringBytes >= 0) || error("maxStringBytes must be a positive integer")
        new("string" * titlecase(type), of, as, maxStringBytes)
    end
end

struct Grouping <: Aggregator
    type::String
    groupings::Vector{String}
    name::String
    Grouping(groupings, name) = new("grouping", groupings, name)
end

struct Filtered <: Aggregator
    type::String
    filter::Filter
    aggregator::Aggregator
    Aggregator(filter, aggregator) = new("filtered", filter, aggregator)
end
