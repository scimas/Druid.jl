JSON.lower(a::Aggregator) = non_nothing_dict(a)

"""
    Count(output_name)

Count number of rows.
"""
struct Count <: Aggregator
    type::String
    name::String
    Count(name) = new("count", name)
end

"""
    SingelField(type, field, output_name)

Apply `type` aggregator to the `field` and get result as `output_name`.

Available `type`s: "longSum", "doubleSum", "floatSum", "longMin", "doubleMin",
"floatMin", "longMax", "doubleMax", "floatMax", "longFirst", "doubleFirst",
"floatFirst", "longLast", "doubleLast", "floatLast", "longAny", "doubleAny",
"floatAny", "doubleMean"
"""
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

"""
    StringAgg(type, field, output_name; maxStringBytes=nothing)

Apply `type` string aggregator to `field` and get result as `output_name`.

Available `type`s: "first", "last", "any"

See Druid documentation for `maxStringBytes`.
"""
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

"""
    Grouping(groupings, name)

Grouping aggregator
"""
struct Grouping <: Aggregator
    type::String
    groupings::Vector{String}
    name::String
    Grouping(groupings, name) = new("grouping", groupings, name)
end

"""
    Filtered(filter, aggregator)

An aggregator that combines a filter with the `aggregator`.
"""
struct Filtered <: Aggregator
    type::String
    filter::Filter
    aggregator::Aggregator
    Aggregator(filter, aggregator) = new("filtered", filter, aggregator)
end
