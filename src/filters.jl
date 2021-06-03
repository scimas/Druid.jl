JSON.lower(f::Filter) = non_nothing_dict(f)
JSON.lower(sqs::SearchQuerySpec) = non_nothing_dict(sqs)

"""
    Selector(dimension::String, value::String)

dimension = value filter.
"""
struct Selector <: Filter
    type::String
    dimension::String
    value::String
    Selector(dimension, value) = new("selector", dimension, value)
end

"""
    ColumnComparison(dimensions::Tuple{DimensionSpec, DimensionSpec})

    ColumnComparison(dim1::DimensionSpec, dim2::DimensionSpec)

dimension1 = dimension2 filter.
"""
struct ColumnComparison <: Filter
    type::String
    dimensions::Tuple{DimensionSpec, DimensionSpec}
    ColumnComparison(dimensions) = new("columnComparison", dimensions)
end

ColumnComparison(dim1, dim2) = ColumnComparison((dim1, dim2))

"""
    RegexF(dimension::String, pattern::String)

Regex pattern matching filter.
"""
struct RegexF <: Filter
    type::String
    dimension::String
    pattern::String
    RegexF(dimension, pattern) = new("regex", dimension, pattern)
end

"""
    AndF(filters::Vector{Filter})

Match all `filters`.
"""
struct AndF <: Filter
    type::String
    fields::Vector{<:Filter}
    AndF(filters) = new("and", filters)
end

"""
    OrF(filters::Vector{Filter})

Match at least one of the `filters`.
"""
struct OrF <: Filter
    type::String
    fields::Vector{<:Filter}
    OrF(filters) = new("or", filters)
end

"""
    NotF(filter::Filter)

Do not match `filter`.
"""
struct NotF <: Filter
    type::String
    field::Filter
    NotF(filter) = new("not", filter)
end

"""
    JavaScriptF(dimension::String, jsfunction::String)

Filter using a custom JavaScript function.
"""
struct JavaScriptF <: Filter
    type::String
    dimension::String
    jsfunction::String
    JavaScriptF(dimension, jsfunction) = new("javascript", dimension, jsfunction)
end

JSON.lower(f::JavaScriptF) = Dict("type" => f.type, "dimension" => f.dimension, "function" => f.jsfunction)

"""
    ExtractionFilter(dimension::String, value, extractionFn::ExtractionFunction)

Filter to `value` extracted using `extractionFn`.
"""
struct ExtractionFilter <: Filter
    type::String
    dimension::String
    value
    extractionFn::ExtractionFunction
    ExtractionFilter(dimension, value, extractionFn) = new("extraction", dimension, value, extractionFn)
end

"""
    Contains(value::String; case_sensitive=nothing)

Search query spec for strings containing `value`.

case_sensitive should be a Bool if provided.
"""
struct Contains <: SearchQuerySpec
    type::String
    value::String
    caseSensitive
    function Contains(value; case_sensitive=nothing)
        nothing_or_type(case_sensitive, Bool)
        new("contains", value, case_sensitive)
    end
end

"""
    InsensitiveContains(value::String)

Case insensitive string contains searhc query spec.
"""
struct InsensitiveContains <: SearchQuerySpec
    type::String
    value::String
    InsensitiveContains(value) = new("insensitive_contains", value)
end

"""
    Fragment(value::String; case_sensitive=nothing)

Fragment search query spec.

case_sensitive should be a Bool if provided.
"""
struct Fragment <: SearchQuerySpec
    type::String
    value::String
    caseSensitive
    function Fragment(value; case_sensitive=nothing)
        nothing_or_type(case_sensitive, Bool)
        new("fragment", value, case_sensitive)
    end
end

"""
    SearchF(dimension::String, query::SearchQuerySpec; extractionFn=nothing)

Filter using a query and optionally extraction function.

extractionFn should be an ExtractionFunction if provided.
"""
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

"""
    InF(dimension::String, values::Vector)

Filter if value is in `values`.
"""
struct InF <: Filter
    type::String
    dimension::String
    values::Vector
    InF(dimension, values) = new("in", dimension, values)
end

"""
    Like(dimension::String, pattern::String; escape=nothing, extractionFn=nothing)

Filter strings matching `pattern`.

escape should be a String and extractionFn an ExtractionFunction if provided.
"""
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

"""
    Bound(dimension::String;
        lower=nothing, upper=nothing, lowerStrict=nothing, upperStrict=nothing,
        ordering=nothing, extractionFn=nothing)

Filter values bounded in a range.

lower, upper and ordering should be `String`s if provided. lowerStrict and
upperStrict should be `Bool`s if provided. extractionFn should be an
ExtractionFunction if provided.
"""
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

"""
    IntervalF(dimension::String, intervals::Vector{Interval}; extractionFn=nothing)

Filter by time falling in one of the `intervals`.

extractionFn should be an ExtractionFunction if provided.
"""
struct IntervalF <: Filter
    type::String
    dimension::String
    intervals::Vector{<:Interval}
    extractionFn
    function IntervalF(dimension, intervals; extractionFn=nothing)
        nothing_or_type(extractionFn, ExtractionFunction)
        new("interval", dimension, intervals, extractionFn)
    end
end

"""
    TrueF()

Filter everything.
"""
struct TrueF <: Filter
    type::String
    TrueF() = new("true")
end
