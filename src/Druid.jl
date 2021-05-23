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

include("client.jl")
include("queries.jl")

end # module
