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
    execute(client, query)

Executes the Druid SQL `query` on the `client::Client`. Returns a `JSONTable` -
compatible with Tables.jl interface.

Throws exception if query execution fails.

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
function execute(client::Client, query)
    post_data = Dict("query" => query)
    response = try
        request("POST", client.url, ["Content-Type" => "application/json"], json(post_data))
    catch err
        if isa(err, IOError)
            println("I/O Error happened during query execution")
            println(err.e)
            throw(Base.IOError)
        elseif isa(err, StatusError)
            if err.status ÷ 100 == 5
                err_message = try
                    parse(String(err.response.body))
                catch _e
                    println("Druid error during query execution, error message unavailable")
                    println("Query: ", query)
                    throw(Base.IOError)
                end
                println("Failed Query: ", query)
                println(err_message)
                throw(ErrorException("Couldn't execute query"))
            throw(ErrorException("Query failed with status $(err.status)"))
            end
        end
    end
    jsontable(response.body)
end

end # module
