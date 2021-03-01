"""
    Druid

A Druid SQL querying library.

See also: [Client](@ref), [execute](@ref)
"""
module Druid
using URIs:URI
using HTTP: request, IOError, StatusError
using JSON: json, parse
using JSONTables:jsontable

export Client, execute

"""
    Client

    Client(url::URIs.URI)
    Client(url::AbstractString)
    Client(host, port, endpoint, scheme)

Druid SQL query endpoint connection information store.

#Examples
```julia-repl
julia> client = Client("http://localhost:8888/druid/v2/sql")
Client(URI("http://localhost:8888/druid/v2/sql"))

julia> client = Client("localhost", 8082, "druid/v2/sql", "http")
Client(URI("http://localhost:8082/druid/v2/sql"))
```
"""
struct Client
    url::URI
end
Client(host, port, endpoint, scheme) = 
    Client(joinpath(URI(;scheme=scheme, host=host, port=port), endpoint))
Client(url::AbstractString) = Client(URI(url))

"""
    execute(client, query; parser=JSONTables.jsontable)

Executes the Druid SQL `query` on the `client::Client`. Returns the query result
as parsed by the `parser` (a `JSONTable` - compatible with Tables.jl interface -
by default). Throws exception if query execution fails.

Pass the `String` function as `parser` if the results are needed exactly as
received from Druid.

#Examples
```julia-repl
julia> execute(client, "SELECT * FROM some_datasource LIMIT 10")
JSONTables.Table{...

julia> execute(client, "SELECT * FROM non_existent_datasource")
Failed Query: SELECT * FROM non_existent_datasource
Dict{String,Any}("errorClass" => "org.apache.calcite.tools.ValidationException","host" => nothing,"error" => "Unknown exception","errorMessage" => "org.apache.calcite.runtime.CalciteContextException: From line 1, column 15 to line 1, column 23: Object 'testdata2' not found")
ERROR: Couldn't execute query
Stacktrace: ...
```
"""
function execute(client::Client, query; parser=jsontable)
    post_data = Dict("query" => query)
    local response
    try
        response = request("POST", client.url, ["Content-Type" => "application/json"], json(post_data))
    catch err
        if isa(err, IOError)
            error("I/O Error during query execution")
        elseif isa(err, StatusError)
            if err.status ÷ 100 == 5
                local err_message
                try
                    err_message = parse(String(err.response.body))
                catch _e
                    error("Druid error during query execution, error message unavailable\n", "Query: ", query)
                end
                error("Druid query execution failed with error:\n", err_message, "\nFailed query: ", query)
            end
            error("Druid query execution failed with status $(err.status)")
        end
    end
    parser(response.body)
end

end # module
