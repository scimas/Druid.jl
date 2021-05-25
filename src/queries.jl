JSON.lower(q::Query) = non_nothing_dict(q)
query_type(q::Query) = q.queryType
JSON.lower(ms::TopNMetricSpec) = non_nothing_dict(ms)

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
        filter === nothing || typeassert(filter, Filter)
        aggregations === nothing || typeassert(aggregations, Vector{Aggregator})
        postAggregations === nothing || typeassert(postAggregations, Vector{PostAggregator})
        descending === nothing || typeassert(descending, Bool)
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        context === nothing || typeassert(context, Dict)
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
        previousStop === nothing || typeassert(previousStop, String)
        new("dimension", ordering, previousStop)
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
        aggregations === nothing || typeassert(aggregations, Vector{Aggregator})
        postAggregations === nothing || typeassert(postAggregations, Vector{PostAggregator})
        filter === nothing || typeassert(filter, Filter)
        context === nothing || typeassert(context, Dict)
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
    dataSource, intervals, granularity, dimension, threshold, metric;
    aggregations=nothing, postAggregations=nothing, filter=nothing, context=nothing
) = TopN(
    dataSource, intervals, granularity, dimension, threshold, metric;
    aggregations, postAggregations, filter, context
)

mutable struct GroupBy <: Query
end

mutable struct Scan <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{Interval}
    columns
    filter::Filter
    order
    limit
    offset
    resultFormat
    batchSize
    context
    legacy
    Scan(
        dataSource, intervals;
        columns=nothing, filter=nothing, order=nothing,
        limit=nothing, offset=nothing, resultFormat=nothing,
        batchSize=nothing, context=nothing, legacy=nothing
    ) = new("scan", dataSource, intervals, columns, filter, order, limit, offset, resultFormat, batchSize, context, legacy)
end

mutable struct Search <: Query
end

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
