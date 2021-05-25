JSON.lower(pa::PostAggregator) = non_nothing_dict(pa)

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

struct FieldAccess <: PostAggregator
    type::String
    name::String
    fieldName::String
    FieldAccess(name, aggregator) = new("fieldAccess", name, aggregator)
end

struct FinalizingFieldAccess <: PostAggregator
    type::String
    name::String
    fieldName::String
    FinalizingFieldAccess(name, aggregator) = new("finalizingFieldAccess", name, aggregator)
end

struct ConstantPA <: PostAggregator
    type::String
    name::String
    value::Real
    ConstantPA(name, value) = new("constant", name, value)
end

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

struct JavaScriptPA <: PostAggregator
    type::String
    name::String
    fieldNames::String
    jsfunction::String
    JavaScriptPA(name, fields, jsfunction) = new("javascript", name, fields, jsfunction)
end

JSON.lower(pa::JavaScriptPA) = Dict("type" => pa.type, "name" => pa.name, "fieldNames" => pa.fieldNames, "function" => pa.jsfunction)

struct HyperUniqueCardinality <: PostAggregator
    type::String
    name::String
    fieldName::String
    HyperUniqueCardinality(name, field) = new("hyperUniqueCardinality", name, field)
end
