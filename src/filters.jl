JSON.lower(::Filter) = error("Unknown Filter")
JSON.lower(::SearchQuerySpec) = error("Unknown SearchQuerySpec")

struct Selector <: Filter
    dimension::String
    value::String
end

JSON.lower(f::Selector) = Dict("type" => "selector", "dimension" => f.dimension, "value" => f.value)

struct ColumnComparison <: Filter
    dimensions::Tuple{DimensionSpec, DimensionSpec}
end

ColumnComparison(dim1, dim2) = ColumnComparison((dim1, dim2))

JSON.lower(f::ColumnComparison) = Dict("type" => "columnComparison", "dimensions" => f.dimensions)

struct RegexF <: Filter
    dimension::String
    pattern::String
end

JSON.lower(f::RegexF) = Dict("type" => "regex", "dimension" => f.dimension, "pattern" => f.pattern)

struct AndF <: Filter
    filters::Vector{Filter}
end

JSON.lower(f::AndF) = Dict("type" => "and", "fields" => f.filters)

struct OrF <: Filter
    filters::Vector{Filter}
end

JSON.lower(f::OrF) = Dict("type" => "or", "fields" => f.filters)

struct NotF <: Filter
    filter::Filter
end

JSON.lower(f::NotF) = Dict("type" => "not", "field" => f.filter)

struct JavaScriptF <: Filter
    dimension::String
    jsfunction::String
end

JSON.lower(f::JavaScriptF) = Dict("type" => "javascript", "dimension" => f.dimension, "function" => f.jsfunction)

struct Contains <: SearchQuerySpec
    value::String
    caseSensitive
    function Contains(value; case_sensitive=nothing)
        case_sensitive === nothing || isa(case_sensitive, Bool) || error("case_sensitive must be a Bool")
        new(value, case_sensitive)
    end
end

function JSON.lower(sqs::Contains)
    d = Dict()
    d["type"] = "contains"
    non_nothing_dict(sqs, d)
end

struct InsensitiveContains <: SearchQuerySpec
    value::String
end

JSON.lower(sqs::InsensitiveContains) = Dict("type" => "insensitive_contains", "value" => sqs.value)

struct Fragment <: SearchQuerySpec
    value::String
    caseSensitive
    function Fragment(value; case_sensitive=nothing)
        case_sensitive === nothing || isa(case_sensitive, Bool) || error("case_sensitive must be a Bool")
        new(value, case_sensitive)
    end
end

function JSON.lower(sqs::Fragment)
    d = Dict()
    d["type"] = "fragment"
    non_nothing_dict(sqs, d)
end

struct SearchF <: Filter
    dimension::String
    query::SearchQuerySpec
end

JSON.lower(f::SearchF) = Dict("type" => "search", "dimension" => f.dimension, "query" => f.query)

struct InF <: Filter
    dimension::String
    values::Vector
end

JSON.lower(f::InF) = Dict("type" => "in", "dimension" => f.dimension, "values" => f.values)

struct Like <: Filter
    dimension::String
    pattern::String
    escape
    function Like(dimension, pattern; escape=nothing)
        escape === nothing || isa(escape, AbstractString) || error("escape must be a String")
        new(dimension, pattern, escape)
    end
end

function JSON.lower(f::Like)
    d = Dict()
    d["type"] = "like"
    non_nothing_dict(f, d)
end

struct Bound <: Filter
    dimension::String
    lower
    upper
    lowerStrict
    upperStrict
    ordering
    function Bound(dimension; lower=nothing, upper=nothing, lowerStrict=nothing, upperStrict=nothing, ordering=nothing)
        lower === nothing || isa(lower, String) || error("lower must be a String")
        upper === nothing || isa(upper, String) || error("upper must be a String")
        lower === upper === nothing && error("At least one of lower and upper must be specified")
        lowerStrict === nothing || isa(lowerStrict, Bool) || error("lowerStrict must be a Bool")
        upperStrict === nothing || isa(upperStrict, Bool) || error("upperStrict must be a Bool")
        ordering === nothing || isa(ordering, String) || error("ordering must be a String")
        new(dimension, lower, upper, lowerStrict, upperStrict, ordering)
    end
end

function JSON.lower(f::Bound)
    d = Dict()
    d["type"] = "bound"
    non_nothing_dict(f, d)
end

struct IntervalF <: Filter
    dimension::String
    intervals::Vector{Interval}
end

JSON.lower(f::IntervalF) = Dict("type" => "interval", "dimension" => f.dimension, "intervals" => f.intervals)

struct TrueF <: Filter
end

JSON.lower(f::TrueF) = Dict("type" => "true")
