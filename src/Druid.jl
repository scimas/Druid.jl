"""
    Druid

A Druid SQL querying library.

See also: [Client](@ref), [execute](@ref)
"""
module Druid
using URIs
using HTTP: request, IOError, StatusError
using JSON
using Tables
using CSV

# Druid connection
export Client

# Queries
export execute, Timeseries, TopN, GroupBy, Scan, Search, TimeBoundary, SegmentMetadata, DatasourceMetadata, Sql

# DataSources
export Table, Lookup, Unioned, Inline, QuerySource, Join

# Granularities and Interval
export SimpleGranularity, DurationGranularity, PeriodGranularity, Interval

# Aggregatioons
export Count, SingleField, StringAgg, Grouping, Filtered

# PostAggregations
export Arithmetic, FieldAccess, FinalizingFieldAccess, ConstantPA, Greatest, Least, JavaScriptPA, HyperUniqueCardinality

# Dimension specs
export DefaultDS, ExtractionDS, ListFiltered, RegexFiltered, PrefixFiltered, LookupDS, Map, MapLookupDS

# ExtractionFunctions
export RegexEF, PartialEF, SearchQueryEF, SubstringEF, StrlenEF,
    TimeFormatEF, TimeParseEF, JavaScriptEF, RegisteredLookupEF, InlineLookupEF,
    CascadeEF, StringFormatEF, UpperEF, LowerEF, BucketEF

# Filters
export Selector, ColumnComparison, RegexF, AndF, OrF, NotF,
    JavaScriptF, Contains, InsensitiveContains, Fragment, SearchF, InF, Like,
    Bound, IntervalF, TrueF, ExtractionFilter

# Having Filters
export EqualTo, GreaterThan, LessThan, DimSelector, AndH, OrH, NotH

# TopN Metric Specs
export Numeric, Dimension, Inverted

# LimitSpec
export DefaultLS, OrderByColumn

# SQL Parameter
export Parameter

# Virtual columns
export Expression

# Export abstract types
export Query, Granularity, Aggregator, PostAggregator, Filter, HavingSpec, DataSource,
    DimensionSpec, ExtractionFunction, SearchQuerySpec, TopNMetricSpec, LimitSpec,
    VirtualColumn

"""
    Granularity

Supertype of all granularities.
"""
abstract type Granularity end

"""
    Aggregator

Supertype of all aggregators.
"""
abstract type Aggregator end

"""
    PostAggregator

Supertype of all post aggregators.
"""
abstract type PostAggregator end

"""
    ExtractionFunction

Supertype of all extraction functions.
"""
abstract type ExtractionFunction end

"""
    DimensionSpec

Supertype of all dimension specs.
"""
abstract type DimensionSpec end

"""
    SearchQuerySpec

Supertype of all search query specs.
"""
abstract type SearchQuerySpec end

"""
    Filter

Supertype of all filters.
"""
abstract type Filter end

"""
    HavingSpec

Supertype of all having filters.
"""
abstract type HavingSpec end

"""
    DataSource

Supertype of all data sources.
"""
abstract type DataSource end

"""
    TopNMetricSpec

Supertype of all topN metric specs.
"""
abstract type TopNMetricSpec end

"""
    LimitSpec

Supertype of all limit specs.
"""
abstract type LimitSpec end

"""
    VirtualColumn

Supertype of all virtual columns.
"""
abstract type VirtualColumn end

"""
    Query

Supertype of all queries.
"""
abstract type Query end

"""
    QueryResult

Supertype of all query results.
"""
abstract type QueryResult end

include("utils.jl")
include("client.jl")
include("intervals.jl")
include("granularities.jl")
include("dimensionspecs.jl")
include("filters.jl")
include("having.jl")
include("aggregations.jl")
include("post_aggregations.jl")
include("datasources.jl")
include("virtualcolumns.jl")
include("queries.jl")

end # module
