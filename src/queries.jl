JSON.lower(q::Query) = non_nothing_dict(q)
query_type(q::Query) = q.queryType
JSON.lower(ms::TopNMetricSpec) = non_nothing_dict(ms)
JSON.lower(ls::LimitSpec) = non_nothing_dict(ls)

mutable struct Timeseries <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{Interval}
    granularity::Granularity
    filter
    aggregations
    postAggregations
    descending
    limit
    context
    function Timeseries(
        dataSource, intervals, granularity;
        filter=nothing, aggregations=nothing, postAggregations=nothing,
        descending=nothing, limit=nothing, context=nothing
    )
        nothing_or_type(filter, Filter)
        nothing_or_type(aggregations, Vector{Aggregator})
        nothing_or_type(postAggregations, Vector{PostAggregator})
        nothing_or_type(descending, Bool)
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        nothing_or_type(context, Dict)
        new(
            "timeseries", dataSource, intervals, granularity,
            filter, aggregations, postAggregations,
            descending, limit, context
        )
    end
end
Timeseries(
    ;dataSource, intervals, granularity,
    filter=nothing, aggregations=nothing, postAggregations=nothing,
    descending=nothing, limit=nothing, context=nothing
) = Timeseries(
    dataSource, intervals, granularity;
    filter, aggregations, postAggregations,
    descending, limit, context
)

struct Numeric <: TopNMetricSpec
    type::String
    metric::String
    Numeric(metric) = new("metric", metric)
end

struct Dimension <: TopNMetricSpec
    type::String
    ordering
    previousStop
    function Dimension(; ordering=nothing, previousStop=nothing)
        ordering === nothing || lowercase(ordering) ∈ ["lexicographic", "alphanumeric", "numeric", "strlen"] || error("Invalid ordering")
        nothing_or_type(previousStop, String)
        new("dimension", lowercar(ordering), previousStop)
    end
end

struct Inverted <: TopNMetricSpec
    type::String
    metric::TopNMetricSpec
    Inverted(metric) = new("inverted", metric)
end

mutable struct TopN <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{Interval}
    granularity::Granularity
    dimension::DimensionSpec
    threshold::UInt64
    metric::TopNMetricSpec
    aggregations
    postAggregations
    filter
    context
    function TopN(
        dataSource, intervals, granularity, dimension, threshold, metric;
        aggregations=nothing, postAggregations=nothing, filter=nothing, context=nothing
    )
        nothing_or_type(aggregations, Vector{Aggregator})
        nothing_or_type(postAggregations, Vector{PostAggregator})
        nothing_or_type(filter, Filter)
        nothing_or_type(context, Dict)
        if !isa(metric, Numeric) && !(isa(metric, Inverted) && isa(metric.metric, Numeric))
            if !(aggregations === nothing) || !(postAggregations === nothing)
                error("Aggregations and post aggregations can only be specified for Numeric metric specs")
            end
        end
        new(
            "topN", dataSource, intervals, granularity, dimension, threshold, metric,
            aggregations, postAggregations, filter, context
        )
    end
end
TopN(
    ;dataSource, intervals, granularity, dimension, threshold, metric,
    aggregations=nothing, postAggregations=nothing, filter=nothing, context=nothing
) = TopN(
    dataSource, intervals, granularity, dimension, threshold, metric;
    aggregations, postAggregations, filter, context
)

struct OrderByColumn
    dimension::String
    direction::String
    dimensionOrder
    function OrderByColumn(dimension, direction; dimensionOrder=nothing)
        direction ∈ ["ascending", "descending"] || error("Invalid direction")
        dimensionOrder === nothing || lowercase(dimensionOrder) ∈ ["lexicographic", "alphanumeric", "numeric", "strlen"] || error("Invalid dimsionOrder")
        new(dimension, direction, dimensionOrder)
    end
end

struct DefaultLS <: LimitSpec
    type::String
    limit
    offset
    columns
    function DefaultLS(;limit=nothing, offset=nothing, columns=nothing)
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        offset === nothing || (isa(offset, Integer) && offset >= 0) || error("offset must be a non-negative integer")
        nothing_or_type(columns, Vector{OrderByColumn})
    end
end

mutable struct GroupBy <: Query
    queryType::String
    dataSource::DataSource
    dimensions::Vector{DimensionSpec}
    intervals::Vector{Interval}
    granularity::Granularity
    limitSpec
    having
    filter
    aggregations
    postAggregations
    subtotalsSpec
    context
    function GroupBy(
        dataSource, dimesnions, intervals, granularity;
        limitSpec=nothing, having=nothing, filter=nothing, aggregations=nothing, postAggregations=nothing, subtotalsSpec=nothing, context=nothing
    )
        nothing_or_type(limitSpec, LimitSpec)
        nothing_or_type(having, Union{HavingSpec, Filter})
        nothing_or_type(filter, Filter)
        nothing_or_type(aggregations, Vector{Aggregator})
        nothing_or_type(postAggregations, Vector{PostAggregator})
        nothing_or_type(subtotalsSpec, Vector{Vector{String}})
        nothing_or_type(context, Dict)
        new("groupBy", dataSource, dimensions, intervals, granularity, limitSpec, having, filter, aggregations, postAggregations, subtotalsSpec, context)
    end
end
GroupBy(
    ;dataSource, dimesnions, intervals, granularity,
    limitSpec=nothing, having=nothing, filter=nothing, aggregations=nothing, postAggregations=nothing, subtotalsSpec=nothing, context=nothing
) = GroupBy(
    dataSource, dimesnions, intervals, granularity;
    limitSpec, having, filter, aggregations, postAggregations, subtotalsSpec, context
)

mutable struct Scan <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{Interval}
    columns
    filter
    order
    limit
    offset
    resultFormat
    batchSize
    context
    legacy
    function Scan(
        dataSource, intervals;
        columns=nothing, filter=nothing, order=nothing,
        limit=nothing, offset=nothing, resultFormat=nothing,
        batchSize=nothing, context=nothing, legacy=nothing
    )
        nothing_or_type(columns, Vector{String})
        nothing_or_type(filter, Filter)
        order === nothing || lowercase(order) ∈ ["ascending", "descending", "none"] || error("Invalid order")
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        offset === nothing || (isa(offset, Integer) && offset >= 0) || error("offset must be a non-negative integer")
        resultFormat === nothing || resultFormat ∈ ["list", "compactedList"] || error("Invalid resultFormat")
        batchSize === nothing || (isa(batchSize, Integer) && batchSize >= 0) || error("batchSize must be a non-negative integer")
        nothing_or_type(context, Dict)
        nothing_or_type(legacy, Bool)
        new("scan", dataSource, intervals, columns, filter, order, limit, offset, resultFormat, batchSize, context, legacy)
    end
end
Scan(
    ;dataSource, intervals,
    columns=nothing, filter=nothing, order=nothing,
    limit=nothing, offset=nothing, resultFormat=nothing,
    batchSize=nothing, context=nothing, legacy=nothing
) = Scan(
    dataSource, intervals;
    columns, filter, order,
    limit, offset, resultFormat,
    batchSize, context, legacy
)

mutable struct Search <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{Interval}
    query::SearchQuerySpec
    granularity
    filter
    sort
    limit
    context
    function Search(
        dataSource, intervals, query;
        granularity=nothing, filter=nothing, sort=nothing, limit=nothing, context=nothing
    )
        nothing_or_type(granularity, Granularity)
        nothing_or_type(filter, Filter)
        sort === nothing || lowercase(sort) ∈ ["lexicographic", "alphanumeric", "numeric", "strlen"] || error("Invalid sort value")
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        nothing_or_type(context, Dict)
        new("search", dataSource, intervals, query, granularity, filter, Dict("type" => sort), limit, context)
    end
end
Search(
    ;dataSource, intervals, query,
    granularity=nothing, filter=nothing, sort=nothing, limit=nothing, context=nothing
) = Search(
    dataSource, intervals, query;
    granularity, filter, sort, limit, context
)

mutable struct TimeBoundary <: Query
end

mutable struct SegmentMetadata <: Query
end

mutable struct DatasourceMetadata <: Query
end

mutable struct Sql <: Query
    query::String
    parameters
    resultFormat
    header
    context
    Sql(query; parameters=nothing, resultFormat=nothing, header=nothing, context=nothing) =
        new(query, parameters, resultFormat, header, context)
end

query_type(::Sql) = "SQL"

"""
    execute(client, query)

Executes the native Druid `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.
"""
function execute(client::Client, query::Query; pretty=false)
    url = joinpath(client.url, "druid/v2")
    if pretty
        url = merge(url, query="pretty")
    end
    do_query(url, query)
end

"""
    execute(client, query::Sql)

Executes the Druid SQL `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.

# Examples
```julia-repl
julia> query = Sql("SELECT * FROM some_datasource LIMIT 10")
julia> execute(client, query)
"[...\\n]"

julia> query = Sql("SELECT * FROM non_existent_datasource")
julia> execute(client, query)
ERROR: Druid error during query execution
Dict{String,Any}("errorClass" => "org.apache.calcite.tools.ValidationException"...
```
"""
function execute(client::Client, query::Sql)
    url = joinpath(client.url, "druid/v2/sql")
    do_query(url, query)
end

function do_query(url, post_data)
    local response
    try
        response = request("POST", url, ["Content-Type" => "application/json"], json(post_data))
    catch err
        if isa(err, IOError)
            error("I/O Error during query execution")
        elseif isa(err, StatusError)
            local err_message
            try
                err_message = JSON.parse(String(err.response.body))
            catch
                error("Druid error during query execution, error message unavailable\n", "Error status: $(err.status)")
            end
            error("Druid error during query execution\n", err_message, "\nError status: $(err.status)")
        end
    end
    String(response.body)
end

function Base.show(io::IO, q::Query)
    print(io, query_type(q), '(')
    firstprint = true
    for fname in propertynames(q)
        val = getproperty(q, fname)
        if !(val === nothing)
            firstprint || print(io, ", ")
            if firstprint
                firstprint = false
            end
            print(io, fname, '=', repr(val, context=io))
        end
    end
    print(io, ')')
end
