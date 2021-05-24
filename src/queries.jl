query_type(::Type{Query}) = error("Unknown query type")
query_type(q::T) where T<:Query = query_type(T)

mutable struct Timeseries <: Query
    dataSource::DataSource
    intervals::Vector{Interval}
    granularity::Granularity
    filter
    aggregations::Aggregator
    postAggregations
    descending
    limit
    context
end

Timeseries(
    dataSource, intervals, granularity;
    filter=nothing, aggregations=nothing, postAggregations=nothing,
    descending=nothing, limit=nothing, context=nothing
) = Timeseries(
        dataSource, intervals, granularity,
        filter, aggregations, postAggregations,
        descending, limit, context
    )

query_type(::Type{Timeseries}) = "timeseries"

mutable struct TopN <: Query
end

query_type(::Type{TopN}) = "topN"

mutable struct GroupBy <: Query
end

query_type(::Type{GroupBy}) = "groupBy"

mutable struct Scan <: Query
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
end

Scan(
    dataSource, intervals;
    columns=nothing, filter=nothing, order=nothing,
    limit=nothing, offset=nothing, resultFormat=nothing,
    batchSize=nothing, context=nothing, legacy=nothing
) = Scan(dataSource, intervals, columns, filter, order, limit, offset, resultFormat, batchSize, context, legacy)

query_type(::Type{Scan}) = "scan"

mutable struct Search <: Query
end

query_type(::Type{Search}) = "search"

mutable struct TimeBoundary <: Query
end

query_type(::Type{TimeBoundary}) = "timeBoundary"

mutable struct SegmentMetadata <: Query
end

query_type(::Type{SegmentMetadata}) = "segmentMetadata"

mutable struct DatasourceMetadata <: Query
end

query_type(::Type{DatasourceMetadata}) = "dataSourceMetadata"

mutable struct Sql <: Query
    query
    parameters
    resultFormat
    header
    context
end

Sql(query; parameters=nothing, resultFormat=nothing, header=nothing, context=nothing) =
    Sql(query, parameters, resultFormat, header, context)

query_type(::Type{Sql}) = "SQL"

function JSON.lower(q::Query)
    d = Dict()
    qt = query_type(q)
    if qt != query_type(Sql)
        d["queryType"] = qt
    end
    for fname ∈ propertynames(q)
        val = getproperty(q, fname)
        if !(val === nothing)
            d[fname] = val
        end
    end
    d
end

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
