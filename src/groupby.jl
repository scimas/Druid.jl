"""
    OrderByColumn(dimension::String, direction::String; dimensionOrder=nothing)

dimensionOrder should be a String if provided.
"""
struct OrderByColumn
    dimension::String
    direction::String
    dimensionOrder
    function OrderByColumn(dimension, direction; dimensionOrder=nothing)
        direction ∈ ["ascending", "descending"] || error("Invalid direction")
        dimensionOrder === nothing ||
            (dimensionOrder = lowercase(dimensionOrder)) ∈ ["lexicographic", "alphanumeric", "numeric", "strlen"] ||
            error("Invalid dimensionOrder")
        new(dimension, direction, dimensionOrder)
    end
end
JSON.lower(oc::OrderByColumn) = non_nothing_dict(oc)

"""
    DefaultLS(; limit=nothing, offset=nothing, columns=nothing)

Default limitSpec.

limit and offset should be non negative integers if provided. columns should be
Vector{OrderByColumn} if provided.
"""
struct DefaultLS <: LimitSpec
    type::String
    limit
    offset
    columns
    function DefaultLS(; limit=nothing, offset=nothing, columns=nothing)
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        offset === nothing || (isa(offset, Integer) && offset >= 0) || error("offset must be a non-negative integer")
        nothing_or_type(columns, Vector{OrderByColumn})
    end
end

"""
    GroupBy(
        dataSource::DataSource,
        dimensions::Vector{<:DimensionSpec},
        intervals::Vector{<:Interval},
        granularity::Granularity;
        <keyword arguments>
    )

Returns a Druid.GroupByResult which is compatible with the Tables.jl interface.

A method with all arguments as keyword arguments is also provided.

# Arguments
- limitSpec::LimitSpec = nothing
- having::HavingSpec = nothing
- filter::Filter = nothing
- aggregations::Vector{<:Aggregator} = nothing
- postAggregations::Vector{<:PostAggregator} = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- subtotalsSpec::Vector{Vector{String}} = nothing
- context::Dict = nothing
"""
mutable struct GroupBy <: Query
    queryType::String
    dataSource::DataSource
    dimensions::Vector{<:DimensionSpec}
    intervals::Vector{<:Interval}
    granularity::Granularity
    limitSpec
    having
    filter
    aggregations
    postAggregations
    virtualColumns
    subtotalsSpec
    context
    function GroupBy(
        dataSource, dimensions, intervals, granularity;
        limitSpec=nothing, having=nothing, filter=nothing,
        aggregations=nothing, postAggregations=nothing,
        virtualColumns=nothing, subtotalsSpec=nothing, context=nothing
    )
        nothing_or_type(limitSpec, LimitSpec)
        nothing_or_type(having, Union{HavingSpec, Filter})
        nothing_or_type(filter, Filter)
        nothing_or_type(aggregations, Vector{<:Aggregator})
        nothing_or_type(postAggregations, Vector{<:PostAggregator})
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        nothing_or_type(subtotalsSpec, Vector{Vector{String}})
        nothing_or_type(context, Dict)
        new("groupBy", dataSource, dimensions, intervals, granularity, limitSpec,
        having, filter, aggregations, postAggregations, virtualColumns, subtotalsSpec, context)
    end
end
GroupBy(
    ; dataSource, dimensions, intervals, granularity,
    limitSpec=nothing, having=nothing, filter=nothing, aggregations=nothing,
    postAggregations=nothing, virtualColumns=nothing, subtotalsSpec=nothing, context=nothing
) = GroupBy(
    dataSource, dimensions, intervals, granularity;
    limitSpec, having, filter, aggregations, postAggregations, virtualColumns, subtotalsSpec, context
)

function execute(client::Client, query::GroupBy; pretty=false)
    res = convert(Vector{Dict}, JSON.parse(execute_native_query(client, query; pretty)))
    names = [:timestamp, Symbol.(keys(res[1]["event"]))...]
    GroupByResult(names, res)
end

struct GroupByResult <: QueryResult
    names::Vector{Symbol}
    inner_array::Vector{Dict}
end

names(gr::GroupByResult) = getfield(gr, :names)

Base.getindex(gr::GroupByResult, i::Int) = getfield(gr, :inner_array)[i]

Tables.rowaccess(::GroupByResult) = true
Tables.rows(gr::GroupByResult) = gr

Base.eltype(::GroupByResult) = GroupByRow
Base.length(gr::GroupByResult) = length(getfield(gr, :inner_array))
Base.iterate(gr::GroupByResult, state=1) = state > length(gr) ? nothing : (GroupByRow(state, gr), state + 1)

struct GroupByRow
    row::Int
    source::GroupByResult
end

function Tables.getcolumn(gr::GroupByRow, name::Symbol)
    if name == :timestamp
        getfield(gr, :source)[getfield(gr, :row)][string(name)]
    else
        getfield(gr, :source)[getfield(gr, :row)]["event"][string(name)]
    end
end

Tables.getcolumn(gr::GroupByRow, i::Int) = Tables.getcolumn(gr, names(getfield(gr, :source))[i])
Tables.columnnames(gr::GroupByRow) = names(getfield(gr, :source))

function Base.show(io::IO, gr::GroupByRow)
    print(io, getfield(gr, :source)[getfield(gr, :row)])
end