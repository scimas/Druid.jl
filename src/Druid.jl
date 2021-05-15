"""
    Druid

A Druid SQL querying library.

See also: [Client](@ref), [execute](@ref)
"""
module Druid
using URIs:URI
using HTTP: request, IOError, StatusError
using JSON

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
    execute(client, query; resultFormat="object", header=false, context=Dict(), parameters=[])

Executes the Druid SQL `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.

#Examples
```julia-repl
julia> execute(client, "SELECT * FROM some_datasource LIMIT 10")
"[...\\n]"

julia> execute(client, "SELECT * FROM non_existent_datasource")
ERROR: Druid error during query execution
Dict{String,Any}("errorClass" => "org.apache.calcite.tools.ValidationException","host" => nothing,"error" => "Unknown exception","errorMessage" => "org.apache.calcite.runtime.CalciteContextException: From line 1, column 15 to line 1, column 23: Object 'non_existent_datasource' not found")
Error status: 5xx
Stacktrace: ...
```
"""
function execute(client::Client, query; resultFormat="object", header=false, context=Dict(), parameters=[])
    post_data = Dict(
        "query" => query,
        "resultFormat" => resultFormat,
        "header" => header,
        "context" => context,
        "parameters" => parameters
    )
    @debug post_data
    local response
    try
        response = request("POST", client.url, ["Content-Type" => "application/json"], JSON.json(post_data))
    catch err
        if isa(err, IOError)
            error("I/O Error during query execution")
        elseif isa(err, StatusError)
            if err.status ÷ 100 == 5
                local err_message
                try
                    err_message = JSON.parse(String(err.response.body))
                catch _e
                    error("Druid error during query execution, error message unavailable\n", "Error status: $(err.status)")
                end
                error("Druid error during query execution\n", err_message, "\nError status: $(err.status)")
            end
            error("Druid query execution failed with status $(err.status)")
        end
    end
    String(response.body)
end

end # module
