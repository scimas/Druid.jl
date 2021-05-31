JSON.lower(pa::PostAggregator) = non_nothing_dict(pa)

"""
    Arithmetic(name::String, fn::String, fields::Vector{PostAggregator}; ordering=nothing)

Apply the `fn` aggregation to the `fields`.

ordering should be a String if provided.
"""
struct Arithmetic <: PostAggregator
    type::String
    name::String
    fn::String
    fields::Vector{PostAggregator}
    ordering
    function Arithmetic(name, fn, fields; ordering=nothing)
        fn = string(fn)
        fn ∈ ["+", "-", "*", "/", "quotient"] || error("Unknown arithmetic function")
        ordering === nothing || ordering == "numericFirst" || error("Invalid ordering")
        new("arithmetic", name, fn, fields, ordering)
    end
end

"""
    FieldAccess(name::String, aggregator::String)
    FieldAccess(aggregator::String)

Access the `aggregator` and return as `name`.
"""
struct FieldAccess <: PostAggregator
    type::String
    name::String
    fieldName::String
    FieldAccess(name, aggregator) = new("fieldAccess", name, aggregator)
end
FieldAccess(aggregator) = FieldAccess(aggregator, aggregator)

"""
    FinalizingFieldAccess(name::String, aggregator::String)
    FinalizingFieldAccess(aggregator::String)

Access the `aggregator` and return as `name`.
"""
struct FinalizingFieldAccess <: PostAggregator
    type::String
    name::String
    fieldName::String
    FinalizingFieldAccess(name, aggregator) = new("finalizingFieldAccess", name, aggregator)
end
FinalizingFieldAccess(aggregator) = FinalizingFieldAccess(aggregator, aggregator)

"""
    ConstantPA(name::String, value::Real)

Return a constant value as `name`.
"""
struct ConstantPA <: PostAggregator
    type::String
    name::String
    value::Real
    ConstantPA(name, value) = new("constant", name, value)
end

"""
    Greatest(name::String, fields::Vector{PostAggregator}, dtype::String)

Find the largest value per row across the `fields` of type `dtype` (double,
long) and return as `name`.
"""
struct Greatest <: PostAggregator
    type::String
    name::String
    fields::Vector{PostAggregator}
    function Greatest(name, fields, dtype)
        dtype = lowercase(dtype)
        dtype ∈ ["double", "long"] || error("Invalid data type")
        new(dtype * "Greatest", name, fields)
    end
end

"""
    Least(name::String, fields::Vector{PostAggregator}, dtype::String)

Find the smallest value per row across the `fields` of type `dtype` (double,
long) and return as `name`.
"""
struct Least <: PostAggregator
    type::String
    name::String
    fields::Vector{PostAggregator}
    function Least(name, fields, dtype)
        dtype = lowercase(dtype)
        dtype ∈ ["double", "long"] || error("Invalid data type")
        new(dtype * "Least", name, fields)
    end
end

"""
    JavaScriptPA(name::String, fieldNames::Vector{String}, jsfunction::String)

Post aggregate the `fieldNames` aggregators using a custom `jsfunction`
JavaScript function.
"""
struct JavaScriptPA <: PostAggregator
    type::String
    name::String
    fieldNames::Vector{String}
    jsfunction::String
    JavaScriptPA(name, fields, jsfunction) = new("javascript", name, fields, jsfunction)
end

JSON.lower(pa::JavaScriptPA) = Dict("type" => pa.type, "name" => pa.name, "fieldNames" => pa.fieldNames, "function" => pa.jsfunction)

"""
    HyperUniqueCardinality(name::String, field::String)
    HyperUniqueCardinality(field::String)

Post aggregator of a hyper unique aggregation.
"""
struct HyperUniqueCardinality <: PostAggregator
    type::String
    name::String
    fieldName::String
    HyperUniqueCardinality(name, field) = new("hyperUniqueCardinality", name, field)
end
HyperUniqueCardinality(field) = HyperUniqueCardinality(field, field)
