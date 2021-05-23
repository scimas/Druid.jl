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
export Scan, Sql
export Table, Lookup, Unioned, Inline, QuerySource, INNER, LEFT, Join

abstract type DataSource end
abstract type JoinType end
abstract type Query end

include("client.jl")
include("datasources.jl")
include("queries.jl")

end # module
