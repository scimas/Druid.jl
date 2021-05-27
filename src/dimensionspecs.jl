JSON.lower(ds::DimensionSpec) = non_nothing_dict(ds)
JSON.lower(ef::ExtractionFunction) = non_nothing_dict(ef)

"""
    DefaultDS(dimension::String; outputName::String, outputType::String)

The "default" type dimension spec.
"""
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

"""
    ExtractionDS(dimension::String, extractionFn::ExtractionFunction; outputName::String, outputType::String)

Dimension spec to use with an extraction function.
"""
struct ExtractionDS <: DimensionSpec
    type::String
    dimension::String
    extractionFn::ExtractionFunction
    outputName
    outputType
    function ExtractionDS(dimension, extractionFn; outputName=nothing, outputType=nothing)
        nothing_or_type(outputName, String)
        outputType === nothing || uppercase(outputType) ∈ ["STRING", "LONG", "FLOAT"] || error("Invalid outputType")
        new("extraction", dimension, extractionFn, outputName, outputType)
    end
end

"""
    ListFiltered(delegate::DimensionSpec, values::Vector{String}; isWhitelist::Bool)

Filter the `delegate` dimension spec with the `values`.
"""
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

"""
    RegexFiltered(delegate::DimensionSpec, pattern::String)

Filter the `delegate` dimension spec with the regex `pattern`.
"""
struct RegexFiltered <: DimensionSpec
    type::String
    delegate::DimensionSpec
    pattern::String
    RegexFiltered(delegate, pattern) = new("regexFiltered", delegate, pattern)
end

"""
    PrefixFiltered(delegate::DimensionSpec, prefix::String)

Filter the `delegate` dimension spec with the `prefix`.
"""
struct PrefixFiltered <: DimensionSpec
    type::String
    delegate::DimensionSpec
    prefix::String
    PrefixFiltered(delegate, prefix) = new("prefixFiltered", delegate, prefix)
end

"""
    LookupDS(dimension::String, name::String; outputName::String)

A dimension spec to use with the `name` lookup.
"""
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

"""
    Map(isOneToOne::Bool, dict::Dict)

The lookup map used in the map lookup dimension spec.
"""
struct Map
    isOneToOne::Bool
    dict::Dict
end

JSON.lower(m::Map) = Dict("type" => "map", "map" => m.dict, "isOneToOne" => m.isOneToOne)

"""
    MapLookupDS(dimension::String, lookup::Map; outputName::String, retainMissingValue::Bool, replaceMissingValueWith::String, optimize::Bool)

Map lookup dimension spec.
"""
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

"""
    RegexEF(expr::String; index::Integer, replaceMissingValue::Bool, replaceMissingValueWith::String)

Regex based extraction function.
"""
struct RegexEF <: ExtractionFunction
    type::String
    expr::String
    index
    replaceMissingValue
    replaceMissingValueWith
    function RegexEF(expr; index=nothing, replaceMissingValue=nothing, replaceMissingValueWith=nothing)
        index === nothing || (isa(index, Integer) && index >= 0) || error("index must be a non-negative integer")
        nothing_or_type(replaceMissingValue, Bool)
        new("regex", expr, index, replaceMissingValue, replaceMissingValueWith)
    end
end

"""
    PartialEF(expr::String)

Regex based extraction function that return nulls for non-matches.
"""
struct PartialEF <: ExtractionFunction
    type::String
    expr::String
    PartialEF(expr) = new("partial", expr)
end

"""
    SearchQueryEF(query::SearchQuerySpec)

Extraction using a search query spec.
"""
struct SearchQueryEF <: ExtractionFunction
    type::String
    query::SearchQuerySpec
    SearchQueryEF(query) = new("searchQuery", query)
end

"""
    SubstringEF(index::UInt64; length::Integer)

Substring extraction based on index and length.
"""
struct SubstringEF <: ExtractionFunction
    type::String
    index::UInt64
    length
    function SubstringEF(index; length=nothing)
        length === nothing || (isa(length, Integer) && length >= 0) || error("length must be a non-negative integer")
        new("substring", index, length)
    end
end

"""
    StrlenEF()

Extract string length.
"""
struct StrlenEF <: ExtractionFunction
    type::String
    StrlenEF() = new("strlen")
end

"""
    TimeFormatEF(; format::String, timeZone::String, locale::String, granularity::String, asMillis::Bool)

Extract timestamps.
"""
struct TimeFormatEF <: ExtractionFunction
    type::String
    format
    timeZone
    locale
    granularity
    asMillis
    function TimeFormatEF(; format=nothing, timeZone=nothing, locale=nothing, granularity=nothing, asMillis=nothing)
        nothing_or_type(format, String)
        nothing_or_type(timeZone, String)
        nothing_or_type(locale, String)
        nothing_or_type(granularity, Granularity)
        nothing_or_type(asMillis, Bool)
        new("timeFormat", format, timeZone, locale, granularity, asMillis)
    end
end

"""
    TimeParseEF(timeFormat::String, resultFormat::String)

Parse and extract time.
"""
struct TimeParseEF <: ExtractionFunction
    type::String
    timeFormat::String
    resultFormat::String
    joda
    function TimeParseEF(timeFormat, resultFormat; joda=nothing)
        nothing_or_type(joda, Bool)
        new("time", timeFormat, resultFormat, joda)
    end
end

"""
    JavaScriptEF(jsfunction::String; injective::Bool)

Extract using a custom JavaScript function.
"""
struct JavaScriptEF <: ExtractionFunction
    type::String
    jsfunction::String
    injective
    function JavaScriptEF(jsfunction; injective=nothing)
        nothing_or_type(injective, Bool)
        new("javascript", jsfunction, injective)
    end
end

function JSON.lower(ef::JavaScriptEF)
    d = Dict()
    d["type"] = ef.type
    d["function"] = ef.jsfunction
    if !(ef.injective === nothing)
        d["injective"] = ef.injective
    end
    d
end

"""
    RegisteredLookupEF(lookup::String; retainMissingValue::Bool, replaceMissingValueWith::String, injective::Bool, optimize::Bool)

Extract using a registered lookup.
"""
struct RegisteredLookupEF <: ExtractionFunction
    type::String
    lookup::String
    retainMissingValue
    replaceMissingValueWith
    injective
    optimize
    function RegisteredLookupEF(lookup; retainMissingValue=nothing, replaceMissingValueWith=nothing, injective=nothing, optimize=nothing)
        nothing_or_type(retainMissingValue, Bool)
        nothing_or_type(replaceMissingValueWith, String)
        nothing_or_type(injective, Bool)
        nothing_or_type(optimize, Bool)
        retainMissingValue != true || !isa(replaceMissingValueWith, String) || error("Cannon specify replaceMissingValueWith when retainMissingValue == true")
        new("registeredLookup", lookup, retainMissingValue, replaceMissingValueWith, injective, optimize)
    end
end

"""
    InlineLookupEF(lookup::Map; retainMissingValue::Bool, replaceMissingValueWith::String, injective::Bool, optimize::Bool)

Extract using an inline lookup.
"""
struct InlineLookupEF <: ExtractionFunction
    type::String
    lookup::Map
    retainMissingValue
    replaceMissingValueWith
    injective
    optimize
    function InlineLookupEF(lookup; retainMissingValue=nothing, replaceMissingValueWith=nothing, injective=nothing, optimize=nothing)
        nothing_or_type(retainMissingValue, Bool)
        nothing_or_type(replaceMissingValueWith, String)
        nothing_or_type(optimize, Bool)
        retainMissingValue != true || !isa(replaceMissingValueWith, String) || error("Cannon specify replaceMissingValueWith when retainMissingValue == true")
        new("lookup", lookup, retainMissingValue, replaceMissingValueWith, injective, optimize)
    end
end

"""
    CascadeEF(extractionFns::Vector{ExtractionFunction})

Apply multiple extraction functions in sequence.
"""
struct CascadeEF <: ExtractionFunction
    type::String
    extractionFns::Vector{ExtractionFunction}
    CascadeEF(extractionFns) = new("cascade", extractionFns)
end

"""
    StringFormatEF(format::String; nullHandling::String)

Extract strings using a format.
"""
struct StringFormatEF <: ExtractionFunction
    type::String
    format::String
    nullHandling
    function StringFormatEF(format; nullHandling=nothing)
        nullHandling === nothing || nullHandling ∈ ["nullString", "emptyString", "returnNull"] || error("Invalid nullHandling")
        new("stringFormat", format, nullHandling)
    end
end

"""
    UpperEF(; locale::String)

Extract strings as upper case.
"""
struct UpperEF <: ExtractionFunction
    type::String
    locale
    function UpperEF(;locale=nothing)
        nothing_or_type(locale, String)
        new("upper", locale)
    end
end

"""
    LowerEF(; locale)

Extract strings as lower case.
"""
struct LowerEF <: ExtractionFunction
    type::String
    locale
    function LowerEF(;locale=nothing)
        nothing_or_type(locale, String)
        new("lower", locale)
    end
end

"""
    BucketEF(; size::Integer, offset::Integer)

Bucket numeric values into `size` buckets starting at `offset`.
"""
struct BucketEF <: ExtractionFunction
    type::String
    size
    offset
    function BucketEF(;size=nothing, offset=nothing)
        size === nothing || (isa(size, Integer) && size >= 0) || error("size must be a non-negative integer")
        offset === nothing || (isa(offset, Integer) && offset >= 0) || error("offset must be a non-negative integer")
        new("bucket", size, offset)
    end
end
