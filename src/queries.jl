JSON.lower(q::Query) = non_nothing_dict(q)
query_type(q::Query) = q.queryType

mutable struct Timeseries <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{Interval}
    granularity::Granularity
    filter::Filter
    aggregations::Vector{Aggregator}
    postAggregations
    descending
    limit
    context
    Timeseries(
        dataSource, intervals, granularity;
        filter=nothing, aggregations=nothing, postAggregations=nothing,
        descending=nothing, limit=nothing, context=nothing
    ) = new(
        "timeseries", dataSource, intervals, granularity,
        filter, aggregations, postAggregations,
        descending, limit, context
    )
end

mutable struct TopN <: Query
end

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
