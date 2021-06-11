"""
    TimeBoundary(dataSource::DataSource; <keyword arguments>)

Returns a Dict{String, String} with "timestamp", "minTime" and/or "maxTime"
(depending on `bound`) as keys.

A method with all arguments as keyword arguments is also provided.

# Arguments
- bound::String = nothing
- filter::Filter = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- context::Dict = nothing
"""
mutable struct TimeBoundary <: Query
    queryType::String
    dataSource::DataSource
    bound
    filter
    virtualColumns
    context
    function TimeBoundary(dataSource; bound=nothing, filter=nothing, virtualColumns=nothing, context=nothing)
        bound === nothing || bound ∈ ["minTime", "maxTime"] || error("Invalid bound")
        nothing_or_type(filter, Filter)
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        nothing_or_type(context, Dict)
        new("timeBoundary", dataSource, bound, filter, virtualColumns, context)
    end
end
TimeBoundary(; dataSource, bound=nothing, filter=nothing, virtualColumns=nothing, context=nothing) =
    TimeBoundary(dataSource; bound, filter, virtualColumns, context)

function execute(client::Client, query::TimeBoundary; pretty=false)
    res = JSON.parse(execute_native_query(client, query; pretty))
    d = Dict{String, String}()
    d["timestamp"] = res[1]["timestamp"]
    if haskey(res[1]["result"], "minTime")
        d["minTime"] = res[1]["result"]["minTime"]
    end
    if haskey(res[1]["result"], "maxTime")
        d["maxTime"] = res[1]["result"]["maxTime"]
    end
    d
end
