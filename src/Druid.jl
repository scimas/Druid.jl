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

abstract type DataSource end
abstract type Query end

include("client.jl")
include("queries.jl")

end # module
