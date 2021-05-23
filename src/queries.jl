DataSourceType = Union{AbstractString,Dict{T,U}} where {T<:AbstractString, U}
IntervalType = Union{AbstractString,Tuple{AbstractString,AbstractString}}

abstract type Query end

mutable struct Timeseries <: Query
end

mutable struct TopN <: Query
end

mutable struct GroupBy <: Query
end

mutable struct Scan <: Query
    dataSource::DataSourceType
    intervals::IntervalType
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

mutable struct Search <: Query
end

mutable struct TimeBoundary <: Query
end

mutable struct SegmentMetadata <: Query
end

mutable struct DatasourceMetadata <: Query
end

mutable struct Sql <: Query
    query
    parameters
    resultFormat
    header
    context
end

Sql(query; parameters=nothing, resultFormat=nothing, header=nothing, context=nothing) =
    Sql(query, parameters, resultFormat, header, context)

"""
    execute(client, query)

Executes the native Druid `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.
"""
function execute(client::Client, query::Query; pretty=false)
    post_data = Dict()
    post_data["queryType"] = query_type(query)
    for fname ∈ fieldnames(typeof(query))
        val = getfield(query, fname)
        if !(val === nothing)
            post_data[fname] = val
        end
    end
    url = joinpath(client.url, "druid/v2")
    if pretty
        url = merge(url, query="pretty")
    end
    do_query(url, post_data)
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
    post_data = Dict()
    for fname ∈ fieldnames(Sql)
        val = getfield(query, fname)
        if !(val === nothing)
            post_data[fname] = val
        end
    end
    url = joinpath(client.url, "druid/v2/sql")
    do_query(url, post_data)
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

query_type(q::Query) = error("Unknown query type. Please implement `query_type` for ", typeof(q))
query_type(::Timeseries) = "timeseries"
query_type(::TopN) = "topN"
query_type(::GroupBy) = "groupBy"
query_type(::Scan) = "scan"
query_type(::Search) = "search"
query_type(::TimeBoundary) = "timeBoundary"
query_type(::SegmentMetadata) = "segmentMetadata"
query_type(::DatasourceMetadata) = "dataSourceMetadata"
