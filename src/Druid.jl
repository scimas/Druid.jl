"""
    Druid

A Druid SQL querying library.

See also: [Client](@ref), [execute](@ref)
"""
module Druid
using URIs
using HTTP: request, IOError, StatusError
using JSON

# Druid connection
export Client

# Queries
export execute, Timeseries, Scan, Sql

# DataSources
export Table, Lookup, Unioned, Inline, QuerySource, INNER, LEFT, Join

# Granularities and Interval
export SimpleGranularity, DurationGranularity, PeriodGranularity, Interval

# Aggregatioons
export Count, SingleField, StringAgg, Grouping, Filtered

# PostAggregations
export Arithmetic, FieldAccess, FinalizingFieldAccess, ConstantPA, Greatest, Least, JavaScriptPA, HyperUniqueCardinality

# Dimension specs
export DefaultDS, ListFiltered, RegexFiltered, PrefixFiltered, LookupDS, Map, MapLookupDS

# Filters
export Selector, ColumnComparison, RegexF, AndF, OrF, NotF,
    JavaScriptF, Contains, InsensitiveContains, Fragment, SearchF, InF, Like,
    Bound, IntervalF, TrueF

abstract type Granularity end
abstract type Aggregator end
abstract type PostAggregator end
abstract type DimensionSpec end
abstract type SearchQuerySpec end
abstract type Filter end
abstract type DataSource end
abstract type JoinType end
abstract type TopNMetricSpec end
abstract type Query end

function non_nothing_dict(s, d::Dict)
    for fname ∈ propertynames(s)
        val = getproperty(s, fname)
        if !(val === nothing)
            d[fname] = val
        end
    end
    d
end
non_nothing_dict(s) = non_nothing_dict(s, Dict())

include("client.jl")
include("intervals.jl")
include("granularities.jl")
include("dimensionspecs.jl")
include("filters.jl")
include("aggregations.jl")
include("post_aggregations.jl")
include("datasources.jl")
include("queries.jl")

end # module
