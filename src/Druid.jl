"""
    Druid

A Druid SQL querying library.

See also: [Client](@ref), [execute](@ref)
"""
module Druid
using URIs
using HTTP: request, IOError, StatusError
using JSON

export Client, execute
export Timeseries, Scan, Sql
export Table, Lookup, Unioned, Inline, QuerySource, INNER, LEFT, Join
export SimpleGranularity, DurationGranularity, PeriodGranularity, Interval

abstract type Granularity end
abstract type DataSource end
abstract type JoinType end
abstract type Query end

include("client.jl")
include("intervals.jl")
include("granularities.jl")
include("datasources.jl")
include("queries.jl")

end # module
