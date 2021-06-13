JSON.lower(q::Query) = non_nothing_dict(q)
query_type(q::Query) = q.queryType
JSON.lower(ls::LimitSpec) = non_nothing_dict(ls)
Tables.istable(::QueryResult) = true

include("timeseries.jl")
include("topn.jl")
include("groupby.jl")
include("scan.jl")
include("search.jl")
include("timeboundary.jl")
include("segment_metadata.jl")
include("datasource_metadata.jl")
include("sql.jl")

"""
    execute(client, query; pretty=false)

Executes the native Druid `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.
"""
execute(client::Client, query::Query; pretty=false) = execute_native_query(client, query; pretty)

function execute_native_query(client::Client, query::Query; pretty=false)
    url = joinpath(client.url, "druid/v2")
    if pretty
        url = merge(url, query="pretty")
    end
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
