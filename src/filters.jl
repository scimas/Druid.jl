JSON.lower(f::Filter) = non_nothing_dict(f)
JSON.lower(sqs::SearchQuerySpec) = non_nothing_dict(sqs)

struct Selector <: Filter
    type::String
    dimension::String
    value::String
    Selector(dimension, value) = new("selector", dimension, value)
end

struct ColumnComparison <: Filter
    type::String
    dimensions::Tuple{DimensionSpec, DimensionSpec}
    ColumnComparison(dimensions) = new("columnComparison", dimensions)
end

ColumnComparison(dim1, dim2) = ColumnComparison((dim1, dim2))

struct RegexF <: Filter
    type::String
    dimension::String
    pattern::String
    RegexF(dimension, pattern) = new("regex", dimension, pattern)
end

struct AndF <: Filter
    type::String
    fields::Vector{Filter}
    AndF(filters) = new("and", filters)
end

struct OrF <: Filter
    type::String
    fields::Vector{Filter}
    OrF(filters) = new("or", filters)
end

struct NotF <: Filter
    type::String
    field::Filter
    NotF(filter) = new("not", filter)
end

struct JavaScriptF <: Filter
    type::String
    dimension::String
    jsfunction::String
    JavaScriptF(dimension, jsfunction) = new("javascript", dimension, jsfunction)
end

JSON.lower(f::JavaScriptF) = Dict("type" => f.type, "dimension" => f.dimension, "function" => f.jsfunction)

struct ExtractionFilter <: Filter
    type::String
    dimension::String
    value
    extractionFn::ExtractionFunction
    ExtractionFilter(dimension, value, extractionFn) = new("extraction", dimension, value, extractionFn)
end

struct Contains <: SearchQuerySpec
    type::String
    value::String
    caseSensitive
    function Contains(value; case_sensitive=nothing)
        nothing_or_type(case_sensitive, Bool)
        new("contains", value, case_sensitive)
    end
end

struct InsensitiveContains <: SearchQuerySpec
    type::String
    value::String
    InsensitiveContains(value) = new("insensitive_contains", value)
end

struct Fragment <: SearchQuerySpec
    type::String
    value::String
    caseSensitive
    function Fragment(value; case_sensitive=nothing)
        nothing_or_type(case_sensitive, Bool)
        new("fragment", value, case_sensitive)
    end
end

struct SearchF <: Filter
    type::String
    dimension::String
    query::SearchQuerySpec
    extractionFn
    function SearchF(dimension, query; extractionFn=nothing)
        nothing_or_type(extractionFn, ExtractionFunction)
        new("search", dimension, query, extractionFn)
    end
end

struct InF <: Filter
    type::String
    dimension::String
    values::Vector
    InF(dimension, values) = new("in", dimension, values)
end

struct Like <: Filter
    type::String
    dimension::String
    pattern::String
    escape
    extractionFn
    function Like(dimension, pattern; escape=nothing, extractionFn=nothing)
        nothing_or_type(escape, AbstractString)
        nothing_or_type(extractionFn, ExtractionFunction)
        new("like", dimension, pattern, escape, extractionFn)
    end
end

struct Bound <: Filter
    type::String
    dimension::String
    lower
    upper
    lowerStrict
    upperStrict
    ordering
    extractionFn
    function Bound(dimension; lower=nothing, upper=nothing, lowerStrict=nothing, upperStrict=nothing, ordering=nothing, extractionFn=nothing)
        nothing_or_type(lower, String)
        nothing_or_type(upper, String)
        lower === upper === nothing && error("At least one of lower and upper must be specified")
        nothing_or_type(lowerStrict, Bool)
        nothing_or_type(upperStrict, Bool)
        nothing_or_type(ordering, String)
        nothing_or_type(extractionFn, ExtractionFunction)
        new("bound", dimension, lower, upper, lowerStrict, upperStrict, ordering, extractionFn)
    end
end

struct IntervalF <: Filter
    type::String
    dimension::String
    intervals::Vector{Interval}
    extractionFn
    function IntervalF(dimension, intervals; extractionFn=nothing)
        nothing_or_type(extractionFn, ExtractionFunction)
        new("interval", dimension, intervals, extractionFn)
    end
end

struct TrueF <: Filter
    type::String
    TrueF() = new("true")
end
