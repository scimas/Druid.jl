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

include("client.jl")

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
Dict{String,Any}("errorClass" => "org.apache.calcite.tools.ValidationException"...
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
    local response
    try
        response = request("POST", client.url, ["Content-Type" => "application/json"], JSON.json(post_data))
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

end # module
