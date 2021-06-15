"""
    Timeseries(dataSource::DataSource, intervals::Vector{<:Interval}, granularity::Granularity; <keyword arguments>)

Returns a Druid.TimeseriesResult which is compatible with the Tables.jl interface.

A method with all arguments as keyword arguments is also provided.

# Arguments
- filter::Filter = nothing
- aggregations::Vector{<:Aggregator} = nothing
- postAggregations::Vector{<:PostAggregator} = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- descending::Bool = nothing
- limit::Integer = nothing
- context::Dict = nothing
"""
mutable struct Timeseries <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{<:Interval}
    granularity::Granularity
    filter
    aggregations
    postAggregations
    virtualColumns
    descending
    limit
    context
    function Timeseries(
        dataSource, intervals, granularity;
        filter=nothing, aggregations=nothing, postAggregations=nothing,
        virtualColumns=nothing, descending=nothing, limit=nothing, context=nothing
    )
        nothing_or_type(filter, Filter)
        nothing_or_type(aggregations, Vector{<:Aggregator})
        nothing_or_type(postAggregations, Vector{<:PostAggregator})
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        nothing_or_type(descending, Bool)
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        nothing_or_type(context, Dict)
        new(
            "timeseries", dataSource, intervals, granularity,
            filter, aggregations, postAggregations,
            virtualColumns, descending, limit, context
        )
    end
end
Timeseries(
    ; dataSource, intervals, granularity,
    filter=nothing, aggregations=nothing, postAggregations=nothing,
    virtualColumns=nothing, descending=nothing, limit=nothing, context=nothing
) = Timeseries(
    dataSource, intervals, granularity;
    filter, aggregations, postAggregations,
    virtualColumns, descending, limit, context
)

function execute(client::Client, query::Timeseries; pretty=false)
    res = convert(Vector{Dict}, JSON.parse(execute_native_query(client, query; pretty)))
    names = [:timestamp, Symbol.(keys(res[1]["result"]))...]
    TimeseriesResult(names, res)
end

struct TimeseriesResult <: QueryResult
    names::Vector{Symbol}
    inner_array::Vector{Dict}
end

names(tr::TimeseriesResult) = getfield(tr, :names)

Base.getindex(tr::TimeseriesResult, i::Int) = TimeseriesRow(i, tr)

Tables.rowaccess(::TimeseriesResult) = true
Tables.rows(tr::TimeseriesResult) = tr

Base.eltype(::TimeseriesResult) = TimeseriesRow
Base.length(tr::TimeseriesResult) = length(getfield(tr, :inner_array))
Base.iterate(tr::TimeseriesResult, state=1) = state > length(tr) ? nothing : (TimeseriesRow(state, tr), state + 1)

struct TimeseriesRow <: Tables.AbstractRow
    row::Int
    source::TimeseriesResult
end

function Tables.getcolumn(tr::TimeseriesRow, name::Symbol)
    if name == :timestamp
        getfield(getfield(tr, :source), :inner_array)[getfield(tr, :row)][string(name)]
    else
        getfield(getfield(tr, :source), :inner_array)[getfield(tr, :row)]["result"][string(name)]
    end
end

Tables.getcolumn(tr::TimeseriesRow, i::Int) = Tables.getcolumn(tr, names(getfield(tr, :source))[i])
Tables.columnnames(tr::TimeseriesRow) = names(getfield(tr, :source))
